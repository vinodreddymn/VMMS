import express from "express";
import * as controller from "../controllers/material.controller.js";
import auth from "../middleware/auth.middleware.js";
import rbac from "../middleware/rbac.middleware.js";

const router = express.Router();

// Material master data
router.post("/", auth, rbac(["SUPER_ADMIN"]), controller.createMaterial);
router.get("/", auth, controller.getMaterials);

// Material transactions
router.post("/transaction", auth, controller.transaction);
router.get("/balance/:visitorId", auth, controller.balance);

// Pending returns (for alerts)
router.get(
  "/pending-returns",
  auth,
  rbac(["SECURITY_HEAD", "SUPER_ADMIN"]),
  controller.getPendingReturns
);

export default router;