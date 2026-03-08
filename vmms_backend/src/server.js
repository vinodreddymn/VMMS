import http from "http";
import app from "./app.js";
import env from "./config/env.js";
import logger from "./utils/logger.util.js";
import db from "./config/db.js";
import initSocket from "./sockets/realtime.socket.js";
import { startGateHealthWatcher } from "./services/gateHealthWatcher.service.js";
import runMigrations from "./utils/migration.util.js";

const server = http.createServer(app);
startGateHealthWatcher();

// Initialize WebSocket
initSocket(server);

// Start server
const PORT = env.port || 5000;

server.listen(PORT, "0.0.0.0", async () => {
  logger.info(`🚀 VMMS Backend Server running on port ${PORT}`);
  logger.info(`Environment: ${env.nodeEnv}`);

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