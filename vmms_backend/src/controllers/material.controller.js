import * as visitorRepo from "../repositories/visitor.repo.js";
import * as materialRepo from "../repositories/material.repo.js";
import smsService from "../services/sms.service.js";
import logger from "../utils/logger.util.js";
// =====================================================
// MATERIAL CONTROLLER
// =====================================================

export const createMaterial = async (req, res) => {
  try {
    const { category, make, model, serial_number, description, is_returnable } = req.body;

    const material = await materialRepo.createMaterial(
      category,
      make,
      model,
      serial_number,
      description,
      is_returnable
    );

    res.json({ success: true, material });
  } catch (error) {
    logger.error("Create material error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};

export const getMaterials = async (req, res) => {
  try {
    const materials = await materialRepo.getAllMaterials();
    res.json({ success: true, materials });
  } catch (error) {
    logger.error("Get materials error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};

export const transaction = async (req, res) => {
  try {
    const { visitor_id, material_id, quantity, direction } = req.body;

    // Validate visitor exists
    const visitor = await visitorRepo.findById(visitor_id);
    if (!visitor) {
      return res.status(404).json({ success: false, error: "Visitor not found" });
    }

    const transaction = await materialRepo.insertTransaction(visitor_id, material_id, quantity, direction);

    res.json({ success: true, transaction });
  } catch (error) {
    logger.error("Record transaction error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};

export const balance = async (req, res) => {
  try {
    const { visitorId } = req.params;

    const balance = await materialRepo.getBalance(visitorId);
    const transactions = await materialRepo.getTransactions(visitorId);

    res.json({ success: true, balance, transactions });
  } catch (error) {
    logger.error("Get material balance error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};

export const getPendingReturns = async (req, res) => {
  try {
    const pendingReturns = await materialRepo.getPendingReturns();

    res.json({ success: true, pendingReturns });
  } catch (error) {
    logger.error("Get pending returns error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};