import db from "../config/db.js";
import logger from "../utils/logger.util.js";

const OFFLINE_THRESHOLD_SEC = 30;
const WATCH_INTERVAL_MS = 10000;

/**
 * Check if heartbeat expired
 */
const isHeartbeatExpired = (lastHeartbeat) => {
  if (!lastHeartbeat) return true;
  const diffSec =
    (Date.now() - new Date(lastHeartbeat).getTime()) / 1000;
  return diffSec > OFFLINE_THRESHOLD_SEC;
};

/**
 * Insert missing gate_health rows for newly added gates
 */
const ensureGateHealthRows = async () => {
  const { rows } = await db.query(`
    INSERT INTO gate_health (gate_id, is_online)
    SELECT g.id, FALSE
    FROM gates g
    LEFT JOIN gate_health gh ON gh.gate_id = g.id
    WHERE gh.gate_id IS NULL AND g.is_active = TRUE
    RETURNING gate_id
  `);

  if (rows.length > 0) {
    logger.info(
      `Initialized health rows for new gates: ${rows
        .map((r) => r.gate_id)
        .join(", ")}`
    );
  }
};

/**
 * Clear stale metrics and mark offline
 */
const markGateOffline = async (gateId) => {
  await db.query(
    `
    UPDATE gate_health
    SET
      is_online = FALSE,
      cpu_usage = NULL,
      memory_usage = NULL,
      storage_usage = NULL,
      camera_status = NULL,
      rfid_status = NULL,
      biometric_status = NULL,
      updated_at = NOW()
    WHERE gate_id = $1
    `,
    [gateId]
  );

  await db.query(
    `
    INSERT INTO gate_health_logs (
      gate_id,
      cpu_usage,
      memory_usage,
      storage_usage,
      camera_status,
      rfid_status,
      biometric_status
    )
    VALUES ($1, NULL, NULL, NULL, NULL, NULL, NULL)
    `,
    [gateId]
  );

  logger.warn(`Gate ${gateId} marked OFFLINE (heartbeat timeout)`);
};

/**
 * Main watcher loop
 */
export const startGateHealthWatcher = () => {
  logger.info("Gate Health Watcher Started");

  setInterval(async () => {
    try {
      // 1️⃣ Ensure newly added gates are tracked
      await ensureGateHealthRows();

      // 2️⃣ Fetch all health rows
      const { rows } = await db.query(`
        SELECT
          gate_id,
          last_heartbeat,
          is_online,
          cpu_usage,
          memory_usage,
          storage_usage,
          camera_status,
          rfid_status,
          biometric_status
        FROM gate_health
      `);

      // 3️⃣ Check heartbeat expiration
      for (const row of rows) {
        const { gate_id, last_heartbeat, is_online } = row;

        if (!isHeartbeatExpired(last_heartbeat)) continue;

        // Skip if already offline and metrics already cleared
        const alreadyClean =
          is_online === false &&
          row.cpu_usage === null &&
          row.memory_usage === null &&
          row.storage_usage === null &&
          row.camera_status === null &&
          row.rfid_status === null &&
          row.biometric_status === null;

        if (alreadyClean) continue;

        await markGateOffline(gate_id);
      }
    } catch (error) {
      logger.error("Gate health watcher error:", error);
    }
  }, WATCH_INTERVAL_MS);
};