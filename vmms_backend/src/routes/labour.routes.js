import express from "express";
import * as controller from "../controllers/labour.controller.js";
import auth from "../middleware/auth.middleware.js";
import rbac from "../middleware/rbac.middleware.js";

const router = express.Router();

router.get("/", auth, controller.getAllLabours);

/* =====================================================
   LABOUR REGISTRATION
===================================================== */

// Register new labour + auto assign RFID token
router.post("/", auth, controller.createLabour);

// Get all labours under a supervisor
router.get("/supervisor/:id", auth, controller.getBySupervisor);

// Search available RFID tokens
router.get("/tokens/available", auth, controller.getAvailableTokens);

/* =====================================================
   MANIFEST MANAGEMENT
===================================================== */

// Create or reuse today's manifest
router.post("/manifests", auth, controller.createManifest);

// Get specific manifest with labours + tokens
router.get("/manifests/:manifest_id", auth, controller.getManifest);

// Update manifest (sign / approve)
router.put("/manifests/:manifest_id", auth, controller.updateManifest);

// Generate & stream PDF manifest
router.get("/manifests/:manifest_id/pdf", auth, controller.generateManifestPDF);

// Get today's manifest for supervisor
router.get(
  "/manifests/supervisor/:supervisor_id",
  auth,
  controller.getTodayManifestBySupervisor
);

// Get all today's manifests for supervisor
router.get(
  "/manifests/supervisor/:supervisor_id/all",
  auth,
  controller.getTodayManifestsBySupervisor
);
router.get(
  "/manifests/supervisor/:supervisor_id/history",
  auth,
  controller.getManifestHistoryBySupervisor
);

/* =====================================================
   LABOUR ANALYTICS
===================================================== */

router.get("/analytics", auth, controller.getLabourAnalytics);


/* =====================================================
   TOKEN RETURN / DEREGISTRATION
===================================================== */

// Token return / deregistration
router.post("/tokens/return", auth, controller.returnToken);

// Admin: force checkout stale labour
router.post("/tokens/force-checkout", auth, rbac(["SUPER_ADMIN", "SECURITY_HEAD"]), controller.forceCheckoutLabour);


/* =====================================================
   GATE VALIDATION (RFID SCAN SUPPORT)
   These APIs will be used by gate devices/scanners
===================================================== */

// Validate labour token for entry (manifest + active check)
router.get("/tokens/validate/:token_uid", auth, controller.validateTokenForGate);

// (Future) Checkout scan endpoint placeholder
// router.post("/tokens/checkout", auth, controller.checkoutLabour);


/* =====================================================
   LEGACY ROUTES (Backward Compatibility)
===================================================== */

router.post("/manifest", auth, controller.createManifest);
router.get("/manifest/:manifest_id", auth, controller.getManifest);
router.post("/manifest/:manifest_id/pdf", auth, controller.generateManifestPDF);


/* =====================================================
   NO-SHOW DETECTION (Scheduled / Manual Trigger)
===================================================== */

router.post("/check-noshows", auth, controller.checkNoShows);


export default router;
