import db from "../config/db.js";
import * as visitorRepo from "../repositories/visitor.repo.js";
import * as gateRepo from "../repositories/gate.repo.js";
import * as blacklistRepo from "../repositories/blacklist.repo.js";
import * as materialRepo from "../repositories/material.repo.js";
import smsService from "./sms.service.js";
import logger from "../utils/logger.util.js";
import { emitAccessEvent } from "../socket.js";
import { saveLivePhoto } from "../utils/live-photo.util.js";

class GateAuthService {
  async resolveGateId(requestedGateId) {
    if (requestedGateId !== undefined && requestedGateId !== null && requestedGateId !== "") {
      const byId = await db.query(
        `SELECT id FROM gates WHERE id = $1 AND is_active = TRUE LIMIT 1`,
        [requestedGateId]
      );
      if (byId.rows.length > 0) return byId.rows[0].id;
    }

    const fallback = await db.query(
      `SELECT id FROM gates WHERE is_active = TRUE ORDER BY id LIMIT 1`
    );
    return fallback.rows[0]?.id || null;
  }

  /**
   * Authenticate person at gate using RFID/Biometric
   * Implements Zero-Input model - no guard input required
   */
  async authenticate({ card_uid, gate_id, photo }) {
    try {
      const resolvedGateId = await this.resolveGateId(gate_id);
      if (!resolvedGateId) {
        return { status: "FAILED", error_code: "E104", error: "No active gate configured" };
      }

      const visitor = await visitorRepo.findByCard(card_uid);
      if (!visitor) {
        return { status: "FAILED", error_code: "E100" };
      }

      if (visitor.status !== "ACTIVE") {
        return { status: "FAILED", error_code: "E101" };
      }

      const blacklisted = await blacklistRepo.check(visitor);
      if (blacklisted) {
        const securityHead = await db.query(
          "SELECT * FROM users WHERE role_id = (SELECT id FROM roles WHERE role_name = 'SECURITY_HEAD') LIMIT 1"
        );

        if (securityHead.rows.length > 0) {
          await smsService.sendBlacklistAlertSMS(
            securityHead.rows[0].phone,
            visitor.full_name,
            "Blacklist match during gate access"
          );
        }

        return { status: "FAILED", error_code: "E102" };
      }

      const today = new Date().toISOString().split("T")[0];
      if (visitor.valid_to && visitor.valid_to < today) {
        return { status: "FAILED", error_code: "E103" };
      }

      // Gate permission check
      const allowedGates = await visitorRepo.getVisitorGatePermissions(visitor.id);
      const gateAllowed =
        !Array.isArray(allowedGates) ||
        allowedGates.length === 0 ||
        allowedGates.includes(resolvedGateId);

      if (!gateAllowed) {
        return {
          status: "FAILED",
          error_code: "E105",
          error: "Gate not permitted for this visitor",
          allowed_gates: allowedGates,
          gate_id: resolvedGateId,
        };
      }

      const lastLog = await gateRepo.getLastLog("VISITOR", visitor.id);
      const direction = lastLog?.direction === "IN" ? "OUT" : "IN";

      if (direction === "OUT") {
        const materialBalance = await materialRepo.getVisitorBalance(visitor.id);
        if (materialBalance.length > 0 && visitor.host_id) {
          const host = await db.query("SELECT * FROM hosts WHERE id = $1", [visitor.host_id]);
          if (host.rows.length > 0) {
            const materials = materialBalance
              .map((m) => `${m.balance}x Material ID: ${m.material_id}`)
              .join(", ");
            await smsService.sendMaterialBalanceAlertSMS(
              host.rows[0].phone,
              visitor.full_name,
              materials
            );
          }
        }
      }

      const { livePhotoPath } = photo
        ? await saveLivePhoto({
            personType: "VISITOR",
            personId: visitor.id,
            rfidUid: card_uid,
            gateId: resolvedGateId,
            photo,
          })
        : { livePhotoPath: null };

      const log = await gateRepo.insertAccessLog(
        "VISITOR",
        visitor.id,
        resolvedGateId,
        direction,
        "SUCCESS",
        null,
        livePhotoPath,
        false
      );

      /* REALTIME ANDON EVENT */

      const gateInfo = await gateRepo.getGate(resolvedGateId);

      // Fetch gate permissions (names) for the visitor to show on Andon popup
      const permRes = await db.query(
        `SELECT g.gate_name FROM visitor_gate_permissions vgp JOIN gates g ON g.id = vgp.gate_id WHERE vgp.visitor_id = $1`,
        [visitor.id]
      );
      const gatePermissions = permRes.rows.map((r) => r.gate_name);

      emitAccessEvent({
        person_type: "VISITOR",
        direction,
        pass_no: visitor.pass_no,
        full_name: visitor.full_name,
        phone: visitor.primary_phone,
        aadhaar_last4: visitor.aadhaar_last4,
        project_name: visitor.project_name,
        department_name: visitor.department_name,
        company_name: visitor.company_name,
        host_name: visitor.host_name,
        gate_id: resolvedGateId,
        gate_name: gateInfo?.gate_name || "Gate " + resolvedGateId,
        scan_time: log?.scan_time || new Date(),
        enrollment_photo_path: visitor.enrollment_photo_path,
        live_photo_path: log?.live_photo_path || null,
        access_log_id: log?.id || null,
        designation: visitor.designation,
        pass_valid_from: visitor.valid_from,
        pass_valid_to: visitor.valid_to,
        pass_valid_till: visitor.work_order_expiry,
        permissions: gatePermissions,
      });

      return {
        status: "SUCCESS",
        direction,
        name: visitor.full_name,
        aadhaar: visitor.aadhaar_last4,
        smartphone_allowed: visitor.smartphone_allowed,
        laptop_allowed: visitor.laptop_allowed,
        ops_area_permitted: visitor.ops_area_permitted,
        can_register_labours: visitor.can_register_labours,
        project_id: visitor.project_id,
        project_name: visitor.project_name,
        department_name: visitor.department_name,
        company_name: visitor.company_name,
        visitor_type_name: visitor.visitor_type_name,
        host_name: visitor.host_name,
        valid_from: visitor.valid_from,
        valid_to: visitor.valid_to,
        enrollment_photo_path: visitor.enrollment_photo_path,
        gate_id: resolvedGateId,
        visitor_id: visitor.id,
        allowed_gates: allowedGates,
      };
    } catch (error) {
      logger.error("Gate authentication error:", error);
      return { status: "FAILED", error_code: "E999" };
    }
  }

