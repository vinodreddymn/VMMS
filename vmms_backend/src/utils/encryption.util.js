import crypto from "crypto";
const ENCRYPTION_KEY = process.env.ENCRYPTION_KEY || "your-256-bit-key-here-do-not-use-in-prod";
const ALGORITHM = "aes-256-cbc";

// Ensure key is 32 bytes for AES-256
const key = crypto.createHash("sha256").update(ENCRYPTION_KEY).digest();

export const encryptAadhaar = (aadhaar) => {
  const iv = crypto.randomBytes(16);
  const cipher = crypto.createCipheriv(ALGORITHM, key, iv);
  let encrypted = cipher.update(aadhaar, "utf8", "hex");
  encrypted += cipher.final("hex");
  return iv.toString("hex") + ":" + encrypted;
};

export const decryptAadhaar = (encryptedData) => {
  const [iv, encrypted] = encryptedData.split(":");
  const decipher = crypto.createDecipheriv(ALGORITHM, key, Buffer.from(iv, "hex"));
  let decrypted = decipher.update(encrypted, "hex", "utf8");
  decrypted += decipher.final("utf8");
  return decrypted;
};

export const hashBiometric = (biometricData) => {
  return crypto.createHash("sha256").update(biometricData).digest("hex");
};

export const hashAadhaarForBlacklist = (aadhaar) => {
  return crypto.createHash("sha256").update(aadhaar).digest("hex");
};

export const generatePassNumber = () => {
  return "PASS" + Date.now() + Math.random().toString(36).substr(2, 9).toUpperCase();
};
