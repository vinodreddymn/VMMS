import db from "../config/db.js";
// =====================================================
// LIVE MUSTER
// =====================================================

export const liveMuster = async (date) => {
  const day = date || new Date().toISOString().split("T")[0];
  const result = await db.query(`
    WITH latest AS (
      SELECT
        person_type,
        person_id,
        MAX(scan_time) AS last_scan_time
      FROM access_logs
      WHERE person_type IN ('VISITOR', 'LABOUR')
        AND scan_time::DATE = $1::DATE
      GROUP BY person_type, person_id
    ),
    state AS (
      SELECT
        l.person_type,
        l.person_id,
        a.direction AS current_status,
        a.scan_time AS last_scan_time,
        a.gate_id
      FROM latest l
      JOIN access_logs a
        ON a.person_type = l.person_type
       AND a.person_id = l.person_id
       AND a.scan_time = l.last_scan_time
    )
    SELECT
      s.person_type,
      s.person_id,
      s.current_status,
      s.last_scan_time,
      ent.entry_time,
      g.gate_name,
      COALESCE(v.full_name, l.full_name) AS full_name,
      COALESCE(v.primary_phone, l.phone) AS phone,
      v.aadhaar_last4,
      COALESCE(pv.project_name, pl.project_name) AS project_name,
      v.designation,
      CASE WHEN s.person_type = 'LABOUR' THEN sup.full_name ELSE NULL END AS supervisor_name
    FROM state s
    LEFT JOIN gates g
      ON g.id = s.gate_id
    LEFT JOIN visitors v
      ON s.person_type = 'VISITOR'
     AND v.id = s.person_id
    LEFT JOIN projects pv
      ON pv.id = v.project_id
    LEFT JOIN labours l
      ON s.person_type = 'LABOUR'
     AND l.id = s.person_id
    LEFT JOIN visitors sup
      ON sup.id = l.supervisor_id
    LEFT JOIN projects pl
      ON pl.id = sup.project_id
    LEFT JOIN LATERAL (
      SELECT al.scan_time AS entry_time
      FROM access_logs al
      WHERE al.person_type = s.person_type
        AND al.person_id = s.person_id
        AND al.direction = 'IN'
        AND al.scan_time <= s.last_scan_time
      ORDER BY al.scan_time DESC
      LIMIT 1
      ) ent ON TRUE
    ORDER BY
      CASE WHEN s.current_status = 'IN' THEN 0 ELSE 1 END,
      s.last_scan_time DESC
  `, [day]);

  return result.rows;
};

// =====================================================
// DAILY STATISTICS
// =====================================================

export const getDailyStats = async (from_date, to_date) => {
  const query = `
    SELECT
      COUNT(*) FILTER (WHERE direction='IN') as total_entry_scans,
      COUNT(*) FILTER (WHERE direction='OUT') as total_exit_scans,
      COUNT(DISTINCT CASE WHEN direction='IN' THEN person_id END) as unique_entries,
      COUNT(DISTINCT CASE WHEN direction='OUT' THEN person_id END) as unique_exits,
      COUNT(*) FILTER (WHERE person_type='LABOUR' AND direction='IN') as labour_entry_scans,
      COUNT(*) FILTER (WHERE person_type='VISITOR' AND direction='IN') as visitor_entry_scans
    FROM access_logs
    WHERE scan_time::DATE BETWEEN $1::DATE AND $2::DATE
  `;

  const result = await db.query(query, [from_date, to_date]);
  return result.rows[0];
};

// =====================================================
// GATE-WISE STATISTICS
// =====================================================

export const getGateStats = async (from_date, to_date) => {
  const query = `
    SELECT
      g.id, g.gate_name, e.entrance_name,
      COUNT(*) as total_scans,
      COUNT(DISTINCT CASE WHEN direction='IN' THEN person_id END) as entries,
      COUNT(DISTINCT CASE WHEN direction='OUT' THEN person_id END) as exits,
      COUNT(DISTINCT CASE WHEN status='FAILED' THEN al.id END) as failed_scans
    FROM access_logs al
    JOIN gates g ON al.gate_id = g.id
    LEFT JOIN entrances e ON g.entrance_id = e.id
    WHERE al.scan_time::DATE >= $1::DATE AND al.scan_time::DATE <= $2::DATE
    GROUP BY g.id, g.gate_name, e.entrance_name
    ORDER BY total_scans DESC
  `;

  const result = await db.query(query, [from_date, to_date]);
  return result.rows;
};

