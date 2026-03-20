import db from "../config/db.js";
import logger from "../utils/logger.util.js";
import { exec } from "child_process";
import util from "util";

const execAsync = util.promisify(exec);

const {
  SMS_PROVIDER = "gammu",
  GAMMU_BINARY = "gammu-smsd-inject",
  GAMMU_DEVICE = "",
} = process.env;

// SMS Service - Handles all SMS communications
class SMSService {
  constructor() {
    // Supported providers: gammu | twilio | aws | console
    this.provider = SMS_PROVIDER.toLowerCase();
  }

  async sendSMS(phone, message, eventType, related_entity_id = null) {
    try {
      let status = "FAILED";

      if (this.provider === "twilio") {
        // Example: Twilio integration
        // const response = await twilioClient.messages.create({...});
        // status = "SENT";
      } else if (this.provider === "aws") {
        // Example: AWS SNS integration
        // const response = await snsClient.publish({...});
        // status = "SENT";
      } else if (this.provider === "gammu") {
        status = await this.sendViaGammu(phone, message) ? "SENT" : "FAILED";
      } else {
        // Console logging for development
        logger.info(`SMS to ${phone}: ${message}`);
        status = "SENT";
      }

      // Log SMS in database
      await db.query(
        `INSERT INTO sms_logs (recipient, message, event_type, related_entity_id, status)
         VALUES ($1, $2, $3, $4, $5)`,
        [phone, message, eventType, related_entity_id, status]
      );

      return { success: status === "SENT", status };
    } catch (error) {
      logger.error("SMS sending failed:", error);
      await db.query(
        `INSERT INTO sms_logs (recipient, message, event_type, related_entity_id, status)
         VALUES ($1, $2, $3, $4, 'FAILED')`,
        [phone, message, eventType, related_entity_id]
      );
      return { success: false, status: "FAILED" };
    }
  }

  async sendViaGammu(phone, message) {
    // gammu-smsd-inject TEXT <phone> -text "message"
    const sanitizedPhone = String(phone || "").trim();
    if (!sanitizedPhone) {
      logger.warn("Gammu SMS aborted: missing phone number");
      return false;
    }

    const cmd = `${GAMMU_BINARY} TEXT "${sanitizedPhone}" -text "${message.replace(/"/g, '\\"')}"${
      GAMMU_DEVICE ? ` -device "${GAMMU_DEVICE}"` : ""
    }`;

    try {
      const { stdout, stderr } = await execAsync(cmd);
      if (stdout) logger.info(`Gammu SMS stdout: ${stdout.trim()}`);
      if (stderr) logger.warn(`Gammu SMS stderr: ${stderr.trim()}`);
      return true;
    } catch (error) {
      logger.error("Gammu SMS failed:", error);
      return false;
    }
  }

  async sendLabourRegistrationSMS(host_phone, supervisor_name, labour_count) {
    const message = `Labour manifest registered: ${supervisor_name} with ${labour_count} workers for the day.`;
    return this.sendSMS(host_phone, message, "LABOUR_REGISTRATION");
  }

  async sendNoShowAlertSMS(host_phone, labour_name) {
    const message = `No-Show Alert: ${labour_name} has not entered the facility within 60 minutes of manifest printing.`;
    return this.sendSMS(host_phone, message, "NO_SHOW_ALERT");
  }



  async sendBlacklistAlertSMS(security_head_phone, person_name, reason) {
    const message = `SECURITY ALERT: Blacklisted person ${person_name} attempted entry. Reason: ${reason}`;
    return this.sendSMS(security_head_phone, message, "BLACKLIST_ALERT");
  }

  async getSMSLogs(filters = {}) {
    let query = "SELECT * FROM sms_logs WHERE 1=1";
    const values = [];
    let paramCount = 1;

    if (filters.recipient) {
      query += ` AND recipient = $${paramCount++}`;
      values.push(filters.recipient);
    }

    if (filters.event_type) {
      query += ` AND event_type = $${paramCount++}`;
      values.push(filters.event_type);
    }

    if (filters.from_date) {
      query += ` AND sent_at >= $${paramCount++}`;
      values.push(filters.from_date);
    }

    if (filters.to_date) {
      query += ` AND sent_at <= $${paramCount++}`;
      values.push(filters.to_date);
    }

    query += " ORDER BY sent_at DESC LIMIT 1000";

    const result = await db.query(query, values);
    return result.rows;
  }
}

export default new SMSService();
