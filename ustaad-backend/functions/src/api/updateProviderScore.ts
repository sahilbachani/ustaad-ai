import { db, FieldValue } from "../admin";

export async function updateProviderScore(
  providerId: string,
  newRating: number
) {
  const providerRef = db.collection("providers").doc(providerId);
  const snap = await providerRef.get();

  if (!snap.exists) throw new Error(`Provider ${providerId} not found`);

  const provider = snap.data()!;
  const totalJobs = provider.totalJobs || 1;
  const oldRating = provider.rating || 0;

  // Recalculate average
  const updatedRating =
    (oldRating * totalJobs + newRating) / (totalJobs + 1);

  await providerRef.update({
    rating: Math.round(updatedRating * 10) / 10,
    totalJobs: FieldValue.increment(1),
  });

  console.log(`✅ Provider ${providerId} rating → ${updatedRating}`);
  return updatedRating;
}