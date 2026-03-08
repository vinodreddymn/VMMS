import cron from "node-cron";
import db from "../config/db.js";
import * as socket from "../sockets/realtime.socket.js";

/**
 * CRON: Realtime Analytics Broadcast
 * Runs every 30 seconds to push peak-hour stats to dashboard via WebSocket
 */
export default function startRealtimeAnalyticsCron() {
  cron.schedule("*/30 * * * * *", async () => {
    try {
      const peak = await db.query(`
        SELECT date_part('hour', scan_time) as hour,
        COUNT(*) as total
        FROM access_logs
        GROUP BY hour
      `);

      socket.emitEvent("ANALYTICS_UPDATE", {
        peakHours: peak.rows,
      });
    } catch (error) {
      console.error("Realtime analytics cron error:", error);
    }
  });
}