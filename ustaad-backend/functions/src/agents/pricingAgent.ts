export function runPricingAgent(
  distance: number,
  urgency: string
) {
  try {
    const base = 1000;
    const distanceFee = Math.round(distance * 50);
    const surge = urgency === "urgent" ? 300 : 0;
    const finalMin = base + distanceFee;
    const finalMax = base + distanceFee + surge + 500;

    return {
      base,
      distance_fee: distanceFee,
      surge,
      final_range: `${finalMin}-${finalMax}`,
      min: finalMin,
      max: finalMax,
    };

  } catch (error) {
    // Fallback 3: flat rate
    console.warn("Pricing failed, using flat rate");
    return {
      base: 1000,
      distance_fee: 0,
      surge: 0,
      final_range: "1000-2000",
      min: 1000,
      max: 2000,
    };
  }
}