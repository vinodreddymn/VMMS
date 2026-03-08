import express from "express";
import * as controller from "../controllers/auth.controller.js";
import auth from "../middleware/auth.middleware.js";

const router = express.Router();

router.post("/login", controller.login);
router.get("/me", auth, controller.me);
router.post("/change-password", auth, controller.changePassword);

export default router;
