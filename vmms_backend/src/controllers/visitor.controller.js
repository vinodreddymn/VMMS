import * as visitorRepo from "../repositories/visitor.repo.js";
import * as blacklistRepo from "../repositories/blacklist.repo.js";
import * as encryption from "../utils/encryption.util.js";
import smsService from "../services/sms.service.js";
import logger from "../utils/logger.util.js";
import db from "../config/db.js";
import { toPosixRelativePath } from "../utils/visitor-storage.util.js";
// =====================================================
// VISITOR ENROLLMENT & CRUD
// =====================================================

export const createVisitor = async (req, res) => {

  const client = await db.connect();

  try {

    await client.query("BEGIN");

    const visitorData = req.body;
    const userId = req.user.id;

    const {
      department_id,
      project_id,
      host_id,
      allowed_gates = []
    } = visitorData;

    if (!department_id || !project_id || !host_id) {
      throw new Error("Department, Project and Host are required");
    }

    await validateVisitorDepartmentMapping(
      client,
      department_id,
      project_id,
      host_id
    );

    visitorData.created_by = userId;

    const { allowed_gates: gates, ...visitorFields } = visitorData;

    const visitor = await visitorRepo.create(visitorFields, client);

    // 🔐 Store gate permissions
    if (gates?.length) {
      await visitorRepo.setVisitorGatePermissions(
        visitor.id,
        gates,
        client
      );
    }

    await client.query("COMMIT");

    res.status(201).json({
      success: true,
      message: "Visitor enrolled successfully",
      visitor,
    });

  } catch (error) {

    await client.query("ROLLBACK");

    logger.error("Create Visitor Error:", error);

    res.status(400).json({
      success: false,
      error: error.message
    });

  } finally {

    client.release();

  }
};

// =====================================================
// LIST / SEARCH VISITORS
// =====================================================

