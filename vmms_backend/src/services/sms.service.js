import db from "../config/db.js";
import logger from "../utils/logger.util.js";

class SMSService {
  /**
   * Generic SMS queue function
   */
  async queueSMS({
    phone,
    message,
    eventType = "GENERAL",
    relatedEntityId = null,
    recipientName = null,
  }) {
    try {
      if (!phone || !message) {
        throw new Error("Phone and message are required");
      }

      const query = `
        INSERT INTO sms_logs
        (recipient, recipient_name, message, event_type, related_entity_id, status)
        VALUES ($1, $2, $3, $4, $5, 'PENDING')
        RETURNING id
      `;

      const values = [
        phone,
        recipientName,
        message,
        eventType,
        relatedEntityId,
      ];

      const result = await db.query(query, values);

      logger.info(
        `SMS queued [ID=${result.rows[0].id}] → ${phone} (${eventType})`
      );

      return {
        success: true,
        id: result.rows[0].id,
        status: "PENDING",
      };
    } catch (error) {
      logger.error("SMS queueing failed:", error);
      return { success: false, error: error.message };
    }
  }

  // ==========================
  // EVENT-SPECIFIC HELPERS
  // ==========================

  async sendLabourRegistrationSMS(
    hostPhone,
    supervisorName,
    labourCount
  ) {
    const message = `Labour manifest registered: ${supervisorName} with ${labourCount} workers.`;

    return this.queueSMS({
      phone: hostPhone,
      message,
      eventType: "LABOUR_REGISTRATION",
      recipientName: supervisorName,
    });
  }

  async sendNoShowAlertSMS(hostPhone, labourName) {
    const message = `No-Show Alert: ${labourName} has not entered within expected time.`;

    return this.queueSMS({
      phone: hostPhone,
      message,
      eventType: "NO_SHOW_ALERT",
      recipientName: labourName,
    });
  }

  async sendBlacklistAlertSMS(phone, personName, reason) {
    const message = `SECURITY ALERT: ${personName} attempted entry. Reason: ${reason}`;

    return this.queueSMS({
      phone,
      message,
      eventType: "BLACKLIST_ALERT",
      recipientName: personName,
    });
  }

  /**
   * Fetch logs (for UI / debugging)
   */
  async getSMSLogs(filters = {}) {
    let query = `SELECT * FROM sms_logs WHERE 1=1`;
    const values = [];
    let i = 1;

    if (filters.recipient) {
      query += ` AND recipient = $${i++}`;
      values.push(filters.recipient);
    }

    if (filters.event_type) {
      query += ` AND event_type = $${i++}`;
      values.push(filters.event_type);
    }

    if (filters.status) {
      query += ` AND status = $${i++}`;
      values.push(filters.status);
    }

    if (filters.from_date) {
      query += ` AND updated_at >= $${i++}`;
      values.push(filters.from_date);
    }

    if (filters.to_date) {
      query += ` AND updated_at <= $${i++}`;
      values.push(filters.to_date);
    }

    query += ` ORDER BY id DESC LIMIT 1000`;

    const result = await db.query(query, values);
    return result.rows;
  }
}

export default new SMSService();