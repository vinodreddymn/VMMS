import db from "../config/db.js";
import logger from "../utils/logger.util.js";
import * as visitorRepo from "../repositories/visitor.repo.js";
import * as labourRepo from "../repositories/labour.repo.js";
import * as gateRepo from "../repositories/gate.repo.js";
import { emitAccessEvent } from "../socket.js";
import { saveLivePhoto } from "../utils/live-photo.util.js";

const DEFAULT_SYNC_WINDOW_MINUTES = 5;
const MAX_QUEUE_BATCH = 500;
const MAX_WHITELIST_ROWS = 5000;

const parseDate = (value, fallback) => {
  if (!value) return fallback;
  const ts = Date.parse(value);
  return Number.isNaN(ts) ? fallback : new Date(ts);
};

const clampNumber = (value, min, max) => {
  const num = Number(value);
  if (Number.isNaN(num)) return min;
  return Math.min(Math.max(num, min), max);
};

const sanitizeAccessLog = (log = {}) => ({
  person_type: String(log.person_type || "").toUpperCase() || null,
  person_id: log.person_id ? Number(log.person_id) : null,
  direction: (log.direction || "IN").toUpperCase(),
  status: log.status ? String(log.status).toUpperCase() : "SUCCESS",
  scan_time: parseDate(log.scan_time, new Date()),
  live_photo_path: log.live_photo_path || null,
  live_photo_base64: log.live_photo_base64 || log.live_photo || null,
  rfid_uid: log.rfid_uid || log.card_uid || null,
});
/**
 * SYNC SERVICE
 * Handles offline synchronization and master whitelist distribution
 */
