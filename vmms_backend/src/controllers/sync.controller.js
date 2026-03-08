import syncService from "../services/sync.service.js";
import logger from "../utils/logger.util.js";
// =====================================================
// GATE SYNCHRONIZATION
// =====================================================

export const getMasterWhitelist = async (req, res) => {
  try {
    const { last_sync } = req.query;

    const result = await syncService.getMasterWhitelist(last_sync);

    res.json(result);
  } catch (error) {
    logger.error("Get master whitelist error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};

export const processSyncQueue = async (req, res) => {
  try {
    const { gate_id, payloads } = req.body;

    if (!gate_id || !payloads || !Array.isArray(payloads)) {
      return res.status(400).json({ success: false, error: "Invalid request format" });
    }

    const result = await syncService.processSyncQueue(gate_id, payloads);

    res.json(result);
  } catch (error) {
    logger.error("Process sync queue error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};

export const getUnSyncedQueue = async (req, res) => {
  try {
    const { gate_id, limit = 100 } = req.query;

    if (!gate_id) {
      return res.status(400).json({ success: false, error: "Gate ID required" });
    }

    const result = await syncService.getUnSyncedQueue(gate_id, limit);

    res.json(result);
  } catch (error) {
    logger.error("Get unsynced queue error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};

export const markSynced = async (req, res) => {
  try {
    const { sync_ids } = req.body;

    if (!Array.isArray(sync_ids)) {
      return res.status(400).json({ success: false, error: "sync_ids must be an array" });
    }

    const result = await syncService.markSynced(sync_ids);

    res.json(result);
  } catch (error) {
    logger.error("Mark synced error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};
