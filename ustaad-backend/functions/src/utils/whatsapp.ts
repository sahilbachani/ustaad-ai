import twilio from "twilio";
import { config } from "../config";

// Lazy initialization — only creates client when actually needed
let client: twilio.Twilio | null = null;

function getClient() {
  if (!client) {
    client = twilio(
      config.twilio.accountSid,
      config.twilio.authToken
    );
  }
  return client;
}

export async function sendWhatsApp(
  to: string,
  message: string
): Promise<void> {
  try {
    await getClient().messages.create({
      from: config.twilio.whatsappNumber,
      to: `whatsapp:${to}`,
      body: message,
    });
    console.log(`✅ WhatsApp sent to ${to}`);
  } catch (error: any) {
    console.error(`❌ WhatsApp failed to ${to}:`, error.message);
  }
}