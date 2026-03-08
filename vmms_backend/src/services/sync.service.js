import db from "../config/db.js";
import logger from "../utils/logger.util.js";
/**
 * SYNC SERVICE
 * Handles offline synchronization and master whitelist distribution
 */
class SyncService {
  /**
   * Get master whitelist for gate synchronization
   * Called by gates every 5 minutes
   */
  async getMasterWhitelist(lastSync) {
    try {
      const query = `
        SELECT id, visitor_id, rfid_uid, biometric_hash,
               smartphone_allowed, laptop_allowed, ops_area_permitted,
               valid_until, last_synced
        FROM master_whitelist
        WHERE last_synced > $1
        ORDER BY last_synced DESC
      `;

      const defaultLastSync = new Date(Date.now() - 5 * 60 * 1000); // Last 5 minutes
      const result = await db.query(query, [lastSync || defaultLastSync]);

      return {
        success: true,
        whitelist: result.rows,
        sync_timestamp: new Date(),
      };
    } catch (error) {
      logger.error("Get master whitelist error:", error);
      return { success: false, error: error.message };
    }
  }

  /**
   * Process offline sync queue
   * Gates push cached access logs and photos when reconnected
   */
  async processSyncQueue(gate_id, payloads) {
    try {
      const results = [];

      for (const payload of payloads) {
        try {
          // Insert into sync_queue
          const result = await db.query(
            `INSERT INTO sync_queue (gate_id, payload, created_at, synced)
             VALUES ($1, $2, NOW(), TRUE) RETURNING *`,
            [gate_id, JSON.stringify(payload)]
          );

          // If payload contains access logs, process them
          if (payload.access_logs) {
            for (const log of payload.access_logs) {
              await db.query(
                `INSERT INTO access_logs (person_type, person_id, gate_id, direction, scan_time, status, live_photo_path)
                 VALUES ($1, $2, $3, $4, $5, $6, $7)`,
                [
                  log.person_type,
                  log.person_id,
                  gate_id,
                  log.direction,
                  new Date(log.scan_time),
                  log.status || "SUCCESS",
                  log.live_photo_path,
                ]
              );
            }
          }

          results.push({ success: true, payload_id: result.rows[0].id });
        } catch (innerError) {
          logger.error("Error processing sync payload:", innerError);
          results.push({ success: false, error: innerError.message });
        }
      }

      return {
        success: true,
        processed: results.length,
        results,
      };
    } catch (error) {
      logger.error("Process sync queue error:", error);
      return { success: false, error: error.message };
    }
  }

  /**
   * Get unsynced items from queue for gate
   */
  async getUnSyncedQueue(gate_id, limit = 100) {
    try {
      const query = `
        SELECT * FROM sync_queue
        WHERE gate_id = $1 AND synced = FALSE
        ORDER BY created_at ASC
        LIMIT $2
      `;

      const result = await db.query(query, [gate_id, limit]);
      return { success: true, queue: result.rows };
    } catch (error) {
      logger.error("Get unsynced queue error:", error);
      return { success: false, error: error.message };
    }
  }

  /**
   * Mark sync queue items as synced
   */
  async markSynced(sync_ids) {
    try {
      const query = `
        UPDATE sync_queue
        SET synced = TRUE, synced_at = NOW()
        WHERE id = ANY($1)
        RETURNING *
      `;

      const result = await db.query(query, [sync_ids]);
      return { success: true, synced_count: result.rows.length };
    } catch (error) {
      logger.error("Mark synced error:", error);
      return { success: false, error: error.message };
    }
  }

  /**
   * Push master whitelist to all active gates
   * Called every 5 minutes via cron
   */
  async pushWhitelistToGates() {
    try {
      // Get all active gates
      const gatesResult = await db.query("SELECT id FROM gates WHERE is_active = TRUE");

      const whitelist = await this.getMasterWhitelist(new Date(Date.now() - 5 * 60 * 1000));

      logger.info(`Pushing whitelist with ${whitelist.whitelist.length} entries to ${gatesResult.rows.length} gates`);

      return {
        success: true,
        gates_updated: gatesResult.rows.length,
        whitelist_entries: whitelist.whitelist.length,
      };
    } catch (error) {
      logger.error("Push whitelist to gates error:", error);
      return { success: false, error: error.message };
    }
  }
}

export default new SyncService();
