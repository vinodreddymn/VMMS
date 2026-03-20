import * as labourRepo from "../repositories/labour.repo.js";
import * as visitorRepo from "../repositories/visitor.repo.js";
import smsService from "../services/sms.service.js";
import PDFDocument from "pdfkit";
import QRCode from "qrcode";
import fs from "fs";
import path from "path";
import logger from "../utils/logger.util.js";
import * as encryption from "../utils/encryption.util.js";
import { getVisitorManifestPaths } from "../utils/visitor-storage.util.js";

// =====================================================
// HELPERS
// =====================================================

const formatManifestNumber = (manifest) => {
  const rawDate = manifest?.manifest_date;
  let datePart = "NA";

  if (rawDate instanceof Date && !Number.isNaN(rawDate.getTime())) {
    datePart = rawDate.toISOString().slice(0, 10).replace(/-/g, "");
  } else if (typeof rawDate === "string" && rawDate.trim()) {
    // Accept both ISO dates and datetime-like strings but keep only digits from date section
    const isoLike = rawDate.includes("T")
      ? rawDate.slice(0, 10)
      : rawDate.slice(0, 10);
    const digits = isoLike.replace(/\D/g, "");
    datePart = digits.length === 8 ? digits : "NA";
  }

  const idPart = String(manifest.id).padStart(6, "0");
  return `MF-${datePart}-${idPart}`;
};

const withManifestNumber = (manifest) => {
  if (!manifest) return manifest;
  return {
    ...manifest,
    manifest_number: formatManifestNumber(manifest),
  };
};

const resolveSupervisor = async (identifier) => {
  const value = String(identifier ?? "").trim();
  if (!value) return null;
  if (/^\d+$/.test(value)) {
    return visitorRepo.findById(value);
  }
  return visitorRepo.findByPassNo(value);
};

