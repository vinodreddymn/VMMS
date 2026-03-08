import express from "express";
import * as controller from "../controllers/sync.controller.js";

const router = express.Router();

// Public sync endpoints (for gates - no auth required)

// Get master whitelist for offline mode
router.get("/whitelist", controller.getMasterWhitelist);

// Submit synced data from gates
router.post("/queue", controller.processSyncQueue);

// Get unsynced items
router.get("/queue", controller.getUnSyncedQueue);

// Mark items as synced
router.post("/mark-synced", controller.markSynced);

export default router;