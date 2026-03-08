import cron from "node-cron";
import * as labourRepo from "../repositories/labour.repo.js";
import * as visitorRepo from "../repositories/visitor.repo.js";
import smsService from "../services/sms.service.js";
import logger from "../utils/logger.util.js";
import db from "../config/db.js";

/**
 * CRON: Check for Labour No-Shows
 * Runs every 10 minutes
 * Triggers SMS alert if registered labour has not entered within 60 mins of manifest printing
 */
export function startNoShowCron() {
  // Every 10 minutes
  cron.schedule("*/10 * * * *", async () => {
    try {
      logger.info("Running no-show detection cron...");

      const noShows = await labourRepo.checkNoShows();

      for (const noShow of noShows) {
        const labour = await labourRepo.getLabourById(noShow.labour_id);
        const supervisor = await visitorRepo.findById(noShow.supervisor_id);

        if (supervisor && supervisor.host_id) {
          const host = await db.query(
            "SELECT * FROM hosts WHERE id = $1",
            [supervisor.host_id]
          );

          if (host.rows.length > 0) {
            await smsService.sendNoShowAlertSMS(
              host.rows[0].phone,
              labour.full_name
            );

            logger.warn(
              `No-show alert sent for labour ${labour.full_name} under supervisor ${supervisor.full_name}`
            );
          }
        }
      }
    } catch (error) {
      logger.error("No-show cron error:", error);
    }
  });

  logger.info("No-show detection cron scheduled");
}