// =====================================================
// PROJECT-WISE VISITOR STATISTICS
// =====================================================

export const getProjectStats = async (from_date, to_date) => {
  const query = `
    SELECT
      p.id, p.project_name,
      COUNT(DISTINCT v.id) as total_visitors_registered,
      COUNT(DISTINCT CASE WHEN al.direction='IN' THEN al.person_id END) as unique_entries,
      SUM(CASE WHEN al.direction='IN' THEN 1 ELSE 0 END) as total_entry_scans
    FROM projects p
    LEFT JOIN visitors v ON p.id = v.project_id
    LEFT JOIN access_logs al ON v.id = al.person_id AND al.person_type = 'VISITOR'
    WHERE (al.scan_time::DATE >= $1::DATE AND al.scan_time::DATE <= $2::DATE) OR al.scan_time IS NULL
    GROUP BY p.id, p.project_name
    ORDER BY total_entry_scans DESC
  `;

  const result = await db.query(query, [from_date, to_date]);
  return result.rows;
};

// =====================================================
// VISITOR SEARCH & FILTERING
// =====================================================

export const searchVisitors = async (filters) => {
  let query = `
    SELECT v.*, p.project_name, d.department_name, vt.type_name
    FROM visitors v
    LEFT JOIN projects p ON v.project_id = p.id
    LEFT JOIN departments d ON v.department_id = d.id
    LEFT JOIN visitor_types vt ON v.visitor_type_id = vt.id
    WHERE 1=1
  `;
  const values = [];
  let paramCount = 1;

  if (filters.name) {
    query += ` AND (v.first_name ILIKE $${paramCount} OR v.last_name ILIKE $${paramCount})`;
    values.push(`%${filters.name}%`);
    paramCount++;
  }

  if (filters.phone) {
    query += ` AND (v.primary_phone = $${paramCount} OR v.alternate_phone = $${paramCount})`;
    values.push(filters.phone);
    paramCount++;
  }

  if (filters.aadhaar_last4) {
    query += ` AND v.aadhaar_last4 = $${paramCount}`;
    values.push(filters.aadhaar_last4);
    paramCount++;
  }

  if (filters.project_id) {
    query += ` AND v.project_id = $${paramCount}`;
    values.push(filters.project_id);
    paramCount++;
  }

  if (filters.status) {
    query += ` AND v.status = $${paramCount}`;
    values.push(filters.status);
    paramCount++;
  }

  if (filters.from_date) {
    query += ` AND v.created_at >= $${paramCount}`;
    values.push(filters.from_date);
    paramCount++;
  }

  if (filters.to_date) {
    query += ` AND v.created_at <= $${paramCount}`;
    values.push(filters.to_date);
    paramCount++;
  }

  query += " ORDER BY v.created_at DESC LIMIT 500";

  const result = await db.query(query, values);
  return result.rows;
};

// =====================================================
// FAILED ACCESS ATTEMPTS
// =====================================================

export const getFailedAttempts = async (from_date, to_date, limit = 500) => {
  const query = `
    SELECT al.*, v.full_name, g.gate_name, e.entrance_name
    FROM access_logs al
    LEFT JOIN visitors v ON al.person_id = v.id AND al.person_type = 'VISITOR'
    JOIN gates g ON al.gate_id = g.id
    LEFT JOIN entrances e ON g.entrance_id = e.id
    WHERE al.status = 'FAILED'
    AND al.scan_time::DATE >= $1::DATE AND al.scan_time::DATE <= $2::DATE
    ORDER BY al.scan_time DESC
    LIMIT $3
  `;

  const result = await db.query(query, [from_date, to_date, limit]);
  return result.rows;
};

// =====================================================
// BLACKLIST INCIDENTS
// =====================================================

