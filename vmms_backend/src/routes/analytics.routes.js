import express from "express";
import * as controller from "../controllers/analytics.controller.js";
import rbac from "../middleware/rbac.middleware.js";

const router = express.Router();

// Live muster (two routes for compatibility)
router.get("/muster", rbac(["SECURITY_HEAD", "SUPER_ADMIN"]), controller.liveMuster);
router.get("/live-muster", rbac(["SECURITY_HEAD", "SUPER_ADMIN"]), controller.liveMuster);

// Daily statistics
router.get("/daily-stats", rbac(["SECURITY_HEAD", "SUPER_ADMIN"]), controller.getDailyStats);

// Peak hours and gate load
router.get("/peak-hours", rbac(["SECURITY_HEAD", "SUPER_ADMIN"]), controller.peakHours);
router.get("/gate-load", rbac(["SECURITY_HEAD", "SUPER_ADMIN"]), controller.gateLoad);
router.get("/gate-stats", rbac(["SECURITY_HEAD", "SUPER_ADMIN"]), controller.gateLoad);

// Project wise statistics
router.get("/project-stats", rbac(["SECURITY_HEAD", "SUPER_ADMIN"]), controller.getProjectStats);

// Visitor search (extensive filtering)
router.get(
  "/search",
  rbac(["ENROLLMENT_STAFF", "SECURITY_HEAD", "SUPER_ADMIN"]),
  controller.searchVisitors
);

// Failed access attempts
router.get("/failed-attempts", rbac(["SECURITY_HEAD", "SUPER_ADMIN"]), controller.getFailedAttempts);

// Blacklist incidents
router.get("/blacklist-incidents", rbac(["SECURITY_HEAD", "SUPER_ADMIN"]), controller.getBlacklistIncidents);

// Risk scoring and trends
router.get("/risk-scoring", rbac(["SECURITY_HEAD", "SUPER_ADMIN"]), controller.riskScoring);
router.get("/visitor-trends", rbac(["SECURITY_HEAD", "SUPER_ADMIN"]), controller.visitorTrends);

// Gate performance
router.get("/gate-performance", rbac(["SECURITY_HEAD", "SUPER_ADMIN"]), controller.getGatePerformance);

// Material analytics
router.get("/material-analytics", rbac(["SUPER_ADMIN"]), controller.getMaterialAnalytics);

// Labour analytics
router.get("/labour-analytics", rbac(["SECURITY_HEAD", "SUPER_ADMIN"]), controller.getLabourAnalytics);

// Access log transactions
router.get("/transactions", rbac(["SECURITY_HEAD", "SUPER_ADMIN"]), controller.getTransactions);
router.get("/transactions/export-csv", rbac(["SECURITY_HEAD", "SUPER_ADMIN"]), controller.exportTransactionsCsv);
router.get("/transactions/export-pdf", rbac(["SECURITY_HEAD", "SUPER_ADMIN"]), controller.exportTransactionsPdf);

export default router;
