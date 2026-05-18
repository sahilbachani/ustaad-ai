import * as dotenv from "dotenv";
import * as path from "path";

// Load from local directory first
dotenv.config();

// Fallback to parent directory where .env is located
dotenv.config({ path: path.join(__dirname, "../../.env") });
dotenv.config({ path: path.join(process.cwd(), "../.env") });

export const config = {
  twilio: {
    accountSid: process.env.TWILIO_ACCOUNT_SID || "",
    authToken: process.env.TWILIO_AUTH_TOKEN || "",
    whatsappNumber: process.env.TWILIO_WHATSAPP_NUMBER || "",
  },
  gemini: {
    apiKey: process.env.GEMINI_API_KEY || "",
  },
  cloudinary: {
    cloudName: process.env.CLOUDINARY_CLOUD_NAME || "",
    uploadPreset: process.env.CLOUDINARY_UPLOAD_PRESET || "",
  },
};