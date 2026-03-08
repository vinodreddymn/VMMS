import * as blacklistRepo from "../repositories/blacklist.repo.js";
import logger from "../utils/logger.util.js";
// =====================================================
// BLACKLIST MANAGEMENT
// =====================================================

export const addToBlacklist = async (req, res) => {
  try {
    const { aadhaar, phone, biometric_hash, reason, block_type } = req.body;

    const entry = await blacklistRepo.addToBlacklist(aadhaar, phone, biometric_hash, reason, block_type);

    logger.warn(`Added to blacklist: ${reason}`);

    res.status(201).json({ success: true, entry });
  } catch (error) {
    logger.error("Add to blacklist error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};

export const getBlacklist = async (req, res) => {
  try {
    const entries = await blacklistRepo.getBlacklist();
    res.json({ success: true, entries, count: entries.length });
  } catch (error) {
    logger.error("Get blacklist error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};

export const removeFromBlacklist = async (req, res) => {
  try {
    const { id } = req.params;

    await blacklistRepo.removeFromBlacklist(id);

    logger.info(`Removed from blacklist: ID ${id}`);

    res.json({ success: true, message: "Removed from blacklist" });
  } catch (error) {
    logger.error("Remove from blacklist error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};

export const checkBlacklist = async (req, res) => {
  try {
    const { aadhaar, phone, biometric_hash } = req.body;

    let entry = null;

    if (aadhaar) {
      entry = await blacklistRepo.checkByAadhaar(aadhaar);
    } else if (phone) {
      entry = await blacklistRepo.checkByPhone(phone);
    } else if (biometric_hash) {
      entry = await blacklistRepo.checkByBiometric(biometric_hash);
    }

    res.json({ success: true, isBlacklisted: !!entry, entry });
  } catch (error) {
    logger.error("Check blacklist error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};
