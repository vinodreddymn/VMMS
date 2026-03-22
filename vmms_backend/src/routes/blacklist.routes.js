import express from "express";
import * as controller from "../controllers/blacklist.controller.js";
import rbac from "../middleware/rbac.middleware.js";

const router = express.Router();

// =====================================================
// BLACKLIST MANAGEMENT ROUTES
// =====================================================

// Get all blacklist entries
router.get(
  "/",
  rbac(["SECURITY_HEAD", "SUPER_ADMIN"]),
  controller.getBlacklist
);

// Add a new blacklist entry
router.post(
  "/",
  rbac(["SECURITY_HEAD", "SUPER_ADMIN"]),
  controller.addToBlacklist
);

// Check blacklist (used in enrollment / gate scan)
// ⚠️ Keep this ABOVE /:id to avoid conflicts
router.post("/check", controller.checkBlacklist);

// Remove blacklist entry (Super Admin only)
router.delete(
  "/:id",
  rbac(["SUPER_ADMIN"]),
  controller.removeFromBlacklist
);

export default router;