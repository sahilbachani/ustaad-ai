import { db, FieldValue } from "../admin";

export async function logAIResponse(
  jobId: string,
  agentName: string,
  input: any,
  output: any
) {
  // Log to job document only if jobId is valid and not "pending"
  if (jobId && jobId !== "pending") {
    try {
      await db.collection("jobs").doc(jobId).update({
        aiDecisionLog: FieldValue.arrayUnion({
          agent: agentName,
          input,
          output,
          timestamp: new Date().toISOString(),
        }),
      });
    } catch (e: any) {
      console.warn(`⚠️ Could not update job doc ${jobId} with AI log: ${e.message}`);
    }
  }

  // Also log to separate collection for audit
  await db.collection("ai_logs").add({
    jobId,
    agent: agentName,
    input,
    output,
    createdAt: FieldValue.serverTimestamp(),
  });

  console.log(`✅ AI log saved: ${agentName} for job ${jobId}`);
}