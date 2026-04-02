import express from "express";
import cors from "cors";
import helmet from "helmet";
import path from "path";

import routes from "./routes/index.js";
import errorMiddleware from "./middleware/error.middleware.js";
import logger from "./utils/logger.util.js";
import env from "./config/env.js";

// Initialize cron jobs

import { startAlertCron } from "./cron/noShow.cron.js";
import { startMaterialBalanceCron } from "./cron/materialAlert.cron.js";
import startSoftlockCron from "./cron/softlock.cron.js";

const app = express();

/* ---------- Global Middleware ---------- */
app.use(cors());
app.use(
  helmet({
    crossOriginResourcePolicy: false,
  })
);
app.use(express.json({ limit: "50mb" }));
app.use(express.urlencoded({ limit: "50mb", extended: true }));

/* ---------- Static File Serving ---------- */
const uploadsStaticDir = env.paths?.uploadsDir || path.resolve("uploads");
const exportsStaticDir = env.paths?.exportsDir || path.resolve("exports");
const uploadsMountPath = env.paths?.uploadsMountPath || "/uploads";
const exportsMountPath = env.paths?.exportsMountPath || "/exports";

app.use(uploadsMountPath, express.static(uploadsStaticDir));
app.use(exportsMountPath, express.static(exportsStaticDir));

/* ---------- API Routes ---------- */
app.use("/api", routes);

/* ---------- Health Check ---------- */
app.get("/health", (req, res) => {
  res.json({
    success: true,
    message: "VMMS Backend is running",
    timestamp: new Date().toISOString(),
  });
});

/* ---------- Error Handler ---------- */
app.use(errorMiddleware);

/* ---------- Start Scheduled Jobs ---------- */
startAlertCron();
startMaterialBalanceCron();
await startSoftlockCron();

logger.info("Cron jobs initialized");

export default app;
