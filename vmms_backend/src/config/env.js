import dotenv from "dotenv";

dotenv.config();

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
};

export default env;
