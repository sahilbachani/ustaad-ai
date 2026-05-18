import { calculateDistance } from "../utils/geo";

export function runMatchingAgent(
  providers: any[],
  entities: any,
  customerLat: number,
  customerLng: number
) {
  // Filter available providers
  const available = providers.filter(
    (p) => p.isOnline && !p.activeJobId &&
      p.skills?.includes(entities.service)
  );

  if (available.length === 0) {
    return { selected_provider: null, ranking: [], reason: "no_providers" };
  }

  // Score using 6 factors
  const scored = available.map((p) => {
    const distance = calculateDistance(
      customerLat, customerLng,
      p.location.latitude, p.location.longitude
    );

    const score =
      Math.max(0, 1 - distance / 20) * 0.30 +
      (p.skillSubtypes?.includes(entities.subtype) ? 1 : 0.5) * 0.20 +
      (p.rating / 5) * 0.20 +
      (p.reliabilityScore / 100) * 0.15 +
      (1 - p.cancellationRate / 100) * 0.10 +
      (!p.activeJobId ? 1 : 0) * 0.05;

    return { ...p, distance, score };
  });

  scored.sort((a, b) => b.score - a.score);
  const best = scored[0];

  return {
    selected_provider: best.id,
    ranking: scored.map((p) => ({ id: p.id, score: p.score })),
    reason: `closest + high rating + low workload`,
    provider: best,
  };
}