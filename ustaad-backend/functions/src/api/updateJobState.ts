import { db, FieldValue } from "../admin";
import { isValidTransition, JobStatus } from "../utils/stateMachine";


export async function updateJobState(
  jobId: string,
  newStatus: JobStatus,
  additionalData: Record<string, any> = {}
) {
  const jobRef = db.collection("jobs").doc(jobId);
  const jobSnap = await jobRef.get();

  if (!jobSnap.exists) {
    throw new Error(`Job ${jobId} not found`);
  }

  const currentStatus = jobSnap.data()!.status as JobStatus;

  // Enforce state machine rules
  if (!isValidTransition(currentStatus, newStatus)) {
    throw new Error(
      `Invalid transition: ${currentStatus} → ${newStatus}`
    );
  }

  await jobRef.update({
    status: newStatus,
    ...additionalData,
    stateHistory: FieldValue.arrayUnion(newStatus),
    updatedAt: FieldValue.serverTimestamp(),
  });

  console.log(`✅ Job ${jobId}: ${currentStatus} → ${newStatus}`);
  return true;
}