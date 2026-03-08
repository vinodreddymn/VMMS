import * as analyticsRepo from "../repositories/analytics.repo.js";
import PDFDocument from "pdfkit";
import ExcelJS from "exceljs";
import fs from "fs";
import path from "path";
import logger from "../utils/logger.util.js";
// =====================================================
// LIVE MUSTER REPORTS
// =====================================================

export const liveMuster = async (req, res) => {
  try {
    const data = await analyticsRepo.liveMuster();
    res.json({ success: true, data, count: data.length });
  } catch (error) {
    logger.error("Live muster error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};

// =====================================================
// PDF EXPORTS
// =====================================================

export const exportPDF = async (req, res) => {
  try {
    const { report_type, from_date, to_date } = req.query;
    const user = req.user;

    // Check RBAC
    if (!user.can_export_pdf) {
      return res.status(403).json({ success: false, error: "PDF export not allowed for your role" });
    }

    const doc = new PDFDocument();
    const filename = `${report_type}_${Date.now()}.pdf`;
    const filepath = path.join(process.cwd(), "exports", filename);

    // Ensure exports directory exists
    if (!fs.existsSync(path.dirname(filepath))) {
      fs.mkdirSync(path.dirname(filepath), { recursive: true });
    }

    doc.pipe(fs.createWriteStream(filepath));

    // Header
    doc.fontSize(16).text("VMMS REPORT", { align: "center" });
    doc.fontSize(10).text(`Generated: ${new Date().toLocaleString()}`, { align: "center" });
    doc.fontSize(10).text(`Report Type: ${report_type}`, { align: "center" });
    doc.moveDown();

    // Fetch data based on report type
    let data;
    if (report_type === "daily-stats") {
      data = await analyticsRepo.getDailyStats(from_date || new Date().toISOString().split("T")[0]);
      doc.fontSize(12).text("Daily Statistics");
      doc.moveDown();
      doc.fontSize(10).text(JSON.stringify(data, null, 2));
    } else if (report_type === "gate-load") {
      data = await analyticsRepo.getGateStats(from_date, to_date);
      doc.fontSize(12).text("Gate Load Statistics");
      doc.moveDown();
      data.forEach((gate) => {
        doc.fontSize(10).text(`${gate.gate_name}: ${gate.total_scans} scans`);
      });
    } else if (report_type === "project-stats") {
      data = await analyticsRepo.getProjectStats(from_date, to_date);
      doc.fontSize(12).text("Project Statistics");
      doc.moveDown();
      data.forEach((proj) => {
        doc.fontSize(10).text(`${proj.project_name}: ${proj.unique_entries} unique entries`);
      });
    }

    doc.end();

    doc.on("finish", () => {
      res.json({
        success: true,
        message: "PDF generated",
        download_url: `/exports/${filename}`,
      });
    });
  } catch (error) {
    logger.error("Export PDF error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};

// =====================================================
// EXCEL EXPORTS
// =====================================================

export const exportExcel = async (req, res) => {
  try {
    const { report_type, from_date, to_date } = req.query;
    const user = req.user;

    // Check RBAC
    if (!user.can_export_excel) {
      return res.status(403).json({ success: false, error: "Excel export not allowed for your role" });
    }

    const workbook = new ExcelJS.Workbook();

    if (report_type === "daily-stats") {
      const worksheet = workbook.addWorksheet("Daily Stats");
      const data = await analyticsRepo.getDailyStats(from_date || new Date().toISOString().split("T")[0]);

      worksheet.columns = [
        { header: "Metric", key: "metric", width: 30 },
        { header: "Value", key: "value", width: 15 },
      ];

      Object.entries(data).forEach(([key, value]) => {
        worksheet.addRow({ metric: key, value });
      });
    } else if (report_type === "gate-load") {
      const worksheet = workbook.addWorksheet("Gate Load");
      const data = await analyticsRepo.getGateStats(from_date, to_date);

      worksheet.columns = [
        { header: "Gate Name", key: "gate_name", width: 20 },
        { header: "Entrance", key: "entrance_name", width: 20 },
        { header: "Total Scans", key: "total_scans", width: 15 },
        { header: "Entries", key: "entries", width: 15 },
        { header: "Exits", key: "exits", width: 15 },
        { header: "Failed", key: "failed_scans", width: 15 },
      ];

      data.forEach((row) => {
        worksheet.addRow(row);
      });
    } else if (report_type === "failed-attempts") {
      const worksheet = workbook.addWorksheet("Failed Attempts");
      const data = await analyticsRepo.getFailedAttempts(from_date, to_date);

      worksheet.columns = [
        { header: "Date/Time", key: "scan_time", width: 20 },
        { header: "Visitor Name", key: "full_name", width: 25 },
        { header: "Gate", key: "gate_name", width: 20 },
        { header: "Error Code", key: "error_code", width: 15 },
      ];

      data.forEach((row) => {
        worksheet.addRow(row);
      });
    }

    const filename = `${report_type}_${Date.now()}.xlsx`;
    const filepath = path.join(process.cwd(), "exports", filename);

    // Ensure exports directory exists
    if (!fs.existsSync(path.dirname(filepath))) {
      fs.mkdirSync(path.dirname(filepath), { recursive: true });
    }

    await workbook.xlsx.writeFile(filepath);

    res.json({
      success: true,
      message: "Excel report generated",
      download_url: `/exports/${filename}`,
    });
  } catch (error) {
    logger.error("Export Excel error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};