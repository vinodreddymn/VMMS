import dotenv from "dotenv";
import path from "path";

dotenv.config();

const resolvePath = (value, fallback) => {
  const candidate = (value || "").toString().trim();
  if (!candidate) return path.resolve(fallback);
  return path.isAbsolute(candidate) ? candidate : path.resolve(candidate);
};

const normalizeSegment = (value, fallback) => {
  const clean = (value || fallback || "").toString().trim();
  return clean.replace(/^\/+/, "").replace(/\/+$/, "") || fallback;
};

const normalizeMountPath = (segment) => {
  if (!segment) return "/";
  return segment.startsWith("/") ? segment : `/${segment}`;
};

const uploadsDir = resolvePath(process.env.UPLOAD_PATH, "./uploads");
const exportsDir = resolvePath(process.env.EXPORT_PATH, "./exports");
const uploadsUrlSegment = normalizeSegment(process.env.UPLOAD_URL_PATH, "uploads");
const exportsUrlSegment = normalizeSegment(process.env.EXPORT_URL_PATH, "exports");

const env = {
  port: process.env.PORT || 5000,
  nodeEnv: process.env.NODE_ENV || "development",
  jwtSecret: process.env.JWT_SECRET,
  useHttps: String(process.env.USE_HTTPS || "").toLowerCase() === "true",
  sslKeyPath: process.env.SSL_KEY_PATH,
  sslCertPath: process.env.SSL_CERT_PATH,
  sslPfxPath: process.env.SSL_PFX_PATH,
  sslPfxPassphrase: process.env.SSL_PFX_PASSPHRASE,

  smsServiceEnabled: process.env.SMS_SERVICE_ENABLED === "true",

  db: {
    host: process.env.DB_HOST,
    port: process.env.DB_PORT,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
  },

  redis: {
    host: process.env.REDIS_HOST,
    port: process.env.REDIS_PORT,
  },

  paths: {
    uploadsDir,
    exportsDir,
    uploadsUrlSegment,
    exportsUrlSegment,
    uploadsMountPath: normalizeMountPath(uploadsUrlSegment),
    exportsMountPath: normalizeMountPath(exportsUrlSegment),
  },
};

export default env;
