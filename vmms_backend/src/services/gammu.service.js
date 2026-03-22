import { exec } from "child_process";
import util from "util";
import os from "os";
import db from "../config/db.js";
import logger from "../utils/logger.util.js";

const execAsync = util.promisify(exec);

const {
  GAMMU_CONFIG_WINDOWS,
  GAMMU_CONFIG_LINUX,
  GAMMU_BINARY = "gammu",
  GAMMU_SMSD_BINARY = "gammu-smsd-inject",
  GAMMU_DEVICE = "",
  GAMMU_TIMEOUT_MS = 15000,
  SMS_MAX_ATTEMPTS = 3,
} = process.env;

class GammuService {
  constructor() {
    this.configPath = this.resolveConfigPath();
  }

  resolveConfigPath() {
    const platform = os.platform();
    return platform === "win32"
      ? GAMMU_CONFIG_WINDOWS
      : GAMMU_CONFIG_LINUX;
  }

  buildCommand(parts = []) {
    const configArg = this.configPath ? ["-c", `"${this.configPath}"`] : [];
    const deviceArg = GAMMU_DEVICE ? ["-device", `"${GAMMU_DEVICE}"`] : [];
    return [...parts, ...configArg, ...deviceArg].join(" ");
  }

  async run(command) {
    try {
      const { stdout, stderr } = await execAsync(command, {
        timeout: Number(GAMMU_TIMEOUT_MS),
      });

      if (stderr) logger.warn(`Gammu stderr: ${stderr}`);

      return { success: true, stdout };
    } catch (error) {
      logger.error("Gammu command failed:", error.message);
      return {
        success: false,
        error: error.message,
        stderr: error.stderr?.toString(),
      };
    }
  }

  sanitizeNumber(phone) {
    return String(phone || "").replace(/[^\d+]/g, "");
  }

  sanitizeMessage(message) {
    return String(message || "").replace(/"/g, '\\"');
  }

  async sendSMS(phone, message) {
    const to = this.sanitizeNumber(phone);
    if (!to) return { success: false, error: "Invalid phone number" };

    const text = this.sanitizeMessage(message);

    const cmd = this.buildCommand([
      GAMMU_SMSD_BINARY,
      "TEXT",
      `"${to}"`,
      "-text",
      `"${text}"`,
    ]);

    return this.run(cmd);
  }

  /**
   * CORE WORKER FUNCTION
   */
  async processPending(limit = 20) {
    const client = await db.connect();

    try {
      await client.query("BEGIN");

      const { rows } = await client.query(
        `
        SELECT id, recipient, message, attempts
        FROM sms_logs
        WHERE status IN ('PENDING', 'FAILED')
        AND attempts < $1
        ORDER BY id ASC
        FOR UPDATE SKIP LOCKED
        LIMIT $2
        `,
        [SMS_MAX_ATTEMPTS, limit]
      );

      if (!rows.length) {
        await client.query("COMMIT");
        return { processed: 0, sent: 0, failed: 0 };
      }

      let sent = 0;
      let failed = 0;

      for (const row of rows) {
        // Mark PROCESSING
        await client.query(
          `
          UPDATE sms_logs
          SET status = 'PROCESSING',
              attempts = attempts + 1,
              updated_at = NOW()
          WHERE id = $1
          `,
          [row.id]
        );

        const result = await this.sendSMS(
          row.recipient,
          row.message
        );

        const success = result.success;
        const status = success ? "SENT" : "FAILED";

        if (success) sent++;
        else failed++;

        await client.query(
          `
          UPDATE sms_logs
          SET status = $1,
              sent_at = CASE WHEN $1 = 'SENT' THEN NOW() ELSE sent_at END,
              last_error = $2,
              updated_at = NOW()
          WHERE id = $3
          `,
          [
            status,
            success
              ? null
              : result.stderr || result.error || "Unknown error",
            row.id,
          ]
        );
      }

      await client.query("COMMIT");

      logger.info(
        `SMS Worker: processed=${rows.length}, sent=${sent}, failed=${failed}`
      );

      return { processed: rows.length, sent, failed };
    } catch (error) {
      await client.query("ROLLBACK");
      logger.error("SMS processing failed:", error);
      throw error;
    } finally {
      client.release();
    }
  }

  /**
   * Optional health check
   */
  async identify() {
    const cmd = this.buildCommand([GAMMU_BINARY, "identify"]);
    return this.run(cmd);
  }
}

export default new GammuService();