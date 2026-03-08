import express from "express";

import auth from "../middleware/auth.middleware.js";
import rbac from "../middleware/rbac.middleware.js";

// Route modules
import authRoutes from "./auth.routes.js";
import gateRoutes from "./gate.routes.js";
import syncRoutes from "./sync.routes.js";
import visitorRoutes from "./visitor.routes.js";
import labourRoutes from "./labour.routes.js";
import materialRoutes from "./material.routes.js";
import blacklistRoutes from "./blacklist.routes.js";
import analyticsRoutes from "./analytics.routes.js";
import reportRoutes from "./report.routes.js";
import adminRoutes from "./admin.routes.js";
import masterRoutes from "./master.routes.js"; // unified dropdown masters
import andonRoutes from "./andon.routes.js";

const router = express.Router();

/* =====================================================
   PUBLIC ROUTES (No Auth Required)
===================================================== */

// Authentication (login / token issuance)
router.use("/auth", authRoutes);

// Gate device operations (RFID readers / biometric devices)
router.use("/gate", gateRoutes);

// Sync queue endpoints for offline gate devices
router.use("/sync", syncRoutes);

// Dropdown masters (read-only)
router.use("/masters", masterRoutes);

// Public display (Andon)
router.use("/public/andon", andonRoutes);


/* =====================================================
   PROTECTED BUSINESS ROUTES (Auth Required)
===================================================== */

// Visitor Management
router.use("/visitors", auth, visitorRoutes);

// Labour + RFID Token + Manifest lifecycle
router.use("/labour", auth, labourRoutes);

// Material inward / outward tracking
router.use("/materials", auth, materialRoutes);

// Blacklist / banned persons
router.use("/blacklist", auth, blacklistRoutes);

// Analytics dashboards
router.use("/analytics", auth, analyticsRoutes);

// Reports & exports
router.use("/reports", auth, reportRoutes);


/* =====================================================
   ADMIN ROUTES (Role Based Access Control)
===================================================== */

router.use(
  "/admin",
  auth,
  rbac(["SUPER_ADMIN"]),
  adminRoutes
);

export default router;
