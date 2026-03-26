import db from "../config/db.js";
import smsService from "../services/sms.service.js";
import logger from "../utils/logger.util.js";

const VALID_STATUS = ["PENDING", "PROCESSING", "SENT", "FAILED"];

export const listSMSLogs = async (req, res) => {
  try {
    const { status, event_type, recipient, limit = 200, offset = 0 } = req.query;
    const conditions = [];
    const values = [];
    let idx = 1;

    if (status) {
      conditions.push(`status = $${idx++}`);
      values.push(status);
    }
    if (event_type) {
      conditions.push(`event_type = $${idx++}`);
      values.push(event_type);
    }
    if (recipient) {
      conditions.push(`recipient = $${idx++}`);
      values.push(recipient);
    }

    const where = conditions.length ? `WHERE ${conditions.join(" AND ")}` : "";

    const query = `
      SELECT *
      FROM sms_logs
      ${where}
      ORDER BY id DESC
      LIMIT $${idx++}
      OFFSET $${idx}
    `;

    values.push(Number(limit) || 200, Number(offset) || 0);

    const result = await db.query(query, values);
    res.json({ success: true, logs: result.rows });
  } catch (error) {
    logger.error("listSMSLogs error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};

export const updateSMSStatus = async (req, res) => {
  try {
    const { ids = [], status } = req.body || {};
    if (!status || !VALID_STATUS.includes(status)) {
      return res.status(400).json({ success: false, error: "Invalid status" });
    }
    if (!Array.isArray(ids) || !ids.length) {
      return res.status(400).json({ success: false, error: "ids array required" });
    }

    const idNums = ids.map((x) => Number(x)).filter((n) => Number.isFinite(n));
    if (!idNums.length) {
      return res.status(400).json({ success: false, error: "ids must be numbers" });
    }

    const result = await db.query(
      `UPDATE sms_logs
       SET status = $1::varchar,
           sent_at = CASE WHEN $1::varchar = 'SENT' THEN NOW() ELSE sent_at END,
           updated_at = NOW()
       WHERE id = ANY($2::bigint[])
       RETURNING *`,
      [status.toUpperCase(), idNums]
    );

    res.json({ success: true, updated: result.rows });
  } catch (error) {
    logger.error("updateSMSStatus error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};

export const deleteSMSLogs = async (req, res) => {
  try {
    const { ids = [], status = "SENT" } = req.body || {};

    let result;
    if (Array.isArray(ids) && ids.length) {
      const placeholders = ids.map((_, i) => `$${i + 1}`).join(",");
      result = await db.query(
        `DELETE FROM sms_logs WHERE id IN (${placeholders}) RETURNING id`,
        ids
      );
    } else {
      // default: clear all SENT
      result = await db.query(
        `DELETE FROM sms_logs WHERE status = $1 RETURNING id`,
        [status]
      );
    }

    res.json({ success: true, deleted_count: result.rowCount });
  } catch (error) {
    logger.error("deleteSMSLogs error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};

export const createSMS = async (req, res) => {
  try {
    const { recipient, message, event_type = "MANUAL", related_entity_id = null, recipient_name = null } = req.body || {};
    if (!recipient || !message) {
      return res.status(400).json({ success: false, error: "recipient and message are required" });
    }

    const result = await smsService.queueSMS({
      phone: recipient,
      message,
      eventType: event_type,
      relatedEntityId: related_entity_id,
      recipientName: recipient_name
    });

    if (!result.success) {
      return res.status(500).json({ success: false, error: result.error || "Failed to queue SMS" });
    }

    res.status(201).json({ success: true, id: result.id, status: result.status });
  } catch (error) {
    logger.error("createSMS error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};
