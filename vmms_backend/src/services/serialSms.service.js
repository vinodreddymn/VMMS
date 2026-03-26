import { SerialPort } from "serialport";
import { ReadlineParser } from "@serialport/parser-readline";
import os from "os";
import db from "../config/db.js";
import logger from "../utils/logger.util.js";

const {
  SERIAL_PORT = "",          // optional override
  BAUD_RATE = 115200,
  SMS_MAX_ATTEMPTS = 3,
} = process.env;

class SerialSMSService {
  constructor() {
    this.port = null;
    this.parser = null;
    this.devicePath = null;
  }

  /**
   * 🔥 AUTO DETECT USB MODEM
   */
  async detectDevice() {
    if (SERIAL_PORT) return SERIAL_PORT;

    const ports = await SerialPort.list();

    if (!ports.length) {
      throw new Error("No serial devices found");
    }

    // Prefer USB modem
    const usbPort = ports.find(p =>
      p.path.includes("USB") ||
      p.path.includes("COM") ||
      p.path.includes("tty")
    );

    return usbPort?.path || ports[0].path;
  }

  /**
   * CONNECT SERIAL
   */
  async connect() {
    if (this.port && this.port.isOpen) return;

    this.devicePath = await this.detectDevice();

    this.port = new SerialPort({
      path: this.devicePath,
      baudRate: Number(BAUD_RATE),
      autoOpen: false,
    });

    this.parser = this.port.pipe(
      new ReadlineParser({ delimiter: "\r\n" })
    );

    await new Promise((resolve, reject) => {
      this.port.open(err => {
        if (err) return reject(err);
        logger.info(`Serial connected → ${this.devicePath}`);
        resolve();
      });
    });
  }

  /**
   * SEND AT COMMAND
   */
  sendCommand(command, waitFor = "OK", timeout = 5000) {
    return new Promise((resolve, reject) => {
      let response = "";
      const timer = setTimeout(() => {
        cleanup();
        reject(new Error("Timeout waiting for response"));
      }, timeout);

      const onData = data => {
        response += data + "\n";

        if (response.includes(waitFor)) {
          cleanup();
          resolve(response);
        }
      };

      const cleanup = () => {
        clearTimeout(timer);
        this.parser.off("data", onData);
      };

      this.parser.on("data", onData);

      this.port.write(command + "\r", err => {
        if (err) {
          cleanup();
          reject(err);
        }
      });
    });
  }

  /**
   * SEND SMS USING AT COMMANDS
   */
  async sendSMS(phone, message) {
    try {
      await this.connect();

      const number = String(phone).replace(/[^\d+]/g, "");
      if (!number) throw new Error("Invalid phone number");

      // TEXT MODE
      await this.sendCommand("AT+CMGF=1");

      // SET NUMBER
      await this.sendCommand(`AT+CMGS="${number}"`, ">");

      // SEND MESSAGE + CTRL+Z
      await new Promise((resolve, reject) => {
        this.port.write(message + String.fromCharCode(26), err => {
          if (err) return reject(err);
          resolve();
        });
      });

      // WAIT FOR CONFIRMATION
      await this.sendCommand("", "OK", 10000);

      logger.info(`SMS sent → ${number}`);
      return { success: true };

    } catch (error) {
      logger.error("SMS send failed:", error.message);
      return { success: false, error: error.message };
    }
  }

  /**
   * 🔥 CORE WORKER
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
        try {
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
              success ? null : result.error,
              row.id,
            ]
          );

        } catch (err) {
          failed++;

          await client.query(
            `
            UPDATE sms_logs
            SET status = 'FAILED',
                last_error = $1,
                updated_at = NOW()
            WHERE id = $2
            `,
            [err.message, row.id]
          );

          logger.error(`SMS failed ID ${row.id}:`, err);
        }
      }

      await client.query("COMMIT");

      logger.info(
        `Serial SMS Worker → processed=${rows.length}, sent=${sent}, failed=${failed}`
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
   * OPTIONAL: TEST MODEM
   */
  async testModem() {
    await this.connect();
    return this.sendCommand("AT");
  }
}

export default new SerialSMSService();