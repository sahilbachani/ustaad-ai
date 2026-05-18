import * as functions from "firebase-functions";
import { db, FieldValue, GeoPoint } from "./admin";
import { createJob } from "./api/createJob";
import { updateJobState } from "./api/updateJobState";
import { getProviders } from "./api/getProviders";
import { updateProviderScore } from "./api/updateProviderScore";
import { logAIResponse } from "./api/logAIResponse";
import { triggerWorkflow } from "./api/triggerWorkflow";
import { sendWhatsApp } from "./utils/whatsapp";




// ─────────────────────────────────────────
// WF1: INTAKE — WhatsApp webhook
// ─────────────────────────────────────────
export const whatsappWebhook = functions.https.onRequest(
  async (req, res) => {
    const customerPhone = req.body.From?.replace("whatsapp:", "");
    const messageBody = req.body.Body;

    if (!customerPhone || !messageBody) {
      res.status(400).send("Bad request");
      return;
    }

    console.log(`📱 Message from ${customerPhone}: ${messageBody}`);

    const sessionRef = db.collection("sessions").doc(customerPhone);
    const sessionSnap = await sessionRef.get();
    const session = sessionSnap.exists
      ? sessionSnap.data()!
      : { step: "IDLE" };

    // ── Awaiting job confirmation ──
    if (session.step === "AWAITING_CONFIRMATION") {
      if (messageBody.trim() === "1") {
        const jobId = await createJob({
          customerId: customerPhone,
          service: session.entities.service,
          subtype: session.entities.subtype || null,
          location: session.entities.location,
          urgency: session.entities.urgency,
          aiDecisionLog: session.aiLog,
        });

        await updateJobState(jobId, "MATCHED", {
          providerId: session.matchedProviderId,
          quotedPrice: session.quote,
        });

        await db
          .collection("providers")
          .doc(session.matchedProviderId)
          .update({ activeJobId: jobId });

        await sendWhatsApp(
          customerPhone,
          `✅ Kaam confirm!\nJob ID: ${jobId}\nProvider ko notify kar diya.`
        );

        const providerSnap = await db
          .collection("providers")
          .doc(session.matchedProviderId)
          .get();

        await sendWhatsApp(
          providerSnap.data()!.whatsappNumber,
          `🔔 Naya kaam!\nService: ${session.entities.service}\n` +
          `Location: ${session.entities.location}\nApp khol kar accept karein.`
        );

        await triggerWorkflow("PROVIDER_ASSIGNED", { jobId });
        await sessionRef.set({ step: "IDLE" });

      } else {
        await sendWhatsApp(customerPhone, "Request cancel kar di gayi.");
        await sessionRef.set({ step: "IDLE" });
      }

      res.status(200).send("OK");
      return;
    }

    // ── Awaiting rating ──
    if (session.step === "AWAITING_RATING") {
      const rating = parseInt(messageBody.trim());
      if (rating >= 1 && rating <= 5) {
        await db.collection("jobs")
          .doc(session.jobId)
          .update({ rating });

        const { runSentimentAgent } = await import("./agents/sentimentAgent.js");
        const sentiment = await runSentimentAgent(messageBody);
        await logAIResponse(
          session.jobId, "sentimentAgent",
          { feedback: messageBody }, sentiment
        );

        if (sentiment.flag_dispute) {
          await updateJobState(session.jobId, "DISPUTED", {
            disputeReason: "Negative sentiment detected",
            payoutHeld: true,
          });
          await db.collection("disputes").add({
            jobId: session.jobId,
            customerId: customerPhone,
            providerId: session.providerId,
            reason: "Customer flagged",
            status: "Open",
            createdAt: FieldValue.serverTimestamp(),
          });
          await sendWhatsApp(
            customerPhone,
            "⚠️ Complaint record ho gayi. 24 ghante mein review karein ge."
          );
        } else {
          await updateProviderScore(session.providerId, rating);
          await updateJobState(session.jobId, "CLOSED");
          await sendWhatsApp(
            customerPhone,
            `⭐ Shukriya! ${rating}/5 rating di gayi.\nUstaad.ai use karne ka shukriya!`
          );
        }
        await sessionRef.set({ step: "IDLE" });
      } else {
        await sendWhatsApp(customerPhone, "1 se 5 ke darmiyan number bhejein.");
      }
      res.status(200).send("OK");
      return;
    }

    // ── New service request ──
    console.log("🤖 Running Intent Agent...");
    const { runIntentAgent } = await import("./agents/intentAgent.js");
    const entities = await runIntentAgent(messageBody);
    await logAIResponse("pending", "intentAgent", { message: messageBody }, entities);

    // Fallback 2: low confidence
    if (!entities || entities.confidence < 0.5) {
      console.log("⚠️ Low confidence, running fallback...");
      const { runFallbackAgent } = await import("./agents/fallbackAgent.js");
      const fallback = runFallbackAgent("low_confidence");
      await sendWhatsApp(customerPhone, fallback.message);
      res.status(200).send("OK");
      return;
    }

    if (!entities.intent || entities.intent === "unknown") {
      await sendWhatsApp(
        customerPhone,
        "Kaunsi service chahiye? AC Repair, Plumbing, ya Electrician?"
      );
      res.status(200).send("OK");
      return;
    }

    if (!entities.location) {
      await sendWhatsApp(customerPhone, "Aapka area kya hai?");
      res.status(200).send("OK");
      return;
    }

    // ── WF2: Run matching + pricing ──
    const serviceMap: Record<string, string> = {
      AC_repair: "AC Repair",
      plumbing: "Plumbing",
      electrician: "Electrician",
    };
    const serviceName = serviceMap[entities.intent] || entities.intent;

    console.log(`🔍 Finding providers for: ${serviceName}`);
    const providers = await getProviders(serviceName);

    if (providers.length === 0) {
      const { runFallbackAgent } = await import("./agents/fallbackAgent.js");
      const fallback = runFallbackAgent("no_providers");
      await sendWhatsApp(customerPhone, fallback.message);
      res.status(200).send("OK");
      return;
    }

    const customerLat = 33.6938;
    const customerLng = 73.0652;

    const { runMatchingAgent } = await import("./agents/matchingAgent.js");
    const matchResult = runMatchingAgent(
      providers, { service: serviceName, subtype: entities.subtype },
      customerLat, customerLng
    );

    if (!matchResult.selected_provider) {
      const { runFallbackAgent } = await import("./agents/fallbackAgent.js");
      const fallback = runFallbackAgent("no_providers");
      await sendWhatsApp(customerPhone, fallback.message);
      res.status(200).send("OK");
      return;
    }

    // Write matching decision log to Firestore for traceability
    await db.collection("matching_logs").add({
      customerPhone,
      requestedService: serviceName,
      requestedSubtype: entities.subtype || null,
      ranking: matchResult.ranking,
      selectedProviderId: matchResult.selected_provider,
      reasoning: matchResult.reason,
      createdAt: FieldValue.serverTimestamp(),
    });

    const { runPricingAgent } = await import("./agents/pricingAgent.js");
    const pricing = runPricingAgent(
      matchResult.provider.distance,
      entities.urgency
    );

    await sessionRef.set({
      step: "AWAITING_CONFIRMATION",
      matchedProviderId: matchResult.selected_provider,
      entities: { ...entities, service: serviceName },
      quote: { min: pricing.min, max: pricing.max },
      aiLog: { matchResult, pricing },
    });

    console.log(`✅ Match found: ${matchResult.provider.name}. Sending quote...`);
    const explanation = `Ustaad-AI ne aap ke liye sab se behtareen provider select kiya hai kyunke yeh aap se sirf ${matchResult.provider.distance.toFixed(1)} km door hain aur inki rating zabardast (${matchResult.provider.rating}/5) hai.`;

    await sendWhatsApp(
      customerPhone,
      `👷 *${matchResult.provider.name}* available hain!\n\n` +
      `📊 *AI Recommendation Reasoning*:\n` +
      `• *Rating*: ⭐ ${matchResult.provider.rating}/5\n` +
      `• *Fasla*: 📍 ${matchResult.provider.distance.toFixed(1)} km\n` +
      `• *Estimated Cost*: Rs. ${pricing.final_range}\n\n` +
      `💬 *AI Explanation*: ${explanation}\n\n` +
      `Confirm karne ke liye *1* reply karein.\n` +
      `Cancel karne ke liye *2* reply karein.`
    );

    res.status(200).send("OK");
  }
);

