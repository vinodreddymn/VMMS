import express from "express";
import * as controller from "../controllers/gate.controller.js";
import auth from "../middleware/auth.middleware.js";

const router = express.Router();

// Zero-input authentication (no auth required for gates)
router.post("/authenticate", controller.authenticate);
router.post("/authenticate-labour", controller.authenticateLabour);

// Gate health monitoring
router.post("/health", auth, controller.updateGateHealth);
router.get("/health", auth, controller.getAllGateHealth);
router.get("/health/:gate_id", auth, controller.getGateHealth);

// Live muster & logs
router.get("/muster", auth, controller.getLiveMuster);
router.get("/logs", auth, controller.getAccessLogs);

// Manual gate entry
router.post("/manual-entry", auth, controller.manualEntry);

// Search person
router.get("/search", auth, controller.searchPerson);

// Photo capture
router.post("/save-access-log", controller.saveAccessLog);

export default router;