export const getVisitors = async (req, res) => {
  try {
    const { page = 1, limit = 50, ...filters } = req.query;
    const safeLimit = Math.min(Number(limit) || 50, 500);
    const currentPage = Math.max(Number(page) || 1, 1);
    const offset = (currentPage - 1) * safeLimit;

    const { rows, total, stats, typeCounts } = await visitorRepo.findAll(filters, { limit: safeLimit, offset });

    res.json({
      success: true,
      total,
      page: currentPage,
      limit: safeLimit,
      stats,
      typeCounts,
      visitors: rows,
    });
  } catch (error) {
    logger.error("Get Visitors Error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};

// =====================================================
// FULL VISITOR PROFILE
// =====================================================

export const getVisitorById = async (req, res) => {
  try {
    const { id } = req.params;

    const isNumericId = /^\d+$/.test(String(id).trim());
    const visitor = isNumericId
      ? await visitorRepo.findById(id)
      : await visitorRepo.findByPassNo(String(id).trim());
    if (!visitor) {
      return res.status(404).json({ success: false, error: "Visitor not found" });
    }

    const [documents, biometric, gates] = await Promise.all([
      visitorRepo.getDocuments(visitor.id),
      visitorRepo.getBiometric(visitor.id),
      visitorRepo.getVisitorGatePermissions(visitor.id),
    ]);

    res.json({
      success: true,
      visitor,
      documents,
      biometric,
      allowed_gates: gates
    });
  } catch (error) {
    logger.error("Get Visitor Profile Error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};

// =====================================================
// UPDATE VISITOR
// =====================================================

export const updateVisitor = async (req, res) => {
  try {
    const { id } = req.params;
    const updates = req.body;
    const userId = req.user.id;
    const { allowed_gates, ...visitorUpdates } = updates;

    let visitor;

    const { status, reason, ...rest } = visitorUpdates || {};
    const hasOtherFields = Object.keys(rest || {}).length > 0;

    if (hasOtherFields) {
      visitor = await visitorRepo.update(id, rest);

        if (allowed_gates) {
          await visitorRepo.updateVisitorGatePermissions(
            id,
            allowed_gates
          );
        }
    }

    if (status) {
      visitor = await visitorRepo.updateStatus(
        id,
        status,
        userId,
        reason || "Manual status update"
      );
    }

    if (!visitor && !status) {
      return res.status(400).json({ success: false, error: "No valid fields to update" });
    }

    if (!visitor) {
      return res.status(400).json({ success: false, error: "No valid fields to update" });
    }

    const fresh = await visitorRepo.findById(id);
    res.json({ success: true, message: "Visitor updated", visitor: fresh || visitor });
  } catch (error) {
    logger.error("Update Visitor Error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};

// =====================================================
// DOCUMENT MANAGEMENT (KYC)
// =====================================================

export const uploadDocument = async (req, res) => {
  try {
    const { visitor_id, doc_type, doc_number, expiry_date } = req.body;
    const file = req.file;

    if (!file) {
      return res.status(400).json({ success: false, error: "File upload required" });
    }

    const document = await visitorRepo.addDocument(
      visitor_id,
      doc_type,
      doc_number,
      expiry_date,
      toPosixRelativePath(file.path)
    );

    res.json({ success: true, message: "Document uploaded", document });
  } catch (error) {
    logger.error("Upload Document Error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};

export const getDocuments = async (req, res) => {
  try {
    const { visitor_id } = req.params;
    const documents = await visitorRepo.getDocuments(visitor_id);

    res.json({ success: true, documents });
  } catch (error) {
    logger.error("Get Documents Error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};

// =====================================================
// PHOTO UPLOAD
// =====================================================

export const uploadPhoto = async (req, res) => {
  try {
    const { visitor_id } = req.params;
    const file = req.file;

    if (!file) {
      return res.status(400).json({ success: false, error: "Photo upload required" });
    }

    const visitor = await visitorRepo.update(visitor_id, {
      enrollment_photo_path: toPosixRelativePath(file.path),
    });

    if (!visitor) {
      return res.status(404).json({ success: false, error: "Visitor not found" });
    }

    res.json({ success: true, message: "Photo uploaded", visitor });
  } catch (error) {
    logger.error("Upload Photo Error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};

// =====================================================
// BIOMETRIC ENROLLMENT
// =====================================================

export const enrollBiometric = async (req, res) => {
  try {
    const { visitor_id: paramVisitorId } = req.params;
    const { visitor_id: bodyVisitorId, biometric_data, algorithm = "SHA256" } = req.body;
    const visitor_id = bodyVisitorId || paramVisitorId;

    if (!biometric_data) {
      return res.status(400).json({ success: false, error: "Biometric data required" });
    }

    const biometric_hash = encryption.hashBiometric(biometric_data);

    const biometric = await visitorRepo.enrollBiometric(
      visitor_id,
      biometric_hash,
      algorithm
    );

    res.json({ success: true, message: "Biometric enrolled", biometric });
  } catch (error) {
    logger.error("Enroll Biometric Error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};

// =====================================================
// RFID CARD ISSUANCE
// =====================================================

export const getAvailableRFIDCards = async (req, res) => {
  try {
    const search = req.query.search ? `%${req.query.search}%` : null;
    const limit = req.query.limit ? Number(req.query.limit) : 20;
    const cards = await visitorRepo.getAvailableCardStock(search, limit);
    res.json({ success: true, cards });
  } catch (error) {
    logger.error("Get available RFID cards error:", error);
    if (error?.code === "42P01") {
      return res.status(500).json({
        success: false,
        error: "rfid_cards_stock table is missing. Run migration 003_add_rfid_cards_stock.sql",
      });
    }
    res.status(500).json({ success: false, error: error.message });
  }
};

export const issueRFIDCard = async (req, res) => {
  try {
    const { visitor_id: paramVisitorId } = req.params;
    const { visitor_id: bodyVisitorId, issue_date, expiry_date, card_uid } = req.body;
    const visitor_id = bodyVisitorId || paramVisitorId;

    if (!visitor_id) {
      return res.status(400).json({ success: false, error: "visitor_id required" });
    }
    if (!card_uid) {
      return res.status(400).json({ success: false, error: "card_uid required" });
    }

    const stockCard = await visitorRepo.getCardStockByUid(card_uid);
    if (!stockCard) {
      return res.status(404).json({ success: false, error: "RFID card not found in stock" });
    }
    if (stockCard.status !== "AVAILABLE") {
      return res.status(400).json({ success: false, error: "RFID card is not available" });
    }

    const existingActive = await visitorRepo.getActiveRFIDCardByVisitor(visitor_id);
    if (existingActive) {
      await visitorRepo.updateRFIDCardById(existingActive.id, { card_status: "INACTIVE" });
      if (existingActive.card_uid) {
        try {
          await visitorRepo.markCardStockAvailable(existingActive.card_uid);
        } catch (error) {
          if (error?.code !== "42P01") throw error;
        }
      }
    }

    const qr_code = card_uid;

    // card_uid is unique in rfid_cards. Reuse existing row if present.
    const existingCardRecord = await visitorRepo.getRFIDCardAnyByUID(card_uid);
    const rfidCard = existingCardRecord
      ? await visitorRepo.updateRFIDCardById(existingCardRecord.id, {
          visitor_id,
          qr_code,
          issue_date,
          expiry_date,
          card_status: "ACTIVE",
        })
      : await visitorRepo.createRFIDCard(
          visitor_id,
          card_uid,
          qr_code,
          issue_date,
          expiry_date
        );
    await visitorRepo.markCardStockAssigned(card_uid);

    // Sync to gate whitelist
    try {
      await visitorRepo.updateMasterWhitelist(visitor_id);
    } catch {
      // Ignore whitelist sync failures if biometric is missing.
    }

    res.json({
      success: true,
      message: "RFID card assigned successfully",
      rfidCard,
    });
  } catch (error) {
    logger.error("Issue RFID Card Error:", error);
    if (error?.code === "23505") {
      return res.status(400).json({
        success: false,
        error: "RFID card UID already exists and could not be reassigned",
      });
    }
    if (error?.code === "42P01") {
      return res.status(500).json({
        success: false,
        error: "rfid_cards_stock table is missing. Run migration 003_add_rfid_cards_stock.sql",
      });
    }
    res.status(500).json({ success: false, error: error.message });
  }
};

export const getRFIDCard = async (req, res) => {
  try {
    const { visitor_id } = req.params;
    const card = await visitorRepo.getActiveRFIDCardByVisitor(visitor_id);
    res.json({ success: true, rfidCard: card || null });
  } catch (error) {
    logger.error("Get RFID Card Error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};

export const updateRFIDCard = async (req, res) => {
  try {
    const { visitor_id } = req.params;
    const { issue_date, expiry_date, card_status } = req.body;
    const card = await visitorRepo.getActiveRFIDCardByVisitor(visitor_id);
    if (!card) {
      return res.status(404).json({ success: false, error: "RFID card not found" });
    }

    const updated = await visitorRepo.updateRFIDCardById(card.id, {
      issue_date,
      expiry_date,
      card_status,
    });

    if (updated?.card_status === "ACTIVE") {
      try {
        await visitorRepo.updateMasterWhitelist(visitor_id);
      } catch {
        // Ignore whitelist sync failures if biometric is missing.
      }
    } else {
      if (card.card_uid) {
        await visitorRepo.markCardStockAvailable(card.card_uid);
      }
      await visitorRepo.removeMasterWhitelist(visitor_id);
    }

    res.json({ success: true, message: "RFID card updated", rfidCard: updated });
  } catch (error) {
    logger.error("Update RFID Card Error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};

export const deleteRFIDCard = async (req, res) => {
  try {
    const { visitor_id } = req.params;
    const card = await visitorRepo.getActiveRFIDCardByVisitor(visitor_id);
    if (!card) {
      return res.status(404).json({ success: false, error: "RFID card not found" });
    }

    // Soft-delete to avoid FK issues with card audit/reissue logs
    await visitorRepo.updateRFIDCardById(card.id, { card_status: "INACTIVE" });
    if (card.card_uid) {
      try {
        await visitorRepo.markCardStockAvailable(card.card_uid);
      } catch (error) {
        if (error?.code !== "42P01") throw error;
      }
    }
    try {
      await visitorRepo.removeMasterWhitelist(visitor_id);
    } catch (error) {
      if (error?.code !== "42P01") throw error;
    }

    res.json({ success: true, message: "RFID card deleted" });
  } catch (error) {
    logger.error("Delete RFID Card Error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};

export const getBiometricByVisitor = async (req, res) => {
  try {
    const { visitor_id } = req.params;
    const biometric = await visitorRepo.getBiometric(visitor_id);
    res.json({ success: true, biometric: biometric || null });
  } catch (error) {
    logger.error("Get Biometric Error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};

export const updateBiometric = async (req, res) => {
  try {
    const { visitor_id } = req.params;
    const { biometric_data, algorithm = "SHA256" } = req.body;

    if (!biometric_data) {
      return res.status(400).json({ success: false, error: "Biometric data required" });
    }

    const current = await visitorRepo.getBiometric(visitor_id);
    if (!current) {
      return res.status(404).json({ success: false, error: "Biometric not found" });
    }

    const biometric_hash = encryption.hashBiometric(biometric_data);
    const updated = await visitorRepo.updateBiometricById(
      current.id,
      biometric_hash,
      algorithm
    );

    try {
      await visitorRepo.updateMasterWhitelist(visitor_id);
    } catch {
      // Ignore whitelist sync failure if RFID missing.
    }

    res.json({ success: true, message: "Biometric updated", biometric: updated });
  } catch (error) {
    logger.error("Update Biometric Error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};

export const deleteBiometric = async (req, res) => {
  try {
    const { visitor_id } = req.params;
    const current = await visitorRepo.getBiometric(visitor_id);
    if (!current) {
      return res.status(404).json({ success: false, error: "Biometric not found" });
    }

    await visitorRepo.deleteBiometricById(current.id);
    await visitorRepo.removeMasterWhitelist(visitor_id);

    res.json({ success: true, message: "Biometric deleted" });
  } catch (error) {
    logger.error("Delete Biometric Error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};

// =====================================================
// OFFLINE GATE SYNC (EDGE DEVICE)
// =====================================================

export const getSyncData = async (req, res) => {
  try {
    const { last_sync } = req.query;
    const lastSyncTime = last_sync
      ? new Date(last_sync)
      : new Date(Date.now() - 5 * 60 * 1000);

    const whitelist = await visitorRepo.getMasterWhitelistUpdates(lastSyncTime);

    res.json({
      success: true,
      sync_time: new Date(),
      records: whitelist.length,
      whitelist,
    });
  } catch (error) {
    logger.error("Sync Data Error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};
const validateVisitorDepartmentMapping = async (
  client,
  department_id,
  project_id,
  host_id
) => {

  // 1️⃣ Validate project belongs to department
  const projectCheck = await client.query(
    `SELECT id FROM projects
     WHERE id = $1 AND department_id = $2`,
    [project_id, department_id]
  );

  if (!projectCheck.rowCount) {
    throw new Error("Project does not belong to selected department");
  }

  // 2️⃣ Validate host belongs to department
  const hostCheck = await client.query(
    `SELECT id FROM hosts
     WHERE id = $1 AND department_id = $2`,
    [host_id, department_id]
  );

  if (!hostCheck.rowCount) {
    throw new Error("Host does not belong to selected department");
  }

  // 3️⃣ Validate host assigned to project
  const hostProjectCheck = await client.query(
    `SELECT 1
     FROM host_projects
     WHERE host_id = $1 AND project_id = $2`,
    [host_id, project_id]
  );

  if (!hostProjectCheck.rowCount) {
    throw new Error("Host is not assigned to this project");
  }

};

// =====================================================
// EXTEND DOCUMENT VALIDITY
// =====================================================
export const extendDocument = async (req, res) => {
  try {

    const { doc_id } = req.params
    const { expiry_date } = req.body

    if (!expiry_date) {
      return res.status(400).json({
        success: false,
        error: "expiry_date is required"
      })
    }

    const document = await visitorRepo.extendDocument(
      doc_id,
      expiry_date
    )

    if (!document) {
      return res.status(404).json({
        success: false,
        error: "Document not found"
      })
    }

    res.json({
      success: true,
      message: "Document expiry updated",
      document
    })

  } catch (error) {

    logger.error("Extend Document Error:", error)

    res.status(500).json({
      success: false,
      error: error.message
    })

  }
}

// =====================================================
// DELETE DOCUMENT
// =====================================================

export const deleteDocument = async (req, res) => {

  try {

    const { doc_id } = req.params

    const deleted = await visitorRepo.deleteDocument(doc_id)

    if (!deleted) {
      return res.status(404).json({
        success: false,
        error: "Document not found"
      })
    }

    res.json({
      success: true,
      message: "Document deleted successfully"
    })

  } catch (error) {

    logger.error("Delete Document Error:", error)

    if (error.code === "23503") {
      return res.status(400).json({
        success: false,
        error: "Document cannot be deleted because it is referenced in card_reissue_log"
      })
    }

    res.status(500).json({
      success: false,
      error: error.message
    })

  }

}