class SyncService {
  /**
   * Get master whitelist for gate synchronization
   * Called by gates every 5 minutes
   */
  async getMasterWhitelist(lastSync, gateId) {
    try {
      const since = lastSync ? parseDate(lastSync, null) : null;

      // Dynamic whitelist from live data to avoid stale master_whitelist entries
      const filters = [];
      const values = [];
      let i = 1;

      if (since) {
        filters.push(`COALESCE(v.updated_at, v.created_at) > $${i}`);
        values.push(since);
        i += 1;
      }

      filters.push(`v.status = 'ACTIVE'`);
      filters.push(`rc.card_status = 'ACTIVE'`);
      filters.push(`(v.valid_to IS NULL OR v.valid_to >= CURRENT_DATE)`);

      if (gateId) {
        filters.push(`
          (
            EXISTS (
              SELECT 1 FROM visitor_gate_permissions vgp2 
              WHERE vgp2.visitor_id = v.id AND vgp2.gate_id = $${i}
            )
            OR NOT EXISTS (
              SELECT 1 FROM visitor_gate_permissions vgp3
              WHERE vgp3.visitor_id = v.id
            )
          )
        `);
        values.push(Number(gateId));
        i += 1;
      }

      const where = filters.length ? `WHERE ${filters.join(" AND ")}` : "";

      const query = `
        SELECT
          v.id AS visitor_id,
          rc.card_uid AS rfid_uid,
          v.smartphone_allowed,
          v.laptop_allowed,
          v.ops_area_permitted,
          v.valid_to AS valid_until,
          COALESCE(v.updated_at, v.created_at) AS last_synced,
          v.pass_no,
          v.status,
          v.valid_from,
          v.valid_to,
          v.full_name,
          v.company_name,
          v.department_id,
          v.project_id,
          v.host_id,
          v.enrollment_photo_path,
          COALESCE(array_agg(DISTINCT vgp.gate_id) FILTER (WHERE vgp.gate_id IS NOT NULL), '{}') AS gate_ids
        FROM visitors v
        JOIN rfid_cards rc ON rc.visitor_id = v.id AND rc.card_status = 'ACTIVE'
        LEFT JOIN visitor_gate_permissions vgp ON vgp.visitor_id = v.id
        ${where}
        GROUP BY v.id, rc.card_uid
        ORDER BY last_synced DESC
        LIMIT ${MAX_WHITELIST_ROWS}
      `;

      const result = await db.query(query, values);

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
      const gateId = Number(gate_id);
      if (!Number.isFinite(gateId)) {
        return { success: false, error: "Invalid gate_id" };
      }

      const results = [];
      const batch = Array.isArray(payloads)
        ? payloads.slice(0, MAX_QUEUE_BATCH)
        : [];

      for (const payload of batch) {
        const client = await db.connect();
        try {
          await client.query("BEGIN");

          const queueResult = await client.query(
            `INSERT INTO sync_queue (gate_id, payload, created_at, synced)
             VALUES ($1, $2, NOW(), TRUE)
             RETURNING id`,
            [gateId, JSON.stringify(payload)]
          );

          if (Array.isArray(payload.access_logs) && payload.access_logs.length) {
            const insertLog = `
              INSERT INTO access_logs
              (person_type, person_id, gate_id, direction, scan_time, status, live_photo_path)
              VALUES ($1, $2, $3, $4, $5, $6, $7)
              RETURNING *
            `;

            for (const raw of payload.access_logs) {
              const log = sanitizeAccessLog(raw);

              if (!log.person_type || !log.person_id) {
                logger.warn("Skipping access_log with missing identifiers", { log });
                continue;
              }

              // Save live photo if base64 provided
              if (log.live_photo_base64) {
                try {
                  const saved = await saveLivePhoto({
                    personType: log.person_type,
                    personId: log.person_id,
                    rfidUid: log.rfid_uid,
                    gateId,
                    photo: log.live_photo_base64,
                  });
                  log.live_photo_path = saved?.livePhotoPath || log.live_photo_path;
                } catch (photoErr) {
                  logger.warn("Failed to save live photo from sync payload", photoErr);
                }
              }

              const inserted = await client.query(insertLog, [
                log.person_type,
                log.person_id,
                gateId,
                log.direction,
                log.scan_time,
                log.status,
                log.live_photo_path,
              ]);

              // Emit Andon event for dashboards
              try {
                const gateInfo = await gateRepo.getGate(gateId);
                if (log.person_type === "VISITOR") {
                  const visitor = await visitorRepo.findById(log.person_id);
                  const permRes = await db.query(
                    `SELECT g.gate_name FROM visitor_gate_permissions vgp JOIN gates g ON g.id = vgp.gate_id WHERE vgp.visitor_id = $1`,
                    [log.person_id]
                  );
                  const gatePermissions = permRes.rows.map((r) => r.gate_name);
                  emitAccessEvent({
                    person_type: "VISITOR",
                    direction: log.direction,
                    pass_no: visitor?.pass_no,
                    full_name: visitor?.full_name,
                    phone: visitor?.primary_phone,
                    aadhaar_last4: visitor?.aadhaar_last4,
                    project_name: visitor?.project_name,
                    department_name: visitor?.department_name,
                    company_name: visitor?.company_name,
                    host_name: visitor?.host_name,
                    gate_id: gateId,
                    gate_name: gateInfo?.gate_name || `Gate ${gateId}`,
                    scan_time: inserted.rows[0]?.scan_time || log.scan_time,
                    enrollment_photo_path: visitor?.enrollment_photo_path,
                    live_photo_path: log.live_photo_path || null,
                    access_log_id: inserted.rows[0]?.id || null,
                    designation: visitor?.designation,
                    pass_valid_from: visitor?.valid_from,
                    pass_valid_to: visitor?.valid_to,
                    pass_valid_till: visitor?.work_order_expiry,
                    permissions: gatePermissions,
                  });
                } else if (log.person_type === "LABOUR") {
                  const labour = await labourRepo.getLabourById(log.person_id);
                  const supervisor = labour?.supervisor_id
                    ? await visitorRepo.findById(labour.supervisor_id)
                    : null;
                  emitAccessEvent({
                    person_type: "LABOUR",
                    direction: log.direction,
                    full_name: labour?.full_name,
                    supervisor_name: supervisor?.full_name || "-",
                    supervisor_company: supervisor?.company_name || "-",
                    supervisor_enrollment_photo_path: supervisor?.enrollment_photo_path || null,
                    gate_id: gateId,
                    gate_name: gateInfo?.gate_name || `Gate ${gateId}`,
                    scan_time: inserted.rows[0]?.scan_time || log.scan_time,
                    token_uid: log.rfid_uid || null,
                    live_photo_path: log.live_photo_path || null,
                    access_log_id: inserted.rows[0]?.id || null,
                    pass_valid_to: labour?.valid_until || null,
                  });
                }
              } catch (emitErr) {
                logger.warn("Failed to emit access event from sync queue", emitErr);
              }
            }
          }

          await client.query("COMMIT");
          results.push({ success: true, payload_id: queueResult.rows[0].id });
        } catch (innerError) {
          await client.query("ROLLBACK");
          logger.error("Error processing sync payload:", innerError);
          results.push({ success: false, error: innerError.message });
        } finally {
          client.release();
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
      const gateId = Number(gate_id);
      if (!Number.isFinite(gateId)) {
        return { success: false, error: "Invalid gate_id" };
      }

      const safeLimit = clampNumber(limit, 1, MAX_QUEUE_BATCH);
      const query = `
        SELECT * FROM sync_queue
        WHERE gate_id = $1 AND synced = FALSE
        ORDER BY created_at ASC
        LIMIT $2
      `;

      const result = await db.query(query, [gateId, safeLimit]);
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
      const ids = (sync_ids || [])
        .map((id) => Number(id))
        .filter((id) => Number.isFinite(id));

      if (!ids.length) {
        return { success: true, synced_count: 0 };
      }

      const query = `
        UPDATE sync_queue
        SET synced = TRUE, synced_at = NOW()
        WHERE id = ANY($1)
        RETURNING *
      `;

      const result = await db.query(query, [ids]);
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

      const whitelist = await this.getMasterWhitelist(
        new Date(Date.now() - DEFAULT_SYNC_WINDOW_MINUTES * 60 * 1000)
      );

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
