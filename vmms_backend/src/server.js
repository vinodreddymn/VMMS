import http from "http";
import https from "https";
import fs from "fs";
import path from "path";
import app from "./app.js";
import env from "./config/env.js";
import logger from "./utils/logger.util.js";
import db from "./config/db.js";
import initSocket from "./sockets/realtime.socket.js";
import { startGateHealthWatcher } from "./services/gateHealthWatcher.service.js";
import runMigrations from "./utils/migration.util.js";
import SerialSMSService from "./services/serialSms.service.js";

// -----------------------------------------------------
// HTTP / HTTPS SERVER SETUP
// -----------------------------------------------------
let server;
let httpsActive = false;

if (env.useHttps) {
  try {
    const keyPath = env.sslKeyPath || path.resolve("assets/certs/server.key");
    const certPath = env.sslCertPath || path.resolve("assets/certs/server.crt");
    const pfxPath = env.sslPfxPath || path.resolve("assets/certs/server.pfx");

    let options = {};

    if (fs.existsSync(keyPath) && fs.existsSync(certPath)) {
      options = {
        key: fs.readFileSync(keyPath),
        cert: fs.readFileSync(certPath),
      };
      logger.info(`🔒 HTTPS using key/cert (key: ${keyPath}, cert: ${certPath})`);
    } else if (fs.existsSync(pfxPath)) {
      options = {
        pfx: fs.readFileSync(pfxPath),
        passphrase: env.sslPfxPassphrase || undefined,
      };
      logger.info(`🔒 HTTPS using PFX bundle (${pfxPath})`);
    } else {
      throw new Error("No SSL certificate files found");
    }

    server = https.createServer(options, app);
    httpsActive = true;
  } catch (err) {
    logger.error("Failed to initialize HTTPS server. Falling back to HTTP.", err);
    server = http.createServer(app);
  }
} else {
  server = http.createServer(app);
}

startGateHealthWatcher();


let smsWorkerRunning = false;

if (env.smsServiceEnabled) {
  logger.info("📡 SMS Service is ENABLED");

  setInterval(async () => {
    if (smsWorkerRunning) return; // prevent overlap

    smsWorkerRunning = true;

    try {
      await SerialSMSService.processPending(20);
    } catch (err) {
      logger.error("SMS worker error:", err);
    } finally {
      smsWorkerRunning = false;
    }
  }, 5000);
}

// Initialize WebSocket
initSocket(server);

// Start server
const PORT = env.port || 5000;

server.listen(PORT, "0.0.0.0", async () => {
  logger.info(`🚀 VMMS Backend Server running on ${httpsActive ? "HTTPS" : "HTTP"} port ${PORT}`);
  logger.info(`Environment: ${env.nodeEnv}`);
  if (env.smsServiceEnabled) {
    logger.info("📨 SMS Queue Processor started");
  }

  // Test database connection
  try {
    await db.query("SELECT NOW()");
    logger.info("📊 PostgreSQL connected successfully");
    
    // Run migrations (disabled - use 'npm run migrate' to run manually)
    // try {
    //   await runMigrations();
    // } catch (migrationError) {
    //   logger.warn("Some migrations failed, but continuing (DB may already be initialized)");
    // }
  } catch (error) {
    logger.error("❌ Database connection failed:", error);
    process.exit(1);
  }
});

// Graceful shutdown
process.on("SIGTERM", () => {
  logger.info("SIGTERM signal received: closing HTTP server");
  server.close(() => {
    logger.info("HTTP server closed");
    process.exit(0);
  });
});

process.on("SIGINT", () => {
  logger.info("SIGINT signal received: closing HTTP server");
  server.close(() => {
    logger.info("HTTP server closed");
    process.exit(0);
  });
});

export default server;
