import * as analyticsRepo from "../repositories/analytics.repo.js";
import logger from "../utils/logger.util.js";
import PDFDocument from "pdfkit";
// =====================================================
// LIVE MUSTER
// =====================================================

export const liveMuster = async (req, res) => {
  try {
    const date = req.query?.date;
    const muster = await analyticsRepo.liveMuster(date);
    res.json({ success: true, data: muster, count: muster.length });
  } catch (error) {
    logger.error("Live muster error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};

// =====================================================
// DAILY STATISTICS
// =====================================================

export const getDailyStats = async (req, res) => {
  try {
    const { from_date, to_date, date } = req.query;
    const today = new Date().toISOString().split("T")[0];
    const fromDate = from_date || date || today;
    const toDate = to_date || date || today;

    const stats = await analyticsRepo.getDailyStats(fromDate, toDate);
    res.json({ success: true, from_date: fromDate, to_date: toDate, stats });
  } catch (error) {
    logger.error("Daily stats error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};

export const peakHours = async (req, res) => {
  try {
    const { from_date, to_date } = req.query;

    const today = new Date().toISOString().split("T")[0];
    const fromDate = from_date || today;
    const toDate = to_date || today;

    const peakHours = await analyticsRepo.getPeakHours(fromDate, toDate);
    res.json({ success: true, peakHours });
  } catch (error) {
    logger.error("Peak hours error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};

// =====================================================
// GATE STATISTICS
// =====================================================

export const gateLoad = async (req, res) => {
  try {
    const { from_date, to_date } = req.query;

    const today = new Date().toISOString().split("T")[0];
    const fromDate = from_date || today;
    const toDate = to_date || today;

    const gateStats = await analyticsRepo.getGateStats(fromDate, toDate);
    res.json({ success: true, gateStats });
  } catch (error) {
    logger.error("Gate load error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};

// =====================================================
// PROJECT STATISTICS
// =====================================================

export const getProjectStats = async (req, res) => {
  try {
    const { from_date, to_date } = req.query;

    const today = new Date().toISOString().split("T")[0];
    const fromDate = from_date || new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString().split("T")[0]; // Last 30 days
    const toDate = to_date || today;

    const projectStats = await analyticsRepo.getProjectStats(fromDate, toDate);
    res.json({ success: true, projectStats });
  } catch (error) {
    logger.error("Project stats error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};

// =====================================================
// VISITOR SEARCH
// =====================================================

export const searchVisitors = async (req, res) => {
  try {
    const filters = req.query;
    const visitors = await analyticsRepo.searchVisitors(filters);
    res.json({ success: true, visitors, count: visitors.length });
  } catch (error) {
    logger.error("Search visitors error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};

// =====================================================
// FAILED ATTEMPTS
// =====================================================

export const getFailedAttempts = async (req, res) => {
  try {
    const { from_date, to_date, limit = 500 } = req.query;

    const today = new Date().toISOString().split("T")[0];
    const fromDate = from_date || today;
    const toDate = to_date || today;

    const failedAttempts = await analyticsRepo.getFailedAttempts(fromDate, toDate, limit);
    res.json({ success: true, failedAttempts, count: failedAttempts.length });
  } catch (error) {
    logger.error("Failed attempts error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};

// =====================================================
// BLACKLIST INCIDENTS
// =====================================================

export const getBlacklistIncidents = async (req, res) => {
  try {
    const { from_date, to_date } = req.query;

    const today = new Date().toISOString().split("T")[0];
    const fromDate = from_date || new Date(Date.now() - 90 * 24 * 60 * 60 * 1000).toISOString().split("T")[0]; // Last 90 days
    const toDate = to_date || today;

    const incidents = await analyticsRepo.getBlacklistIncidents(fromDate, toDate);
    res.json({ success: true, incidents, count: incidents.length });
  } catch (error) {
    logger.error("Blacklist incidents error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};

export const riskScoring = async (req, res) => {
  try {
    const { limit = 50, from_date, to_date } = req.query;
    const today = new Date().toISOString().split("T")[0];
    const fromDate = from_date || today;
    const toDate = to_date || today;

    const riskScores = await analyticsRepo.getRiskScores(fromDate, toDate, limit);
    res.json({ success: true, riskScores, count: riskScores.length, from_date: fromDate, to_date: toDate });
  } catch (error) {
    logger.error("Risk scoring error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};

export const visitorTrends = async (req, res) => {
  try {
    const { from_date, to_date } = req.query;

    const today = new Date().toISOString().split("T")[0];
    const fromDate = from_date || new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString().split("T")[0]; // Last 7 days
    const toDate = to_date || today;

    const trends = await analyticsRepo.getVisitorTrends(fromDate, toDate);
    res.json({ success: true, trends });
  } catch (error) {
    logger.error("Visitor trends error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};

// =====================================================
// GATE PERFORMANCE
// =====================================================

export const getGatePerformance = async (req, res) => {
  try {
    const { from_date, to_date } = req.query;

    const today = new Date().toISOString().split("T")[0];
    const fromDate = from_date || today;
    const toDate = to_date || today;

    const gatePerformance = await analyticsRepo.getGatePerformance(fromDate, toDate);
    res.json({ success: true, gatePerformance });
  } catch (error) {
    logger.error("Gate performance error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};

// =====================================================
// MATERIAL ANALYTICS
// =====================================================

export const getMaterialAnalytics = async (req, res) => {
  try {
    const { from_date, to_date } = req.query;

    const today = new Date().toISOString().split("T")[0];
    const fromDate = from_date || new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString().split("T")[0]; // Last 30 days
    const toDate = to_date || today;

    const materialAnalytics = await analyticsRepo.getMaterialAnalytics(fromDate, toDate);
    res.json({ success: true, materialAnalytics, count: materialAnalytics.length });
  } catch (error) {
    logger.error("Material analytics error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};

// =====================================================
// LABOUR ANALYTICS
// =====================================================

export const getLabourAnalytics = async (req, res) => {
  try {
    const { from_date, to_date } = req.query;

    const today = new Date().toISOString().split("T")[0];
    const fromDate = from_date || new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString().split("T")[0]; // Last 30 days
    const toDate = to_date || today;

    const labourAnalytics = await analyticsRepo.getLabourAnalytics(fromDate, toDate);
    res.json({ success: true, labourAnalytics, count: labourAnalytics.length });
  } catch (error) {
    logger.error("Labour analytics error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};

// =====================================================
// ACCESS LOG TRANSACTIONS
// =====================================================

export const getTransactions = async (req, res) => {
  try {
    const filters = req.query || {};
    const data = await analyticsRepo.getAccessTransactions(filters);
    res.json({ success: true, ...data });
  } catch (error) {
    logger.error("Get transactions error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};

export const exportTransactionsCsv = async (req, res) => {
  try {
    const user = req.user;
    if (!user.can_export_excel) {
      return res.status(403).json({ success: false, error: "CSV export not allowed for your role" });
    }

    const filters = { ...req.query, page: 1, limit: 5000 };
    const result = await analyticsRepo.getAccessTransactions(filters);
    const rows = result.rows || [];
    const personType = String(filters.person_type || "VISITOR").toUpperCase();

    let headers = [];
    if (personType === "LABOUR") {
      headers = [
        "scan_time",
        "direction",
        "status",
        "full_name",
        "phone",
        "supervisor_name",
        "project_name",
        "department_name",
        "gate_name",
        "token_uid",
        "entry_time",
        "error_code",
      ];
    } else {
      headers = [
        "scan_time",
        "direction",
        "status",
        "full_name",
        "pass_no",
        "primary_phone",
        "aadhaar_last4",
        "project_name",
        "department_name",
        "gate_name",
        "host_name",
        "entry_time",
        "error_code",
      ];
    }

    const escapeCsv = (value) => {
      if (value === null || value === undefined) return "";
      const s = String(value);
      if (/[",\n]/.test(s)) return `"${s.replace(/"/g, '""')}"`;
      return s;
    };

    const csvLines = [
      headers.join(","),
      ...rows.map((row) => headers.map((h) => escapeCsv(row[h])).join(",")),
    ];

    const filename = `transactions_${personType}_${Date.now()}.csv`;
    res.setHeader("Content-Type", "text/csv");
    res.setHeader("Content-Disposition", `attachment; filename="${filename}"`);
    res.send(csvLines.join("\n"));
  } catch (error) {
    logger.error("Export transactions CSV error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};

export const exportTransactionsPdf = async (req, res) => {
  try {
    const user = req.user;
    if (!user.can_export_pdf) {
      return res.status(403).json({ success: false, error: "PDF export not allowed for your role" });
    }

    const filters = { ...req.query, page: 1, limit: 1000 };
    const result = await analyticsRepo.getAccessTransactions(filters);
    const rows = result.rows || [];
    const personType = String(filters.person_type || "VISITOR").toUpperCase();

    const filename = `transactions_${personType}_${Date.now()}.pdf`;
    res.setHeader("Content-Type", "application/pdf");
    res.setHeader("Content-Disposition", `attachment; filename="${filename}"`);

    const doc = new PDFDocument({ margin: 30, size: "A4" });
    doc.pipe(res);

    doc.fontSize(16).text("VMMS TRANSACTION REPORT", { align: "center" });
    doc.moveDown(0.5);
    doc.fontSize(10).text(`Type: ${personType}`);
    doc.text(`Generated: ${new Date().toLocaleString()}`);
    doc.moveDown();

    const cols = personType === "LABOUR"
      ? [
          { key: "scan_time", label: "Scan Time", width: 90 },
          { key: "direction", label: "Dir", width: 30 },
          { key: "status", label: "Status", width: 40 },
          { key: "full_name", label: "Name", width: 120 },
          { key: "supervisor_name", label: "Supervisor", width: 90 },
          { key: "project_name", label: "Project", width: 90 },
        ]
      : [
          { key: "scan_time", label: "Scan Time", width: 90 },
          { key: "direction", label: "Dir", width: 30 },
          { key: "status", label: "Status", width: 40 },
          { key: "full_name", label: "Name", width: 120 },
          { key: "pass_no", label: "Pass", width: 60 },
          { key: "project_name", label: "Project", width: 90 },
        ];

    const startX = doc.x;
    let y = doc.y;
    doc.fontSize(9);
    cols.forEach((col) => {
      doc.text(col.label, startX + cols.slice(0, cols.indexOf(col)).reduce((a, c) => a + c.width, 0), y, { width: col.width });
    });
    y += 14;
    doc.moveTo(startX, y - 2).lineTo(startX + cols.reduce((a, c) => a + c.width, 0), y - 2).stroke();

    rows.forEach((row) => {
      if (y > 760) {
        doc.addPage();
        y = 40;
      }
      cols.forEach((col) => {
        const value = row[col.key] || "-";
        const x = startX + cols.slice(0, cols.indexOf(col)).reduce((a, c) => a + c.width, 0);
        doc.text(String(value), x, y, { width: col.width });
      });
      y += 12;
    });

    doc.end();
  } catch (error) {
    logger.error("Export transactions PDF error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};