export const getBlacklistIncidents = async (from_date, to_date) => {
  const query = `
    SELECT
      bl.id, bl.aadhaar_hash, bl.phone, bl.reason, bl.created_at,
      COUNT(DISTINCT al.id) as attempt_count,
      MAX(al.scan_time) as last_attempt
    FROM blacklist bl
    LEFT JOIN biometric_match_audit bma ON bl.biometric_hash = bma.biometric_hash
    LEFT JOIN access_logs al ON bma.visitor_id = al.person_id
    WHERE bl.created_at::DATE >= $1::DATE AND bl.created_at::DATE <= $2::DATE
    GROUP BY bl.id
    ORDER BY attempt_count DESC
  `;

  const result = await db.query(query, [from_date, to_date]);
  return result.rows;
};

// =====================================================
// PEAK HOURS
// =====================================================

export const getPeakHours = async (from_date, to_date) => {
  const query = `
    SELECT
      EXTRACT(HOUR FROM scan_time)::integer as hour,
      COUNT(*) as total_scans,
      COUNT(DISTINCT CASE WHEN direction = 'IN' THEN person_id END) as entries,
      COUNT(DISTINCT CASE WHEN direction = 'OUT' THEN person_id END) as exits,
      COUNT(DISTINCT CASE WHEN status = 'FAILED' THEN id END) as failed_scans,
      ROUND(100.0 * COUNT(DISTINCT CASE WHEN status = 'FAILED' THEN id END) / NULLIF(COUNT(*), 0), 2) as failure_rate
    FROM access_logs
    WHERE scan_time::DATE >= $1::DATE AND scan_time::DATE <= $2::DATE
    GROUP BY EXTRACT(HOUR FROM scan_time)
    ORDER BY hour
  `;

  const result = await db.query(query, [from_date, to_date]);
  return result.rows;
};

// =====================================================
// RISK SCORING
// =====================================================

export const getRiskScores = async (from_date, to_date, limit = 50) => {
  const query = `
    WITH visitor_risk AS (
      SELECT
        v.id, v.full_name, v.aadhaar_last4, v.primary_phone,
        p.project_name,
        COALESCE(COUNT(DISTINCT CASE WHEN al.status = 'FAILED' THEN al.id END), 0) as failed_attempts,
        COALESCE(COUNT(DISTINCT CASE WHEN bma.match_score < 0.85 THEN bma.id END), 0) as low_biometric_matches,
        MAX(CASE WHEN bl.id IS NOT NULL THEN 1 ELSE 0 END) as is_blacklisted,
        COUNT(DISTINCT DATE(al.scan_time)) as days_accessed,
        MAX(al.scan_time) as last_access
      FROM visitors v
      LEFT JOIN projects p ON p.id = v.project_id
      LEFT JOIN access_logs al ON al.person_id = v.id AND al.person_type = 'VISITOR' AND al.scan_time::DATE BETWEEN $1::DATE AND $2::DATE
      LEFT JOIN biometric_match_audit bma ON bma.visitor_id = v.id AND bma.attempt_time::DATE BETWEEN $1::DATE AND $2::DATE
      LEFT JOIN blacklist bl ON bl.phone = v.primary_phone
      WHERE v.status = 'ACTIVE'
      GROUP BY v.id, p.project_name
    )
    SELECT
      id, full_name, aadhaar_last4, primary_phone, project_name,
      failed_attempts, low_biometric_matches, is_blacklisted,
      days_accessed, last_access,
      (is_blacklisted * 100 + failed_attempts * 10 + low_biometric_matches * 5) as risk_score,
      CASE
        WHEN is_blacklisted = 1 THEN 'CRITICAL'
        WHEN (is_blacklisted * 100 + failed_attempts * 10 + low_biometric_matches * 5) >= 50 THEN 'HIGH'
        WHEN (is_blacklisted * 100 + failed_attempts * 10 + low_biometric_matches * 5) >= 20 THEN 'MEDIUM'
        ELSE 'LOW'
      END as risk_level
    FROM visitor_risk
    WHERE (is_blacklisted = 1 OR failed_attempts > 0 OR low_biometric_matches > 0)
    ORDER BY risk_score DESC
    LIMIT $3
  `;

  const result = await db.query(query, [from_date, to_date, limit]);
  return result.rows;
};

