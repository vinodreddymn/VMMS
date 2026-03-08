import express from "express";
import * as controller from "../controllers/blacklist.controller.js";
import rbac from "../middleware/rbac.middleware.js";

const router = express.Router();

// Blacklist management (Security Head and Super Admin only)
router.get("/", rbac(["SECURITY_HEAD", "SUPER_ADMIN"]), controller.getBlacklist);
router.post("/", rbac(["SECURITY_HEAD", "SUPER_ADMIN"]), controller.addToBlacklist);
router.delete("/:id", rbac(["SUPER_ADMIN"]), controller.removeFromBlacklist);

// Check blacklist (for enrollment and gate operations)
router.post("/check", controller.checkBlacklist);

export default router;