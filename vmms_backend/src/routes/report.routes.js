import express from "express";
import * as controller from "../controllers/report.controller.js";
import rbac from "../middleware/rbac.middleware.js";

const router = express.Router();

// Live muster report
router.get("/live-muster", rbac(["SECURITY_HEAD", "SUPER_ADMIN"]), controller.liveMuster);

// PDF exports (role-based)
router.get("/export-pdf", rbac(["SECURITY_HEAD", "SUPER_ADMIN"]), controller.exportPDF);

// Excel exports (SUPER_ADMIN only)
router.get("/export-excel", rbac(["SUPER_ADMIN"]), controller.exportExcel);

export default router;