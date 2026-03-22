import * as blacklistRepo from "../repositories/blacklist.repo.js";
import logger from "../utils/logger.util.js";

// =====================================================
// BLACKLIST MANAGEMENT
// =====================================================

// Add to Blacklist
export const addToBlacklist = async (req, res) => {
  try {
    const { aadhaar, phone, biometric_hash, reason, block_type } = req.body;

    // 🔴 Validation: At least one identifier required
    if (!aadhaar && !phone && !biometric_hash) {
      return res.status(400).json({
        success: false,
        message: "At least one identifier (aadhaar, phone, biometric) is required",
      });
    }

    // 🔴 Validation: block_type check
    const allowedTypes = ["TEMP", "PERMANENT"];
    if (block_type && !allowedTypes.includes(block_type)) {
      return res.status(400).json({
        success: false,
        message: "Invalid block_type. Allowed: TEMP, PERMANENT",
      });
    }

    // 🔴 Duplicate Check
    let existing = null;

    if (aadhaar) {
      existing = await blacklistRepo.checkByAadhaar(aadhaar);
    }
    if (!existing && phone) {
      existing = await blacklistRepo.checkByPhone(phone);
    }
    if (!existing && biometric_hash) {
      existing = await blacklistRepo.checkByBiometric(biometric_hash);
    }

    if (existing) {
      return res.status(409).json({
        success: false,
        message: "Person already blacklisted",
      });
    }

    // ✅ Insert
    const entry = await blacklistRepo.addToBlacklist(
      aadhaar,
      phone,
      biometric_hash,
      reason,
      block_type
    );

    logger.warn("Blacklist entry added", {
      id: entry.id,
      phone,
      block_type,
      reason,
    });

    res.status(201).json({
      success: true,
      entry: {
        id: entry.id,
        reason: entry.reason,
        block_type: entry.block_type,
        created_at: entry.created_at,
      },
    });
  } catch (error) {
    logger.error("Add to blacklist error", { error: error.message });
    res.status(500).json({ success: false, error: error.message });
  }
};

// Get all blacklist entries
export const getBlacklist = async (req, res) => {
  try {
    const entries = await blacklistRepo.getBlacklist();

    res.json({
      success: true,
      count: entries.length,
      entries,
    });
  } catch (error) {
    logger.error("Get blacklist error", { error: error.message });
    res.status(500).json({ success: false, error: error.message });
  }
};

// Remove from Blacklist
export const removeFromBlacklist = async (req, res) => {
  try {
    const { id } = req.params;

    // 🔴 Check existence
    const existing = await blacklistRepo.getBlacklistById(id);
    if (!existing) {
      return res.status(404).json({
        success: false,
        message: "Blacklist entry not found",
      });
    }

    await blacklistRepo.removeFromBlacklist(id);

    logger.info("Blacklist entry removed", { id });

    res.json({
      success: true,
      message: "Removed from blacklist",
    });
  } catch (error) {
    logger.error("Remove from blacklist error", { error: error.message });
    res.status(500).json({ success: false, error: error.message });
  }
};

// Check Blacklist (Gate / Enrollment)
export const checkBlacklist = async (req, res) => {
  try {
    const { aadhaar, phone, biometric_hash } = req.body;

    // 🔴 Validation
    if (!aadhaar && !phone && !biometric_hash) {
      return res.status(400).json({
        success: false,
        message: "Provide at least one identifier",
      });
    }

    let entry = null;

    // ✅ Multi-check (important)
    if (aadhaar) {
      entry = await blacklistRepo.checkByAadhaar(aadhaar);
    }
    if (!entry && phone) {
      entry = await blacklistRepo.checkByPhone(phone);
    }
    if (!entry && biometric_hash) {
      entry = await blacklistRepo.checkByBiometric(biometric_hash);
    }

    res.json({
      success: true,
      isBlacklisted: !!entry,
      entry: entry
        ? {
            id: entry.id,
            reason: entry.reason,
            block_type: entry.block_type,
          }
        : null,
    });
  } catch (error) {
    logger.error("Check blacklist error", { error: error.message });
    res.status(500).json({ success: false, error: error.message });
  }
};