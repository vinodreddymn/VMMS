import gateService from "../services/gate.service.js";
import * as gateRepo from "../repositories/gate.repo.js";
import logger from "../utils/logger.util.js";
import db from "../config/db.js";
import { saveLivePhoto, resolvePersonInfo } from "../utils/live-photo.util.js";
// =====================================================
// GATE AUTHENTICATION
// =====================================================

export const authenticate = async (req, res) => {
  try {
    const result = await gateService.authenticate(req.body);
    res.json(result);
  } catch (error) {
    logger.error("Gate authentication error:", error);
    res.status(500).json({ status: "FAILED", error: error.message });
  }
};

export const authenticateLabour = async (req, res) => {
  try {
    const result = await gateService.authenticateLabourToken(req.body);
    res.json(result);
  } catch (error) {
    logger.error("Labour authentication error:", error);
    res.status(500).json({ status: "FAILED", error: error.message });
  }
};

// =====================================================
// MANUAL OVERRIDE CHECK-IN
// =====================================================

// =====================================================
// MANUAL GATE ENTRY
// =====================================================

export const manualEntry = async (req, res) => {
  try {

    const {
      person_type,
      person_id,
      gate_id,
      direction,
      photo,
      rfid_uid
    } = req.body;

    const operator_id = req.user?.id || null;

    if (!person_type || !person_id || !direction) {
      return res.status(400).json({
        success: false,
        error: "person_type, person_id and direction required",
      });
    }

    if (!["IN", "OUT"].includes(direction)) {
      return res.status(400).json({
        success: false,
        error: "Direction must be IN or OUT",
      });
    }

    let livePhotoPath = null;

    // Save photo if provided
    if (photo) {

      const saved = await saveLivePhoto({
        personType: person_type,
        personId: person_id,
        rfidUid: rfid_uid,
        gateId: gate_id,
        photo,
      });

      livePhotoPath = saved?.livePhotoPath || null;
    }

    // Insert access log
    const accessLog = await gateRepo.insertAccessLog(
      person_type,
      person_id,
      gate_id,
      direction,
      "SUCCESS",
      livePhotoPath,
      operator_id,
      true // manual override
    );

    logger.warn(
      `Manual gate entry by operator ${operator_id}: ${person_type} ${person_id} ${direction}`
    );

    res.json({
      success: true,
      message: `Manual ${direction === "IN" ? "Check-in" : "Check-out"} recorded`,
      access_log_id: accessLog?.id,
      photo_path: livePhotoPath,
    });

  } catch (error) {
    logger.error("Manual gate entry error:", error);
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
};

// =====================================================
// LIVE MUSTER & STATISTICS
// =====================================================

export const getLiveMuster = async (req, res) => {
  try {
    const musterData = await gateService.getLiveMuster();
    res.json({ success: true, ...musterData });
  } catch (error) {
    logger.error("Live muster error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};

export const getAccessLogs = async (req, res) => {
  try {
    const { person_id, gate_id, from_date, to_date } = req.query;

    const logs = await gateRepo.getAccessLogs({
      person_id,
      gate_id,
      from_date,
      to_date,
    });

    res.json({ success: true, logs });
  } catch (error) {
    logger.error("Get access logs error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};

// =====================================================
// GATE HEALTH MONITORING
// =====================================================

export const updateGateHealth = async (req, res) => {
  try {
    let {
      gate_id,
      is_online,
      cpu_usage,
      memory_usage,
      storage_usage,
      camera_status,
      rfid_status,
      biometric_status,
    } = req.body;

    // 🔹 Resolve gate_id automatically if not provided
    if (!gate_id) {
      const clientIP =
        req.headers["x-forwarded-for"]?.split(",")[0] ||
        req.socket?.remoteAddress ||
        req.ip;

      const gate = await gateRepo.getGateByIP(clientIP);
      if (!gate) {
        return res.status(400).json({
          success: false,
          error: "Gate not registered for this IP",
        });
      }
      gate_id = gate.id;
    }

    // 🔹 Normalize values
    cpu_usage = cpu_usage ?? 0;
    memory_usage = memory_usage ?? 0;
    storage_usage = storage_usage ?? 0;
    camera_status = camera_status ?? false;
    rfid_status = rfid_status ?? false;
    biometric_status = biometric_status ?? false;
    is_online = is_online ?? true;

    // 🔹 Update main health table
    const health = await gateRepo.updateGateHealth(
      gate_id,
      true, // Force online on update (watcher will mark offline if heartbeat missing)
      cpu_usage,
      memory_usage,
      storage_usage,
      camera_status,
      rfid_status,
      biometric_status
    );

    // 🔹 Insert history log
    await gateRepo.logGateHealth(
      gate_id,
      cpu_usage,
      memory_usage,
      storage_usage,
      camera_status,
      rfid_status,
      biometric_status
    );

    

    res.json({
      success: true,
      message: "Gate health updated",
      health,
    });
  } catch (error) {
    logger.error("Update gate health error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};

export const getGateHealth = async (req, res) => {
  try {
    const { gate_id } = req.params;

    const health = await gateRepo.getGateHealth(gate_id);
    const logs = await gateRepo.getGateHealthLogs(gate_id, 100);

    res.json({ success: true, health, logs });
  } catch (error) {
    logger.error("Get gate health error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};

export const getAllGateHealth = async (req, res) => {
  try {
    const gates = await gateRepo.getAllGates();

    const data = await Promise.all(
      gates.map(async (g) => {
        const health = await gateRepo.getGateHealth(g.id);
        return {
          gate_id: g.id,
          gate_name: g.gate_name,
          ip_address: g.ip_address,
          health,
        };
      })
    );

    res.json({ success: true, data });
  } catch (error) {
    logger.error("Get all gate health error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};

// =====================================================
// PHOTO CAPTURE & ACCESS LOG
// =====================================================

export const saveAccessLog = async (req, res) => {
  try {
    const { gate_id, rfid_uid, person_type, person_id, direction, photo } = req.body;

    if (!photo) {
      return res.status(400).json({ error: "Photo required" });
    }

    const { livePhotoPath } = await saveLivePhoto({
      personType: person_type,
      personId: person_id,
      rfidUid: rfid_uid,
      gateId: gate_id,
      photo,
    });

    if (!livePhotoPath) {
      return res.status(400).json({ error: "Invalid photo data" });
    }

    const { personId: resolvedPersonId } = await resolvePersonInfo({
      personType: person_type,
      personId: person_id,
      rfidUid: rfid_uid,
    });

    // Check if gate exists - if not, use NULL
    let validGateId = null;
    if (gate_id) {
      const gateExists = await db.query("SELECT id FROM gates WHERE id = $1", [gate_id]);
      if (gateExists.rows.length > 0) {
        validGateId = gate_id;
      }
    }

    // Save metadata to database (gate_id can be NULL for unregistered gates)
    let result = { rows: [] };
    if (resolvedPersonId && person_type && direction) {
      result = await db.query(
        `
          UPDATE access_logs
          SET live_photo_path = $1
          WHERE id = (
            SELECT id
            FROM access_logs
            WHERE person_type = $2
              AND person_id = $3
              AND direction = $4
              AND (gate_id = $5 OR $5 IS NULL)
              AND (live_photo_path IS NULL OR live_photo_path = '')
            ORDER BY scan_time DESC
            LIMIT 1
          )
          RETURNING id
        `,
        [
          livePhotoPath,
          person_type,
          resolvedPersonId,
          direction,
          validGateId,
        ]
      );
    }

    if (!result.rows.length) {
      result = await db.query(
        `
          INSERT INTO access_logs (person_type, person_id, gate_id, direction, live_photo_path, scan_time, status)
          VALUES ($1, $2, $3, $4, $5, NOW(), $6)
          RETURNING id
        `,
        [
          person_type,
          resolvedPersonId,
          validGateId, // Will be NULL if gate doesn't exist
          direction,
          livePhotoPath,
          "SUCCESS",
        ]
      );
    }

    logger.info(
      `Access log saved: ${person_type} (RFID: ${rfid_uid}) - ${direction} at gate ${gate_id || 'UNKNOWN'}`
    );

    res.json({
      success: true,
      message: "Photo saved and access logged",
      access_log_id: result.rows[0].id,
      photo_path: livePhotoPath,
      gate_registered: validGateId !== null,
    });
  } catch (error) {
    logger.error("Failed to save access log:", {
      message: error.message,
      code: error.code,
      detail: error.detail,
      stack: error.stack
    });
    res.status(500).json({ 
      error: "Failed to save access log", 
      details: error.detail || error.message,
      code: error.code
    });
  }
};
// =====================================================
// SEARCH PERSON (Visitor / Labour / RFID)
// =====================================================

export const searchPerson = async (req, res) => {
  try {
    const { query } = req.query;

    if (!query) {
      return res.status(400).json({
        success: false,
        error: "Search query required",
      });
    }

    const result = await gateRepo.searchPerson(query);

    if (!result) {
      return res.status(404).json({
        success: false,
        error: "Person not found",
      });
    }

    res.json({
      success: true,
      ...result,
    });

  } catch (error) {
    logger.error("Search person error:", error);
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
};

