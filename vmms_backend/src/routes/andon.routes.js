import express from "express";
import * as controller from "../controllers/andon.controller.js";

const router = express.Router();

router.get("/summary", controller.getSummary);
router.get("/transactions", controller.getTransactions);
router.get("/events", controller.getEvents);

export default router;
