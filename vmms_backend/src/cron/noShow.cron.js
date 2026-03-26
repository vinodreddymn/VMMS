import cron from "node-cron";
import * as labourRepo from "../repositories/labour.repo.js";
import smsService from "../services/sms.service.js";
import logger from "../utils/logger.util.js";
import db from "../config/db.js";

/**
 * CRON: Check Alerts
 * Runs every 5 minutes
 * 1. No-Show (not checked-in within 5 mins)
 * 2. Token not returned (5 mins after checkout)
 */
export function startAlertCron() {
  // ✅ Run every 5 minutes (NOT every 1 minute)
  cron.schedule("*/1 * * * *", async () => {
    try {
      logger.info("Running alert detection cron...");

      const buildManifestNumber = (manifest_date, daily_sequence, manifest_id) => {
        if (!manifest_date) return manifest_id;
        const dateObj = new Date(manifest_date);
        const datePart = Number.isNaN(dateObj.getTime())
          ? String(manifest_date).replace(/-/g, "").slice(0, 8)
          : dateObj.toISOString().slice(0, 10).replace(/-/g, "");
        const seq = daily_sequence ?? manifest_id;
        return `MF-${datePart}-${String(seq || 0).padStart(3, "0")}`;
      };

      const formatCreatedAt = (dateLike) =>
        new Date(dateLike).toLocaleString("en-IN", {
          day: "2-digit",
          month: "short",
          year: "numeric",
          hour: "2-digit",
          minute: "2-digit",
          hour12: true,
        });

      // =====================================
      // 🔴 1. NO-SHOW ALERTS (5 MIN RULE)
      // =====================================
      const noShows = await labourRepo.getNoShowLabours();

      logger.info(`No-show count: ${noShows.length}`);

      for (const row of noShows) {
        try {
          const {
            labour_id,
            labour_name,
            supervisor_id,
            supervisor_name,
            company,
            manifest_id,
            manifest_date,
            daily_sequence,
            printed_at,
            host_id,
          } = row;

          const manifestNumber = buildManifestNumber(manifest_date, daily_sequence, manifest_id);

          // ✅ Fetch host using host_id (not supervisor_id)
          const hostRes = await db.query(
            `SELECT id, host_name, phone 
             FROM hosts 
             WHERE id = $1 AND is_active = true`,
            [host_id]
          );

          const host = hostRes.rows[0];
          if (!host?.phone) continue;

          // ✅ Mark FIRST to avoid duplicates
          await labourRepo.markNoShowAlertSent(labour_id);

          // ✅ Send SMS
          await smsService.sendNoShowAlertSMS(host.phone, {
            labour_name,
            supervisor_name,
            company,
            manifest_id,
            manifest_number: manifestNumber,
            printed_at: formatCreatedAt(printed_at),
            host_name: host.host_name
          });

          logger.warn(
            `No-show alert sent → Labour: ${labour_name}, Host: ${host.host_name}`
          );
        } catch (err) {
          logger.error("No-show processing error:", err);
        }
      }

      // =====================================
      // 🔴 2. TOKEN NOT RETURNED ALERTS (5 MIN RULE)
      // =====================================
      const pendingReturns =
        await labourRepo.getUnreturnedTokensAfterCheckout();

      logger.info(`Token return alert count: ${pendingReturns.length}`);

      for (const row of pendingReturns) {
        try {
          const {
            labour_id,
            labour_name,
            supervisor_id,
            supervisor_name,
            company,
            manifest_id,
            manifest_date,
            daily_sequence,
            token_uid,
            last_out_time,
            host_id,
          } = row;

          const manifestNumber = buildManifestNumber(manifest_date, daily_sequence, manifest_id);

          // ✅ Fetch host using host_id (not supervisor_id)
          const hostRes = await db.query(
            `SELECT id, host_name, phone 
             FROM hosts 
             WHERE id = $1 AND is_active = true`,
            [host_id]
          );

          const host = hostRes.rows[0];
          if (!host?.phone) continue;

          // ✅ Mark FIRST to avoid duplicates
          await labourRepo.markReturnAlertSent(labour_id);

          // ✅ Send SMS
          await smsService.sendTokenNotReturnedAlertSMS(host.phone, {
            labour_name,
            supervisor_name,
            company,
            token_uid,
            last_out_time: formatCreatedAt(last_out_time),
            host_name: host.host_name,
            manifest_number: manifestNumber
          });

          logger.warn(
            `Token NOT returned alert → Labour: ${labour_name}, Host: ${host.host_name}`
          );
        } catch (err) {
          logger.error("Token return alert error:", err);
        }
      }
    } catch (error) {
      logger.error("Alert cron error:", error);
    }
  });

  logger.info("Alert detection cron scheduled (every 5 mins)");
}