// ─────────────────────────────────────────
// WF3: Provider accepts job (Flutter calls this)
// ─────────────────────────────────────────
export const acceptJob = functions.https.onRequest(async (req, res) => {
  try {
    const { jobId } = req.body;
    if (jobId && jobId.toString().startsWith("DEMO-")) {
      res.json({ success: true });
      return;
    }
    await updateJobState(jobId, "ACCEPTED");

    const jobSnap = await db.collection("jobs").doc(jobId).get();
    await sendWhatsApp(
      jobSnap.data()!.customerId,
      "✅ Provider ne kaam accept kar liya! Woh aa rahe hain."
    );

    await triggerWorkflow("JOB_ACCEPTED", { jobId });
    res.json({ success: true });
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

// ─────────────────────────────────────────
// WF4: Provider arrived (Flutter GPS ping)
// ─────────────────────────────────────────
export const providerArrived = functions.https.onRequest(async (req, res) => {
  try {
    const { jobId, latitude, longitude } = req.body;
    if (jobId && jobId.toString().startsWith("DEMO-")) {
      res.json({ success: true });
      return;
    }
    await updateJobState(jobId, "ARRIVED", {
      arrivedAt: FieldValue.serverTimestamp(),
      providerArrivalLocation: new GeoPoint(
        latitude, longitude
      ),
    });

    const jobSnap = await db.collection("jobs").doc(jobId).get();
    await sendWhatsApp(
      jobSnap.data()!.customerId,
      "🏠 Provider aapke ghar pohanch gaye!"
    );

    res.json({ success: true });
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

// ─────────────────────────────────────────
// WF4: Job completed (Flutter calls this)
// ─────────────────────────────────────────
export const completeJob = functions.https.onRequest(async (req, res) => {
  try {
    const { jobId, finalPrice, proofPhotoUrl } = req.body;
    if (jobId && jobId.toString().startsWith("DEMO-")) {
      res.json({ success: true });
      return;
    }

    await updateJobState(jobId, "COMPLETED", {
      finalPrice,
      proofPhotoUrl: proofPhotoUrl || null,
      completedAt: FieldValue.serverTimestamp(),
    });

    const jobSnap = await db.collection("jobs").doc(jobId).get();
    const job = jobSnap.data()!;

    await db.collection("providers").doc(job.providerId).update({
      activeJobId: null,
    });

    await sendWhatsApp(
      job.customerId,
      `✅ Kaam mukammal!\nFinal price: Rs. ${finalPrice}\n\n` +
      `Rating dein (1-5 reply karein):\n` +
      `1=Bura 2=Theek 3=Acha 4=Bohat Acha 5=Zabardast`
    );

    await db.collection("sessions").doc(job.customerId).set({
      step: "AWAITING_RATING",
      jobId,
      providerId: job.providerId,
    });

    await triggerWorkflow("JOB_COMPLETED", { jobId });
    res.json({ success: true });
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

// ─────────────────────────────────────────
// FALLBACK 1: Timeout checker
// Hit this endpoint every 5 mins manually
// ─────────────────────────────────────────
export const checkTimeouts = functions.https.onRequest(async (req, res) => {
  try {
    const { runFallbackAgent } = await import("./agents/fallbackAgent.js");
    const fiveMinutesAgo = new Date(Date.now() - 5 * 60 * 1000);

    const stuckJobs = await db
      .collection("jobs")
      .where("status", "==", "MATCHED")
      .where("assignedAt", "<", fiveMinutesAgo)
      .get();

    for (const jobDoc of stuckJobs.docs) {
      const job = jobDoc.data();

      await db.collection("providers").doc(job.providerId).update({
        reliabilityScore: FieldValue.increment(-5),
        activeJobId: null,
        isOnline: false,
      });

      if (job.assignmentAttempts >= 3) {
        await updateJobState(jobDoc.id, "FAILED");
        await sendWhatsApp(
          job.customerId,
          runFallbackAgent("no_providers").message
        );
        continue;
      }

      await updateJobState(jobDoc.id, "REASSIGNING", {
        providerId: null,
        assignmentAttempts:
          FieldValue.increment(1),
      });

      await sendWhatsApp(
        job.customerId,
        runFallbackAgent("timeout").message
      );
    }

    res.json({ checked: stuckJobs.size });
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

// ─────────────────────────────────────────
// Health check
// ─────────────────────────────────────────
export const health = functions.https.onRequest((req, res) => {
  res.json({ status: "✅ Ustaad.ai backend running!" });
});