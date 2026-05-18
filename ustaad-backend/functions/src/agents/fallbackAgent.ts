export function runFallbackAgent(reason: string) {
  const fallbackMessages: Record<string, string> = {
    low_confidence:
      "Samajh nahi aaya. Maslan likhein: 'AC repair chahiye G-13 mein'",
    no_providers:
      "Afsos, abhi koi provider available nahi. Thodi der baad try karein.",
    api_failure:
      "System mein thori takleef hai. Baad mein try karein.",
    timeout:
      "Provider available nahi tha. Hum doosra dhundh rahe hain...",
  };

  return {
    action: "FALLBACK_FLOW",
    reason,
    message: fallbackMessages[reason] || fallbackMessages["api_failure"],
  };
}