  /**
   * Authenticate labour token at gate
   */
  async authenticateLabourToken({ token_uid, gate_id, photo }) {
    try {
      const resolvedGateId = await this.resolveGateId(gate_id);
      if (!resolvedGateId) {
        return { status: "FAILED", error_code: "E204", error: "No active gate configured" };
      }

      const token = await db.query(
        `SELECT lt.*, l.full_name, l.supervisor_id FROM labour_tokens lt
         JOIN labours l ON lt.labour_id = l.id
         WHERE lt.token_uid = $1 AND lt.status = 'ACTIVE'`,
        [token_uid]
      );

      if (token.rows.length === 0) {
        return { status: "FAILED", error_code: "E200" };
      }

      const labourToken = token.rows[0];

      if (labourToken.valid_until && new Date(labourToken.valid_until) < new Date()) {
        return { status: "FAILED", error_code: "E201" };
      }

      const lastLog = await gateRepo.getLastLog("LABOUR", labourToken.labour_id);
      const direction = lastLog?.direction === "IN" ? "OUT" : "IN";
      const supervisor = await visitorRepo.findById(labourToken.supervisor_id);

      const { livePhotoPath } = photo
        ? await saveLivePhoto({
            personType: "LABOUR",
            personId: labourToken.labour_id,
            rfidUid: token_uid,
            gateId: resolvedGateId,
            photo,
          })
        : { livePhotoPath: null };

      const log = await gateRepo.insertAccessLog(
        "LABOUR",
        labourToken.labour_id,
        resolvedGateId,
        direction,
        "SUCCESS",
        null,
        livePhotoPath,
        false
      );

      const gateInfo = await gateRepo.getGate(resolvedGateId);

      emitAccessEvent({
        person_type: "LABOUR",
        direction,
        full_name: labourToken.full_name,
        supervisor_name: supervisor?.full_name || "-",
        supervisor_company: supervisor?.company_name || "-",
        supervisor_enrollment_photo_path: supervisor?.enrollment_photo_path || null,
        gate_id: resolvedGateId,
        gate_name: gateInfo?.gate_name || "Gate " + resolvedGateId,
        scan_time: log?.scan_time || new Date(),
        token_uid: labourToken.token_uid,
        live_photo_path: log?.live_photo_path || null,
        access_log_id: log?.id || null,
        pass_valid_to: labourToken.valid_until || null,
      });

      return {
        status: "SUCCESS",
        direction,
        name: labourToken.full_name,
        supervisor_name: supervisor?.full_name || "-",
        type: "LABOUR",
        labour_id: labourToken.labour_id,
        supervisor_id: labourToken.supervisor_id,
        valid_until: labourToken.valid_until,
        gate_id: resolvedGateId,
      };
    } catch (error) {
      logger.error("Labour token authentication error:", error);
      return { status: "FAILED", error_code: "E999" };
    }
  }

  /**
   * Get live muster count
   */
  async getLiveMuster() {
    try {
      const result = await db.query(`
        SELECT COUNT(*) as total_inside
        FROM (
          SELECT DISTINCT person_id
          FROM access_logs
          WHERE person_type = 'VISITOR'
          AND scan_time = (
            SELECT MAX(scan_time)
            FROM access_logs a2
            WHERE a2.person_id = access_logs.person_id
          )
          AND direction = 'IN'
        ) as inside
      `);

      return { totalInside: parseInt(result.rows[0].total_inside) };
    } catch (error) {
      logger.error("Live muster error:", error);
      return { totalInside: 0 };
    }
  }
}

export default new GateAuthService();
