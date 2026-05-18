import { GoogleGenerativeAI } from "@google/generative-ai";
import { config } from "../config";

const genAI = new GoogleGenerativeAI(config.gemini.apiKey);

export async function runIntentAgent(message: string) {
  try {
    const model = genAI.getGenerativeModel({ model: "gemini-2.5-flash" });

    const prompt = `
      You are an intent extraction agent for a Pakistani home services app.
      Message may be in Urdu, Roman Urdu, English, or mixed.
      
      Message: "${message}"
      
      Return ONLY valid JSON, no markdown, no extra text:
      {
        "intent": "AC_repair" or "plumbing" or "electrician" or "unknown",
        "language": "roman_urdu" or "urdu" or "english" or "mixed",
        "location": area name or null,
        "subtype": specific subtype or null,
        "urgency": "normal" or "urgent",
        "confidence": number between 0 and 1,
        "missing_fields": array of missing fields
      }
    `;

    const result = await model.generateContent(prompt);
    const text = result.response.text().trim();
    const cleaned = text.replace(/```json|```/g, "").trim();
    return JSON.parse(cleaned);

  } catch (error: any) {
    console.error("Intent agent error:", error.message);
    return {
      intent: "unknown",
      confidence: 0,
      missing_fields: ["service", "location"],
    };
  }
}