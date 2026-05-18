import { GoogleGenerativeAI } from "@google/generative-ai";
import { config } from "../config";

const genAI = new GoogleGenerativeAI(config.gemini.apiKey);

export async function runSentimentAgent(feedback: string) {
  try {
    const model = genAI.getGenerativeModel({ model: "gemini-2.5-flash" });

    const prompt = `
      Analyze this customer feedback for a home services app.
      Feedback may be in Urdu, Roman Urdu, or English.
      Feedback: "${feedback}"
      
      Return ONLY valid JSON:
      {
        "sentiment": "positive" or "negative" or "neutral",
        "rating": number from 1 to 5,
        "flag_dispute": true or false
      }
    `;

    const result = await model.generateContent(prompt);
    const text = result.response.text().trim();
    const cleaned = text.replace(/```json|```/g, "").trim();
    return JSON.parse(cleaned);

  } catch (error: any) {
    console.error("Sentiment agent error:", error.message);
    return { sentiment: "neutral", rating: 3, flag_dispute: false };
  }
}