const buildManifestPdfToFile = async (manifest, labours, absoluteFilePath) => {

  await fs.promises.mkdir(path.dirname(absoluteFilePath), { recursive: true });

  const qrData = `Manifest: ${formatManifestNumber(manifest)}
Date: ${manifest.manifest_date}
Supervisor: ${manifest.supervisor_name}
Total Labours: ${labours.length}`;

  const qrImage = await QRCode.toDataURL(qrData, { margin: 1 });

  await new Promise((resolve, reject) => {

    const doc = new PDFDocument({
      size: "A5",
      layout: "landscape",
      margins: { top: 32, bottom: 0, left: 38, right: 38 }
    });

    const out = fs.createWriteStream(absoluteFilePath);
    doc.pipe(out);

    const startX = doc.page.margins.left;
    const usableWidth = doc.page.width - doc.page.margins.left - doc.page.margins.right;

    const rowHeight = 20;

    const drawLine = y => {
      doc.moveTo(startX, y)
        .lineTo(startX + usableWidth, y)
        .strokeColor("#666666")
        .lineWidth(0.8)
        .stroke();
    };

    /* ================= HEADER ================= */

    const drawLayout = () => {

      doc.rect(0, 0, doc.page.width, 30).fill("#ffffff");

      doc.fillColor("#000000")
        .font("Helvetica-Bold")
        .fontSize(11)
        .text(
          "INS RAJALI | LABOUR MANAGEMENT SYSTEM | DAILY LABOUR MANIFEST",
          startX,
          10,
          { width: usableWidth, align: "center" }
        );

      drawLine(30);

      /* ================= MANIFEST INFO ================= */

      const infoY = 40;

      const formattedDate = new Date(manifest.manifest_date).toLocaleDateString(
        "en-IN",
        { day: "2-digit", month: "short", year: "numeric" }
      );

      const generated = new Date().toLocaleString("en-IN", {
        day: "2-digit",
        month: "short",
        year: "numeric",
        hour: "2-digit",
        minute: "2-digit",
        hour12: true
      });

      doc.font("Helvetica")
        .fontSize(10)
        .fillColor("#1A1A1A")
        .text(
          `Manifest No: ${formatManifestNumber(manifest)} | Date: ${formattedDate} | Generated: ${generated}`,
          startX,
          infoY,
          { width: usableWidth, align: "center" }
        );

      drawLine(56);

      /* ================= SUPERVISOR + QR PANEL ================= */

      const boxTop = 66;
      const boxHeight = 100;

      const leftWidth = usableWidth * 0.75;
      const rightWidth = usableWidth - leftWidth;

      doc.rect(startX, boxTop, usableWidth, boxHeight)
        .strokeColor("#4D4D4D")
        .lineWidth(1)
        .stroke();

      doc.moveTo(startX + leftWidth, boxTop)
        .lineTo(startX + leftWidth, boxTop + boxHeight)
        .stroke();

      /* Supervisor */

      let y = boxTop + 10;

      doc.font("Helvetica-Bold")
        .fontSize(11)
        .fillColor("#000000")
        .text("SUPERVISOR DETAILS", startX + 12, y);

      y += 18;

      doc.font("Helvetica").fontSize(10).fillColor("#1A1A1A");

      const fields = [
        ["Name", manifest.supervisor_name],
        ["Pass No", manifest.supervisor_pass_no || "-"],
        ["Company", manifest.company_name || "-"],
        ["Project", manifest.project_name || "-"],
        ["Phone", manifest.primary_phone || "-"]
      ];

      fields.forEach(([label, value]) => {
        doc.text(`${label}: `, startX + 12, y, { continued: true })
          .font("Helvetica-Bold")
          .text(value);
        doc.font("Helvetica");
        y += 14;
      });

      /* QR Verification */

      /* QR Verification */

      const qrSize = 55;
      const qrTop = boxTop + 10;
      const qrX = startX + leftWidth + (rightWidth - qrSize) / 2;

      doc.image(qrImage, qrX, qrTop, { width: qrSize });

      const gap = 8; // space between QR and text

      doc.font("Helvetica-Bold")
        .fontSize(11)
        .fillColor("#000000")
        .text(
          `TOTAL LABOURS: ${labours.length}`,
          startX + leftWidth,
          qrTop + qrSize + gap,
          { width: rightWidth, align: "center" }
        );



      doc.y = boxTop + boxHeight + 8;

      drawLine(doc.y);

      return doc.y;
    };

    /* ================= TABLE PAGINATION ================= */

    const firstTableY = drawLayout();

    const availableHeight =
      doc.page.height -
      doc.page.margins.bottom -
      firstTableY -
      60;

    const rowsPerPage = Math.floor(availableHeight / rowHeight);
    const totalPages = Math.max(1, Math.ceil(labours.length / rowsPerPage));

    const columns = {
      sno: startX + 6,
      name: startX + 36,
      gender: startX + 180,
      age: startX + 224,
      phone: startX + 268,
      aadhaar: startX + 355,
      token: startX + 465
    };

    let labourIndex = 0;

    for (let page = 1; page <= totalPages; page++) {

      if (page > 1) {
        doc.addPage();
        drawLayout();
      }

      let y = doc.y;

      /* Table Header */

      doc.rect(startX, y, usableWidth, rowHeight)
        .fill("#FFFFFF")
        .stroke();

      doc.font("Helvetica-Bold").fontSize(10).fillColor("#000000");

      doc.text("S.No", columns.sno, y + 5);
      doc.text("Full Name", columns.name, y + 5);
      doc.text("Gender", columns.gender, y + 5);
      doc.text("Age", columns.age, y + 5);
      doc.text("Phone", columns.phone, y + 5);
      doc.text("Aadhaar No", columns.aadhaar, y + 5);
      doc.text("Token UID", columns.token, y + 5);

      y += rowHeight;

      doc.font("Helvetica").fontSize(9.6).fillColor("#000000");

      for (let i = 0; i < rowsPerPage && labourIndex < labours.length; i++) {

        const labour = labours[labourIndex];

        if (i % 2 === 1)
          doc.rect(startX, y, usableWidth, rowHeight).fill("#F0F0F0");

        doc.rect(startX, y, usableWidth, rowHeight).stroke();

        doc.fillColor("#000000");

        let aadhaarDisplay = "-";

        if (labour.aadhaar_encrypted) {
          try {
            aadhaarDisplay = encryption.decryptAadhaar(labour.aadhaar_encrypted);
          } catch {
            aadhaarDisplay = labour.aadhaar_last4
              ? `XXXX XXXX XXXX ${labour.aadhaar_last4}`
              : "-";
          }
        }

        doc.text(String(labourIndex + 1), columns.sno, y + 5);
        doc.text((labour.full_name || "-").substring(0, 32), columns.name, y + 5);
        doc.text(labour.gender || "-", columns.gender, y + 5);
        doc.text(labour.age != null ? String(labour.age) : "-", columns.age, y + 5);
        doc.text(labour.phone || "-", columns.phone, y + 5);
        doc.text(aadhaarDisplay, columns.aadhaar, y + 5);
        doc.text(labour.token_uid || "-", columns.token, y + 5);

        y += rowHeight;
        labourIndex++;
      }

      /* ================= SIGNATURES ================= */

      const sigY = y + 10;
      const sigWidth = usableWidth / 2 - 30;

      doc.fontSize(9).fillColor("#000000");

      doc.text("Supervisor Signature", startX, sigY);
      doc.moveTo(startX, sigY + 14).lineTo(startX + sigWidth, sigY + 14).stroke();

      const rightX = startX + usableWidth / 2 + 10;

      doc.text("Security Officer Signature", rightX, sigY);
      doc.moveTo(rightX, sigY + 14).lineTo(rightX + sigWidth, sigY + 14).stroke();

      /* ================= FOOTER ================= */

      doc.fontSize(8)
        .fillColor("#000000")
        .text(
          `Page ${page} of ${totalPages} • Confidential – For Official Use Only`,
          startX,
          doc.page.height - doc.page.margins.bottom - 10,
          { width: usableWidth, align: "center" }
        );
    }

    doc.end();

    out.on("finish", resolve);
    out.on("error", reject);

  });

};