// =====================================================
// VISITOR TRENDS
// =====================================================

export const getVisitorTrends = async (from_date, to_date) => {
  const query = `
    SELECT
      DATE(scan_time) as date,
      COUNT(DISTINCT CASE WHEN direction = 'IN' THEN person_id END) as unique_entries,
      COUNT(DISTINCT CASE WHEN direction = 'OUT' THEN person_id END) as unique_exits,
      SUM(CASE WHEN direction = 'IN' THEN 1 ELSE 0 END) as total_entry_scans,
      SUM(CASE WHEN direction = 'OUT' THEN 1 ELSE 0 END) as total_exit_scans,
      COUNT(DISTINCT CASE WHEN status = 'FAILED' THEN id END) as failed_attempts
    FROM access_logs
    WHERE scan_time::DATE >= $1::DATE AND scan_time::DATE <= $2::DATE AND person_type = 'VISITOR'
    GROUP BY DATE(scan_time)
    ORDER BY date
  `;

  const result = await db.query(query, [from_date, to_date]);
  return result.rows;
};

// =====================================================
// GATE PERFORMANCE
// =====================================================

export const getGatePerformance = async (from_date, to_date) => {
  const query = `
    SELECT
      g.id, g.gate_name, e.entrance_name,
      COUNT(*) as total_scans,
      COUNT(CASE WHEN al.status = 'SUCCESS' THEN 1 END) as successful_scans,
      COUNT(CASE WHEN al.status = 'FAILED' THEN 1 END) as failed_scans,
      ROUND(100.0 * COUNT(CASE WHEN al.status = 'SUCCESS' THEN 1 END) / NULLIF(COUNT(*), 0), 2) as success_rate,
      COUNT(DISTINCT al.error_code) as unique_error_types,
      STRING_AGG(DISTINCT error_code, ', ' ORDER BY error_code) as error_codes,
      MAX(al.scan_time) as last_activity
    FROM access_logs al
    JOIN gates g ON al.gate_id = g.id
    LEFT JOIN entrances e ON g.entrance_id = e.id
    WHERE al.scan_time::DATE >= $1::DATE AND al.scan_time::DATE <= $2::DATE
    GROUP BY g.id, g.gate_name, e.entrance_name
    ORDER BY failed_scans DESC
  `;

  const result = await db.query(query, [from_date, to_date]);
  return result.rows;
};

// =====================================================
// MATERIAL ANALYTICS
// =====================================================

export const getMaterialAnalytics = async (from_date, to_date) => {
  const query = `
    SELECT
      m.id,
      CONCAT_WS(' ', m.category, m.make, m.model, m.serial_number) AS material_label,
      m.category,
      COALESCE(SUM(CASE WHEN mt.direction = 'IN' THEN mt.quantity ELSE -mt.quantity END), 0) as current_stock,
      0 as min_threshold,
      0 as max_stock,
      COUNT(CASE WHEN mt.direction = 'IN' THEN 1 END) as inbound_count,
      COUNT(CASE WHEN mt.direction = 'OUT' THEN 1 END) as outbound_count,
      COALESCE(SUM(CASE WHEN mt.direction = 'IN' THEN mt.quantity ELSE 0 END),0) as total_inbound,
      COALESCE(SUM(CASE WHEN mt.direction = 'OUT' THEN mt.quantity ELSE 0 END),0) as total_outbound,
      CASE
        WHEN COALESCE(SUM(CASE WHEN mt.direction = 'IN' THEN mt.quantity ELSE -mt.quantity END), 0) <= 0 THEN 'CRITICAL'
        ELSE 'NORMAL'
      END as stock_status,
      MAX(mt.transaction_time) as last_transaction
    FROM materials m
    LEFT JOIN material_transactions mt ON m.id = mt.material_id 
      AND mt.transaction_time::DATE >= $1::DATE AND mt.transaction_time::DATE <= $2::DATE
    GROUP BY m.id, m.category, m.make, m.model, m.serial_number
    ORDER BY stock_status DESC, current_stock ASC
  `;

  const result = await db.query(query, [from_date, to_date]);
  return result.rows;
};

