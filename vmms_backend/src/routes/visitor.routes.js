import express from "express";
import * as controller from "../controllers/visitor.controller.js";
import auth from "../middleware/auth.middleware.js";
import multer from "multer";
import path from "path";
import {
  getVisitorDocumentsDestination,
  getVisitorPhotoDestination,
} from "../utils/visitor-storage.util.js";

const router = express.Router();

const makeFilename = (prefix, originalname) => {
  const ext = path.extname(originalname || "");
  const safeExt = ext && ext.length <= 10 ? ext : "";
  const stamp = Date.now();
  const rand = Math.floor(Math.random() * 1e9);
  return `${prefix}_${stamp}_${rand}${safeExt}`;
};

const documentStorage = multer.diskStorage({
  destination: async (req, _file, cb) => {
    try {
      const visitorId = req.params.visitor_id || req.body.visitor_id;
      if (!visitorId) return cb(new Error("visitor_id is required"));
      const destination = await getVisitorDocumentsDestination(visitorId);
      cb(null, destination);
    } catch (error) {
      cb(error);
    }
  },
  filename: (req, file, cb) => {
    cb(null, makeFilename("document", file.originalname));
  },
});

const photoStorage = multer.diskStorage({
  destination: async (req, _file, cb) => {
    try {
      const visitorId = req.params.visitor_id || req.body.visitor_id;
      if (!visitorId) return cb(new Error("visitor_id is required"));
      const destination = await getVisitorPhotoDestination(visitorId);
      cb(null, destination);
    } catch (error) {
      cb(error);
    }
  },
  filename: (_req, file, cb) => {
    cb(null, makeFilename("photo", file.originalname));
  },
});

const uploadDocument = multer({ storage: documentStorage });
const uploadPhoto = multer({ storage: photoStorage });

/* =====================================================
   VISITOR CRUD
===================================================== */
router.post("/", auth, controller.createVisitor);
router.get("/", auth, controller.getVisitors);

// IMPORTANT: specific routes before param routes
router.get("/sync/whitelist", controller.getSyncData);

/* =====================================================
   DOCUMENT MANAGEMENT (KYC)
===================================================== */
// Upload document
router.post(
  "/:visitor_id/documents",
  auth,
  uploadDocument.single("file"),
  controller.uploadDocument
);

// Get visitor documents
router.get("/:visitor_id/documents", auth, controller.getDocuments);
// Extend document validity
router.put("/visitor-documents/:doc_id/extend", auth, controller.extendDocument);

// Delete document
router.delete("/visitor-documents/:doc_id", auth, controller.deleteDocument);

/* =====================================================
   PHOTO UPLOAD
===================================================== */
router.post(
  "/:visitor_id/photo",
  auth,
  uploadPhoto.single("photo"),
  controller.uploadPhoto
);

/* =====================================================
   BIOMETRIC ENROLLMENT
===================================================== */
router.get("/:visitor_id/biometric", auth, controller.getBiometricByVisitor);
router.post("/:visitor_id/biometric", auth, controller.enrollBiometric);
router.put("/:visitor_id/biometric", auth, controller.updateBiometric);
router.delete("/:visitor_id/biometric", auth, controller.deleteBiometric);

/* =====================================================
   RFID CARD MANAGEMENT
===================================================== */
router.get("/rfid-cards/available", auth, controller.getAvailableRFIDCards);
router.get("/:visitor_id/rfid-card", auth, controller.getRFIDCard);
router.post("/:visitor_id/rfid-card", auth, controller.issueRFIDCard);
router.put("/:visitor_id/rfid-card", auth, controller.updateRFIDCard);
router.delete("/:visitor_id/rfid-card", auth, controller.deleteRFIDCard);

/* =====================================================
   VISITOR PROFILE (keep last to avoid conflicts)
===================================================== */
router.get("/:id", auth, controller.getVisitorById);
router.put("/:id", auth, controller.updateVisitor);

export default router;
