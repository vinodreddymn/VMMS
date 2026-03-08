import cron from "node-cron";
import db from "../config/db.js";

/**
 * CRON: Monthly Partition Creation for access_logs
 * Runs at 00:00 on the 1st day of every month
 */
export default function startPartitionCron() {
  cron.schedule("0 0 1 * *", async () => {
    try {
      const now = new Date();
      const year = now.getFullYear();
      const month = String(now.getMonth() + 2).padStart(2, "0");

      const tableName = `access_logs_${year}_${month}`;

      await db.query(`
        CREATE TABLE IF NOT EXISTS ${tableName}
        PARTITION OF access_logs
        FOR VALUES FROM ('${year}-${month}-01')
        TO ('${year}-${month}-31');
      `);

      console.log("Partition Created:", tableName);
    } catch (error) {
      console.error("Partition cron error:", error);
    }
  });
}