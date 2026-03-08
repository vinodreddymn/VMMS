import cron from "node-cron";
import softlockService from "../services/softlock.service.js";

/**
 * CRON: Daily Soft Lock Execution
 * Runs every day at 01:00 AM
 */
export default function startSoftlockCron() {
  cron.schedule("0 1 * * *", async () => {
    try {
      console.log("Running Soft Lock Cron");
      await softlockService.run();
    } catch (error) {
      console.error("Softlock cron error:", error);
    }
  });
}