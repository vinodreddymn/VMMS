import cron from "node-cron";
import * as materialRepo from "../repositories/material.repo.js";
import smsService from "../services/sms.service.js";
import logger from "../utils/logger.util.js";

/**
 * CRON: Material Balance Alert on Exit
 * Runs periodically to check for pending material returns
 */
export function startMaterialBalanceCron() {
  // Every 30 minutes
  cron.schedule("0 */30 * * * *", async () => {
    try {
      logger.info("Checking for pending material returns...");

      const pendingReturns = await materialRepo.getPendingReturns();

      for (const pending of pendingReturns) {
        // Reminder logging (SMS already triggered on exit)
        logger.warn(
          `Pending material return: Visitor ${pending.full_name} has not returned material ${pending.material_id}`
        );

        // Optional reminder SMS (if required later)
        // await smsService.sendReminder(pending.primary_phone, pending.material_id);
      }
    } catch (error) {
      logger.error("Material balance cron error:", error);
    }
  });

  logger.info("Material balance check cron scheduled");
}