// =====================================================
// LABOUR ANALYTICS
// =====================================================

export const getLabourAnalytics = async (from_date, to_date) => {
  const query = `
    SELECT
      l.id, l.full_name, l.phone,
      COALESCE(sup.full_name, 'N/A') as supervisor_name,
      COALESCE(p.project_name, 'N/A') as project_name,
      COUNT(DISTINCT CASE WHEN al.direction = 'IN' THEN DATE(al.scan_time) END) as days_worked,
      COUNT(DISTINCT CASE WHEN al.direction = 'IN' THEN al.id END) as total_entries,
      COUNT(DISTINCT CASE WHEN al.direction = 'OUT' THEN al.id END) as total_exits,
      MAX(al.scan_time) as last_access,
      COUNT(CASE WHEN al.status = 'FAILED' THEN 1 END) as failed_attempts
    FROM labours l
    LEFT JOIN visitors sup ON sup.id = l.supervisor_id
    LEFT JOIN projects p ON p.id = sup.project_id
    LEFT JOIN access_logs al ON al.person_id = l.id AND al.person_type = 'LABOUR'
      AND al.scan_time::DATE >= $1::DATE AND al.scan_time::DATE <= $2::DATE
    GROUP BY l.id, l.full_name, l.phone, sup.full_name, p.project_name
    ORDER BY last_access DESC NULLS LAST
  `;

  const result = await db.query(query, [from_date, to_date]);
  return result.rows;
};

// =====================================================
// ACCESS LOG TRANSACTIONS (VISITOR / LABOUR)
// =====================================================

