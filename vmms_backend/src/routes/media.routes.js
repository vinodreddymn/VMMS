import express from "express";
import { listMediaPublic } from "../controllers/media.controller.js";

const router = express.Router();

// Public media listing for gate display / marketing screens
router.get("/", listMediaPublic);

export default router;
