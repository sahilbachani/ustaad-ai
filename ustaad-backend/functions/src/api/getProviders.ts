import { db, Query } from "../admin";


export async function getProviders(
  skill: string,
  onlineOnly: boolean = true
) {
  let query: Query = db.collection("providers");

  if (onlineOnly) {
    query = query.where("isOnline", "==", true);
  }

  const snapshot = await query.get();

  const providers = snapshot.docs
    .map((doc) => ({ id: doc.id, ...doc.data() }))
    .filter((p: any) => p.skills?.includes(skill) && !p.activeJobId);

  console.log(`✅ Found ${providers.length} providers for ${skill}`);
  return providers;
}