export const getAccessTransactions = async (filters = {}) => {
  const {
    person_type = "VISITOR",
    status,
    direction,
    person_id,
    supervisor_id,
    from_date,
    to_date,
    project_id,
    department_id,
    gate_id,
    q,
    page = 1,
    limit = 50,
  } = filters;

  const safeLimit = Math.min(Math.max(Number(limit) || 50, 1), 500);
  const safePage = Math.max(Number(page) || 1, 1);
  const offset = (safePage - 1) * safeLimit;

  const values = [];
  let i = 1;

  const where = [];

  if (person_type === "LABOUR") {
    where.push(`al.person_type = 'LABOUR'`);
  } else {
    where.push(`al.person_type = 'VISITOR'`);
  }

  if (status) {
    where.push(`al.status = $${i++}`);
    values.push(status);
  }

  if (direction) {
    where.push(`al.direction = $${i++}`);
    values.push(direction);
  }

  if (person_id) {
    if (person_type === "LABOUR") {
      where.push(`l.id = $${i++}`);
    } else {
      where.push(`v.id = $${i++}`);
    }
    values.push(person_id);
  }

  if (from_date) {
    where.push(`al.scan_time::DATE >= $${i++}::DATE`);
    values.push(from_date);
  }

  if (to_date) {
    where.push(`al.scan_time::DATE <= $${i++}::DATE`);
    values.push(to_date);
  }

  if (gate_id) {
    where.push(`al.gate_id = $${i++}`);
    values.push(gate_id);
  }

  const whereClause = where.length ? `WHERE ${where.join(" AND ")}` : "";

  if (person_type === "LABOUR") {
    if (project_id) {
      where.push(`p.id = $${i++}`);
      values.push(project_id);
    }
    if (department_id) {
      where.push(`d.id = $${i++}`);
      values.push(department_id);
    }
    if (supervisor_id) {
      where.push(`l.supervisor_id = $${i++}`);
      values.push(supervisor_id);
    }
    if (q) {
      where.push(`(
        l.full_name ILIKE $${i}
        OR l.phone ILIKE $${i}
        OR sup.full_name ILIKE $${i}
        OR COALESCE(lt.token_uid, '') ILIKE $${i}
      )`);
      values.push(`%${q}%`);
      i++;
    }
  } else {
    if (project_id) {
      where.push(`p.id = $${i++}`);
      values.push(project_id);
    }
    if (department_id) {
      where.push(`d.id = $${i++}`);
      values.push(department_id);
    }
    if (q) {
      where.push(`(
        v.full_name ILIKE $${i}
        OR v.pass_no ILIKE $${i}
        OR v.primary_phone ILIKE $${i}
        OR v.aadhaar_last4 ILIKE $${i}
      )`);
      values.push(`%${q}%`);
      i++;
    }
  }

  const finalWhere = where.length ? `WHERE ${where.join(" AND ")}` : "";

  let baseQuery = "";
  if (person_type === "LABOUR") {
    baseQuery = `
      FROM access_logs al
      LEFT JOIN labours l ON al.person_id = l.id AND al.person_type = 'LABOUR'
      LEFT JOIN visitors sup ON l.supervisor_id = sup.id
      LEFT JOIN projects p ON p.id = sup.project_id
      LEFT JOIN departments d ON d.id = sup.department_id
      LEFT JOIN gates g ON al.gate_id = g.id
      LEFT JOIN LATERAL (
        SELECT scan_time AS entry_time
        FROM access_logs ain
        WHERE ain.person_type = 'LABOUR'
          AND ain.person_id = l.id
          AND ain.direction = 'IN'
          AND ain.scan_time <= al.scan_time
        ORDER BY ain.scan_time DESC
        LIMIT 1
      ) ent ON TRUE
      LEFT JOIN LATERAL (
        SELECT token_uid
        FROM labour_tokens t
        WHERE t.labour_id = l.id
          AND t.assigned_date = al.scan_time::DATE
        ORDER BY t.id DESC
        LIMIT 1
      ) lt ON TRUE
      ${finalWhere}
    `;
  } else {
    baseQuery = `
      FROM access_logs al
      LEFT JOIN visitors v ON al.person_id = v.id AND al.person_type = 'VISITOR'
      LEFT JOIN projects p ON v.project_id = p.id
      LEFT JOIN departments d ON v.department_id = d.id
      LEFT JOIN hosts h ON v.host_id = h.id
      LEFT JOIN gates g ON al.gate_id = g.id
      LEFT JOIN LATERAL (
        SELECT scan_time AS entry_time
        FROM access_logs ain
        WHERE ain.person_type = 'VISITOR'
          AND ain.person_id = v.id
          AND ain.direction = 'IN'
          AND ain.scan_time <= al.scan_time
        ORDER BY ain.scan_time DESC
        LIMIT 1
      ) ent ON TRUE
      ${finalWhere}
    `;
  }

  const countQuery = `SELECT COUNT(*)::int AS total ${baseQuery}`;
  const countResult = await db.query(countQuery, values);
  const total = countResult.rows[0]?.total || 0;

  const dataQuery =
    person_type === "LABOUR"
      ? `
        SELECT
          al.id AS access_log_id,
          al.scan_time,
          al.direction,
          al.status,
          al.error_code,
          al.live_photo_path,
          al.gate_id,
          g.gate_name,
          l.id AS labour_id,
          l.full_name,
          l.phone,
          l.aadhaar_last4,
          sup.full_name AS supervisor_name,
          p.project_name,
          d.department_name,
          ent.entry_time,
          lt.token_uid
        ${baseQuery}
        ORDER BY al.scan_time DESC
        LIMIT $${i} OFFSET $${i + 1}
      `
      : `
        SELECT
          al.id AS access_log_id,
          al.scan_time,
          al.direction,
          al.status,
          al.error_code,
          al.live_photo_path,
          al.gate_id,
          g.gate_name,
          v.id AS visitor_id,
          v.full_name,
          v.pass_no,
          v.primary_phone,
          v.aadhaar_last4,
          p.project_name,
          d.department_name,
          h.host_name,
          ent.entry_time
        ${baseQuery}
        ORDER BY al.scan_time DESC
        LIMIT $${i} OFFSET $${i + 1}
      `;

  const dataValues = [...values, safeLimit, offset];
  const dataResult = await db.query(dataQuery, dataValues);

  return {
    rows: dataResult.rows || [],
    total,
    page: safePage,
    limit: safeLimit,
  };
};