const generateAndPersistManifestPdf = async (manifest_id) => {
  const manifest = await labourRepo.getManifest(manifest_id);
  if (!manifest) return null;

  const labours = await labourRepo.getManifestLabours(manifest_id);
  const manifestNumber = formatManifestNumber(manifest);
  const filename = `manifest_${manifestNumber}.pdf`;
  const { relativePosix, absolutePath } = await getVisitorManifestPaths(
    manifest.supervisor_id,
    filename
  );

  await buildManifestPdfToFile(manifest, labours, absolutePath);
  const updatedManifest = await labourRepo.signManifest(manifest_id, relativePosix);

  return withManifestNumber(updatedManifest);
};

// =====================================================
// LABOUR CONTROLLER
// =====================================================

export const createLabour = async (req, res) => {
  try {
    const { supervisor_id, full_name, phone, aadhaar, token_uid, gender, age } = req.body;
    const parsedAge =
      age === undefined || age === null || String(age).trim() === ""
        ? null
        : Number(age);
    const ageValue = Number.isFinite(parsedAge) ? parsedAge : null;

    // Validate supervisor permissions first
    const supervisor = await resolveSupervisor(supervisor_id);
    const canRegister =
      Boolean(supervisor?.can_register_labours) || Boolean(supervisor?.allows_labour);

    if (!supervisor || !canRegister) {
      return res.status(403).json({ success: false, error: "Supervisor not authorized to register labours" });
    }

    if (!token_uid) {
      return res.status(400).json({ success: false, error: "RFID token is required" });
    }

    // Validate RFID token before creating labour to avoid orphan records
    const stockToken = await labourRepo.getStockTokenByUid(token_uid);
    if (!stockToken) {
      return res.status(404).json({ success: false, error: "RFID token not found in stock" });
    }
    if (stockToken.status !== "AVAILABLE") {
      return res.status(400).json({ success: false, error: "RFID token is not available" });
    }

    // Create labour record
    const labour = await labourRepo.createLabour(
      supervisor.id,
      full_name,
      phone,
      aadhaar,
      gender ? String(gender).trim() : null,
      ageValue
    );

    // Assign token to labour (valid only today)
    const endOfToday = new Date();
    endOfToday.setHours(23, 59, 59, 999);

    const token = await labourRepo.assignToken(
      labour.id,
      stockToken.uid,
      new Date(),
      endOfToday
    );

    // Mark stock as assigned
    await labourRepo.markTokenAssigned(stockToken.uid);

    res.json({
      success: true,
      labour,
      token,
      message: `RFID Token ${stockToken.uid} assigned successfully`,
    });
  } catch (error) {
    logger.error("Create labour error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};

export const getBySupervisor = async (req, res) => {
  try {
    const { id } = req.params;
    const labours = await labourRepo.getLabours(id);
    res.json({ success: true, labours });
  } catch (error) {
    logger.error("Get labours error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};

// =====================================================
// MANIFEST MANAGEMENT
// =====================================================

export const createManifest = async (req, res) => {
  try {
    const { supervisor_id, labour_ids } = req.body;

    const supervisor = await resolveSupervisor(supervisor_id);
    if (!supervisor) {
      return res.status(404).json({ success: false, error: "Supervisor not found" });
    }

    let manifestLabourIds = [];
    if (Array.isArray(labour_ids) && labour_ids.length > 0) {
      manifestLabourIds = [...new Set(labour_ids.map((id) => Number(id)).filter(Boolean))];
    } else {
      // Auto-include only currently active token holders for this supervisor
      const supervisorLabours = await labourRepo.getLabours(supervisor.id);
      manifestLabourIds = supervisorLabours
        .filter((row) => row.token_uid)
        .map((row) => Number(row.id));
      manifestLabourIds = [...new Set(manifestLabourIds)];
    }

    if (!manifestLabourIds.length) {
      return res.status(400).json({
        success: false,
        error: "No active labours available to generate manifest",
      });
    }

    const today = new Date().toISOString().split("T")[0];
    const manifest = await labourRepo.createManifest(supervisor.id, today);

    for (const labour_id of manifestLabourIds) {
      await labourRepo.addLabourToManifest(manifest.id, labour_id);
    }

    const updatedManifest = await generateAndPersistManifestPdf(manifest.id);

    res.json({
      success: true,
      manifest: updatedManifest,
      message: "Manifest generated and saved as PDF",
    });
  } catch (error) {
    logger.error("Create manifest error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};

export const getTodayManifestBySupervisor = async (req, res) => {
  try {
    const { supervisor_id } = req.params;
    const today = new Date().toISOString().split("T")[0];

    const manifests = await labourRepo.getManifestsBySupervisor(supervisor_id, today);
    if (!manifests.length) {
      return res.json({ success: true, manifest: null });
    }

    res.json({ success: true, manifest: withManifestNumber(manifests[0]) });
  } catch (error) {
    logger.error("Get today manifest error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};

export const getManifest = async (req, res) => {
  try {
    const { manifest_id } = req.params;

    const manifest = await labourRepo.getManifest(manifest_id);
    const labours = await labourRepo.getManifestLabours(manifest_id);

    if (!manifest) {
      return res.status(404).json({ success: false, error: "Manifest not found" });
    }

    res.json({ success: true, manifest: withManifestNumber(manifest), labours });
  } catch (error) {
    logger.error("Get manifest error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};

export const getTodayManifestsBySupervisor = async (req, res) => {
  try {
    const { supervisor_id } = req.params;
    const today = new Date().toISOString().split("T")[0];

    const manifests = await labourRepo.getManifestsBySupervisor(supervisor_id, today);
    res.json({ success: true, manifests: manifests.map(withManifestNumber) });
  } catch (error) {
    logger.error("Get today manifests error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};

export const getManifestHistoryBySupervisor = async (req, res) => {
  try {
    const { supervisor_id } = req.params;
    const manifests = await labourRepo.getManifestsBySupervisor(supervisor_id, null);
    res.json({ success: true, manifests: manifests.map(withManifestNumber) });
  } catch (error) {
    logger.error("Get manifest history error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};

// =====================================================
// LABOUR ANALYTICS
// =====================================================

export const getLabourAnalytics = async (req, res) => {
  try {
    const { date } = req.query;
    
    if (!date) {
      return res.status(400).json({ success: false, error: "Date parameter is required" });
    }

    // Get all manifests for the given date
    const manifests = await labourRepo.getManifestsByDate(date);
    
    if (!manifests.length) {
      return res.json({
        success: true,
        manifests: [],
      });
    }

    // Enrich manifests with labour data
    const enrichedManifests = await Promise.all(
      manifests.map(async (manifest) => {
        const labours = await labourRepo.getManifestLabours(manifest.id);
        
        // Count attendance status
        const checked_in = labours.filter(l => l.is_checked_in).length;
        const checked_out = labours.filter(l => l.is_checked_out).length;
        const returned_tokens = labours.filter(l => l.token_returned).length;
        
        return {
          ...manifest,
          ...withManifestNumber(manifest),
          total_labours: labours.length,
          checked_in,
          checked_out,
          returned_tokens,
        };
      })
    );

    res.json({
      success: true,
      manifests: enrichedManifests,
    });
  } catch (error) {
    logger.error("Get labour analytics error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};

// =====================================================
// AVAILABLE TOKEN SEARCH
// =====================================================

export const getAvailableTokens = async (req, res) => {
  try {
    const search = req.query.search ? `%${req.query.search}%` : null;
    const limit = req.query.limit ? Number(req.query.limit) : 20;

    const tokens = await labourRepo.getAvailableTokens(search, limit);
    res.json({ success: true, tokens });
  } catch (error) {
    logger.error("Get available tokens error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};

// =====================================================
// TOKEN RETURN / DEREGISTRATION
// =====================================================

export const returnToken = async (req, res) => {
  try {
    const { token_uid, supervisor_id, manifest_id } = req.body;

    if (token_uid) {
      const token = await labourRepo.getActiveTokenByUID(token_uid);
      if (!token) {
        return res.status(404).json({ success: false, error: "Active token not found" });
      }

      const attendance = await labourRepo.getLabourAttendanceStatus(
        token.labour_id,
        token.assigned_date || null
      );
      if (attendance.is_inside) {
        return res.status(400).json({
          success: false,
          error: `Labour ${token.full_name} is checked-in. Token can be returned only after checkout.`,
        });
      }

      await labourRepo.deactivateToken(token.id);
      await labourRepo.markTokenAvailable(token_uid);

      const supervisorCleared = token.supervisor_id
        ? !(await labourRepo.hasActiveTokensForSupervisor(token.supervisor_id))
        : false;

      return res.json({
        success: true,
        message: `Token ${token_uid} returned and made AVAILABLE`,
        returned_count: 1,
        supervisor_cleared: supervisorCleared,
      });
    }

    let activeTokens = [];

    if (manifest_id) {
      activeTokens = await labourRepo.getActiveTokensByManifest(manifest_id);
    } else if (supervisor_id) {
      activeTokens = await labourRepo.getActiveTokensBySupervisor(supervisor_id);
    } else {
      return res.status(400).json({
        success: false,
        error: "Provide token_uid or supervisor_id or manifest_id",
      });
    }

    const returned = [];
    const blocked = [];

    for (const token of activeTokens) {
      const attendance = await labourRepo.getLabourAttendanceStatus(
        token.labour_id,
        token.assigned_date || null
      );

      if (attendance.is_inside) {
        blocked.push(token.token_uid);
        continue;
      }

      await labourRepo.deactivateToken(token.id);
      await labourRepo.markTokenAvailable(token.token_uid);
      returned.push(token.token_uid);
    }

    const supervisorCleared = supervisor_id
      ? !(await labourRepo.hasActiveTokensForSupervisor(supervisor_id))
      : false;

    res.json({
      success: true,
      returned_count: returned.length,
      blocked_count: blocked.length,
      blocked_tokens: blocked,
      supervisor_cleared: supervisorCleared,
      message: returned.length
        ? blocked.length
          ? `Returned ${returned.length} token(s). ${blocked.length} token(s) blocked until checkout.`
          : `Returned ${returned.length} token(s) successfully`
        : blocked.length
          ? `No tokens returned. ${blocked.length} token(s) are checked-in and must checkout first.`
          : "No active tokens found",
    });
  } catch (error) {
    logger.error("Return token error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};

export const forceCheckoutLabour = async (req, res) => {
  try {
    const { labour_id } = req.body;

    if (!labour_id) {
      return res.status(400).json({ success: false, error: "labour_id is required" });
    }

    const labour = await labourRepo.getLabourById(labour_id);
    if (!labour) {
      return res.status(404).json({ success: false, error: "Labour not found" });
    }

    // Insert OUT access log to mark labour as checked out
    await labourRepo.forceCheckoutLabour(labour_id);

    res.json({
      success: true,
      message: `Labour ${labour.full_name} has been force-checked out`,
      labour_id,
    });
  } catch (error) {
    logger.error("Force checkout labour error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};

// =====================================================
// PDF MANIFEST GENERATION
// =====================================================

export const generateManifestPDF = async (req, res) => {
  try {
    const { manifest_id } = req.params;

    let manifestRow = await labourRepo.getManifestById(manifest_id);
    if (!manifestRow) {
      return res.status(404).json({ success: false, error: "Manifest not found" });
    }

    if (!manifestRow.pdf_path) {
      const generated = await generateAndPersistManifestPdf(manifest_id);
      manifestRow = generated || manifestRow;
    }

    const relativePath = manifestRow.pdf_path;
    const absolutePath = path.join(process.cwd(), relativePath || "");

    if (!relativePath || !fs.existsSync(absolutePath)) {
      await generateAndPersistManifestPdf(manifest_id);
    }

    const latest = await labourRepo.getManifestById(manifest_id);
    const latestPath = path.join(process.cwd(), latest.pdf_path);

    return res.sendFile(latestPath);
  } catch (error) {
    logger.error("Generate manifest PDF error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};

// =====================================================
// NO-SHOW DETECTION SCHEDULED JOB
// =====================================================

export const checkNoShows = async (req, res) => {
  try {
    const noShows = await labourRepo.checkNoShows();

    for (const noShow of noShows) {
      const labour = await labourRepo.getLabourById(noShow.labour_id);
      const supervisor = await visitorRepo.findById(noShow.supervisor_id);

      if (supervisor && supervisor.primary_phone) {
        await smsService.sendNoShowAlertSMS(
          supervisor.primary_phone,
          labour.full_name
        );
      }
    }

    res.json({ success: true, noShowCount: noShows.length });
  } catch (error) {
    logger.error("Check no-shows error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};

export const validateTokenForGate = async (req, res) => {
  try {
    const { token_uid } = req.params;

    const record = await labourRepo.validateTokenForGateEntry(token_uid);

    if (!record) {
      return res.status(404).json({
        success: false,
        error: "Invalid or unauthorized token for entry",
      });
    }

    res.json({
      success: true,
      token: token_uid,
      manifest_id: record.manifest_id,
      message: "Token valid for gate entry",
    });
  } catch (error) {
    logger.error("Token validation error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};

// =====================================================
// UPDATE MANIFEST (SIGN / APPROVE)
// =====================================================

export const updateManifest = async (req, res) => {
  try {
    const { manifest_id } = req.params;
    const { signed } = req.body;

    const manifest = await labourRepo.getManifest(manifest_id);
    if (!manifest) {
      return res.status(404).json({
        success: false,
        error: "Manifest not found",
      });
    }

    const updatedManifest = await labourRepo.updateManifest(manifest_id, { signed });

    res.json({
      success: true,
      manifest: withManifestNumber(updatedManifest),
    });
  } catch (error) {
    logger.error("Update manifest error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};

export const getAllLabours = async (req, res) => {
  try {
    const labours = await labourRepo.getAllLabours();
    res.json({ success: true, labours });
  } catch (error) {
    logger.error("Get all labours error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};
