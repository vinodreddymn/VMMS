import express from "express";
import cors from "cors";
import helmet from "helmet";

import routes from "./routes/index.js";
import errorMiddleware from "./middleware/error.middleware.js";
import logger from "./utils/logger.util.js";

// Initialize cron jobs
import { startNoShowCron } from "./cron/noShow.cron.js";
import { startMaterialBalanceCron } from "./cron/materialAlert.cron.js";

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
app.use("/uploads", express.static("uploads"));
app.use("/exports", express.static("exports"));

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
startNoShowCron();
startMaterialBalanceCron();

logger.info("Cron jobs initialized");

export default app;
