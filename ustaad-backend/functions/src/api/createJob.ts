import { db, FieldValue } from "../admin";


export async function createJob(data: {
  customerId: string;
  service: string;
  subtype: string | null;
  location: string;
  urgency: string;
  aiDecisionLog: any;
}) {
  const jobRef = await db.collection("jobs").add({
    ...data,
    status: "CREATED",
    providerId: null,
    quotedPrice: null,
    finalPrice: null,
    proofPhotoUrl: null,
    rating: null,
    disputeReason: null,
    payoutHeld: false,
    assignmentAttempts: 0,
    stateHistory: ["CREATED"],
    aiDecisionLog: [data.aiDecisionLog],
    createdAt: FieldValue.serverTimestamp(),
  });

  console.log(`✅ Job created: ${jobRef.id}`);
  return jobRef.id;
}