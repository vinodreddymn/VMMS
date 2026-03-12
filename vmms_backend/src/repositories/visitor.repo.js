import db from "../config/db.js";
import * as encryption from "../utils/encryption.util.js";
// =====================================================
// BASE SELECT WITH JOINS (Reusable)
// =====================================================
const BASE_SELECT = `
  SELECT 
    v.id,
    v.pass_no,
    v.first_name,
    v.last_name,
    v.full_name,
    v.designation,
    v.gender,
    v.company_name,
    v.company_address,
    v.primary_phone,
    v.alternate_phone,
    v.email,
    v.date_of_birth,
    v.blood_group,
    v.height_cm,
    v.visible_marks,
    v.temp_address,
    v.perm_address,
    v.work_order_no,
    v.work_order_expiry,
    v.police_verification_certificate_number,
    v.pvc_expiry,
    v.smartphone_allowed,
    v.smartphone_expiry,
    v.laptop_allowed,
    v.laptop_make,
    v.laptop_model,
    v.laptop_serial,
    v.laptop_expiry,
    v.ops_area_permitted,
    v.can_register_labours,
    v.valid_from,
    v.status,
    v.valid_to,
    v.vehicle_number,
    v.vehicle_make,
    v.vehicle_model,
    v.vehicle_color,
    v.enrollment_photo_path,
    v.project_id,
    v.department_id,
    v.host_id,
    v.visitor_type_id,
    vt.type_name AS visitor_type_name,
    vt.allows_labour,
    vt.is_internal,
    p.project_name,
    d.department_name,
    h.full_name AS host_name,
    rc.card_uid,
    rc.card_status,
    b.algorithm AS biometric_algorithm
  FROM visitors v
  LEFT JOIN visitor_types vt ON vt.id = v.visitor_type_id
  LEFT JOIN projects p ON p.id = v.project_id
  LEFT JOIN departments d ON d.id = v.department_id
  LEFT JOIN visitors h ON h.id = v.host_id
  LEFT JOIN rfid_cards rc 
    ON rc.visitor_id = v.id AND rc.card_status = 'ACTIVE'
  LEFT JOIN biometric_data b 
    ON b.visitor_id = v.id
`;

// =====================================================
// VISITOR CRUD
// =====================================================

export const create = async (data) => {
  const {
    visitor_type_id,
    pass_no,
    first_name,
    last_name,
    designation,
    gender,
    company_name,
    company_address,
    project_id,
    department_id,
    host_id,
    primary_phone,
    alternate_phone,
    email,
    date_of_birth,
    blood_group,
    height_cm,
    visible_marks,
    temp_address,
    perm_address,
    work_order_no,
    work_order_expiry,
    police_verification_certificate_number,
    pvc_expiry,
    aadhaar,
    entrance_id,
    smartphone_allowed,
    smartphone_expiry,
    laptop_allowed,
    laptop_make,
    laptop_model,
    laptop_serial,
    laptop_expiry,
    ops_area_permitted,
    valid_from,
    valid_to,
    enrollment_photo_path,
    can_register_labours,
    created_by,
  } = data;

  const toNull = (v) => (v === "" || v === undefined ? null : v);
  const toBoolOrNull = (v) => {
    if (v === "" || v === undefined || v === null) return null;
    if (typeof v === "boolean") return v;
    if (typeof v === "number") return v === 1 ? true : v === 0 ? false : null;
    if (typeof v === "string") {
      const s = v.trim().toLowerCase();
      if (["true", "t", "1", "yes", "y", "on"].includes(s)) return true;
      if (["false", "f", "0", "no", "n", "off"].includes(s)) return false;
    }
    return null;
  };
  const toIntOrNull = (v) => {
    const val = toNull(v);
    return val === null ? null : Number(val);
  };
  const toDateOrNull = (v) => toNull(v);

  const aadhaar_encrypted = encryption.encryptAadhaar(aadhaar);
  const aadhaar_last4 = aadhaar.slice(-4);
  const normalizedPassNo = pass_no?.trim();

  const query = `
    INSERT INTO visitors (
      visitor_type_id, pass_no, first_name, last_name, designation,
      gender,
      company_name, company_address, project_id, department_id, host_id,
      primary_phone, alternate_phone, email, date_of_birth, blood_group,
      height_cm, visible_marks, temp_address, perm_address,
      work_order_no, work_order_expiry,
      police_verification_certificate_number, pvc_expiry,
      aadhaar_encrypted, aadhaar_last4, entrance_id,
      smartphone_allowed, smartphone_expiry,
      laptop_allowed, laptop_make, laptop_model, laptop_serial, laptop_expiry,
      ops_area_permitted, valid_from, valid_to, enrollment_photo_path,
      vehicle_number, vehicle_make, vehicle_model, vehicle_color,
      created_by, can_register_labours, status
    ) VALUES (
      $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,
      $11,$12,$13,$14,$15,$16,$17,$18,$19,$20,
      $21,$22,$23,$24,$25,$26,$27,$28,$29,$30,
      $31,$32,$33,$34,$35,$36,$37,$38,$39,$40,
      $41,$42,$43,$44,$45,$46,'ACTIVE'
    ) RETURNING *;
  `;

  const values = [
    toIntOrNull(visitor_type_id),
    normalizedPassNo,
    first_name,
    last_name,
    designation,
    gender,
    company_name,
    company_address,
    toIntOrNull(project_id),
    toIntOrNull(department_id),
    toIntOrNull(host_id),
    primary_phone,
    alternate_phone,
    email,
    toDateOrNull(date_of_birth),
    blood_group,
    toIntOrNull(height_cm),
    visible_marks,
    temp_address,
    perm_address,
    work_order_no,
    toDateOrNull(work_order_expiry),
    police_verification_certificate_number,
    toDateOrNull(pvc_expiry),
    aadhaar_encrypted,
    aadhaar_last4,
    toIntOrNull(entrance_id),
    toBoolOrNull(smartphone_allowed) ?? false,
    toDateOrNull(smartphone_expiry),
    toBoolOrNull(laptop_allowed) ?? false,
    laptop_make,
    laptop_model,
    laptop_serial,
    toDateOrNull(laptop_expiry),
    toBoolOrNull(ops_area_permitted) ?? false,
    toDateOrNull(valid_from),
    toDateOrNull(valid_to),
    toNull(enrollment_photo_path),
    toNull(params.vehicle_number),
    toNull(params.vehicle_make),
    toNull(params.vehicle_model),
    toNull(params.vehicle_color),
    toIntOrNull(created_by),
    toBoolOrNull(can_register_labours) ?? false,
  ];

  const result = await db.query(query, values);
  return result.rows[0];
};

// =====================================================
// FIND ALL WITH FILTERS + JOINS
// =====================================================

export const findAll = async (filters = {}, pagination = {}) => {
  let where = `WHERE 1=1`;
  const values = [];
  let i = 1;
  const joinClause = `LEFT JOIN visitor_types vt ON vt.id = v.visitor_type_id`;

  if (filters.q) {
    where += ` AND (
      v.first_name ILIKE $${i}
      OR v.last_name ILIKE $${i}
      OR v.pass_no ILIKE $${i}
      OR v.company_name ILIKE $${i}
      OR v.primary_phone ILIKE $${i}
    )`;
    values.push(`%${filters.q}%`);
    i += 1;
  }

  if (filters.first_name) {
    where += ` AND v.first_name ILIKE $${i++}`;
    values.push(`%${filters.first_name}%`);
  }

  if (filters.pass_no) {
    where += ` AND v.pass_no = $${i++}`;
    values.push(filters.pass_no);
  }

  if (filters.project_id) {
    where += ` AND v.project_id = $${i++}`;
    values.push(filters.project_id);
  }

  if (filters.status) {
    where += ` AND v.status = $${i++}`;
    values.push(filters.status);
  }

  if (filters.primary_phone) {
    where += ` AND v.primary_phone = $${i++}`;
    values.push(filters.primary_phone);
  }

  if (filters.type) {
    where += ` AND vt.type_name = $${i}`;
    values.push(filters.type);
    i += 1;
  }

  const limit = Math.min(Number(pagination.limit) || 50, 500);
  const offset = Number(pagination.offset) || 0;

  // totals
  const countQuery = `SELECT COUNT(*) FROM visitors v ${joinClause} ${where}`;
  const countResult = await db.query(countQuery, values);
  const total = Number(countResult.rows[0]?.count || 0);

  // status & expiry aggregates (independent of pagination)
  const statsQuery = `
    SELECT
      COUNT(*)::int AS total,
      COUNT(*) FILTER (WHERE v.valid_to IS NULL)::int AS inactive,
      COUNT(*) FILTER (WHERE v.status = 'SOFT_LOCK')::int AS soft_lock,
      COUNT(*) FILTER (WHERE v.valid_to IS NOT NULL AND v.valid_to >= CURRENT_DATE)::int AS active,
      COUNT(*) FILTER (WHERE v.valid_to IS NOT NULL AND v.valid_to < CURRENT_DATE)::int AS expired,
      COUNT(*) FILTER (
        WHERE v.valid_to IS NOT NULL
          AND v.valid_to >= CURRENT_DATE
          AND v.valid_to <= CURRENT_DATE + INTERVAL '7 days'
      )::int AS expiring
    FROM visitors v
    ${joinClause}
    ${where}
  `;
  const statsResult = await db.query(statsQuery, values);
  const stats = statsResult.rows[0] || {};

  // visitor type counts (independent of pagination)
  const typeQuery = `
    SELECT COALESCE(vt.type_name, 'Unknown') AS type, COUNT(*)::int AS count
    FROM visitors v
    ${joinClause}
    ${where}
    GROUP BY 1
    ORDER BY 1
  `;
  const typeResult = await db.query(typeQuery, values);
  const typeCounts = typeResult.rows;

  // paged data
  const dataQuery = `${BASE_SELECT} ${where} ORDER BY v.created_at DESC LIMIT $${i} OFFSET $${i + 1}`;
  const dataValues = [...values, limit, offset];
  const result = await db.query(dataQuery, dataValues);

  return { rows: result.rows, total, limit, offset, stats, typeCounts };
};

// =====================================================
// FIND BY ID / PASS / CARD
// =====================================================

export const findById = async (id) => {
  const result = await db.query(`${BASE_SELECT} WHERE v.id = $1`, [id]);
  return result.rows[0];
};

export const findByPassNo = async (passNo) => {
  const result = await db.query(`${BASE_SELECT} WHERE v.pass_no = $1`, [passNo]);
  return result.rows[0];
};

export const findByCard = async (cardUid) => {
  const query = `
    ${BASE_SELECT}
    WHERE rc.card_uid = $1 AND rc.card_status = 'ACTIVE'
  `;
  const result = await db.query(query, [cardUid]);
  return result.rows[0];
};

// =====================================================
// SAFE UPDATE (Whitelist Columns)
// =====================================================

const ALLOWED_UPDATE_FIELDS = [
  "visitor_type_id",
  "project_id",
  "department_id",
  "host_id",
  "entrance_id",
  "first_name",
  "last_name",
  "designation",
  "gender",
  "company_name",
  "company_address",
  "primary_phone",
  "alternate_phone",
  "email",
  "date_of_birth",
  "blood_group",
  "height_cm",
  "visible_marks",
  "temp_address",
  "perm_address",
  "work_order_no",
  "work_order_expiry",
  "police_verification_certificate_number",
  "pvc_expiry",
  "status",
  "valid_from",
  "valid_to",
  "smartphone_allowed",
  "smartphone_expiry",
  "laptop_allowed",
  "laptop_make",
  "laptop_model",
  "laptop_serial",
  "laptop_expiry",
  "ops_area_permitted",
  "enrollment_photo_path",
  "can_register_labours",
];

export const update = async (id, updates) => {
  const keys = Object.keys(updates).filter((k) =>
    ALLOWED_UPDATE_FIELDS.includes(k)
  );

  if (!keys.length) return null;

  const toNull = (v) => (v === "" || v === undefined ? null : v);
  const toBoolOrNull = (v) => {
    if (v === "" || v === undefined || v === null) return null;
    if (typeof v === "boolean") return v;
    if (typeof v === "number") return v === 1 ? true : v === 0 ? false : null;
    if (typeof v === "string") {
      const s = v.trim().toLowerCase();
      if (["true", "t", "1", "yes", "y", "on"].includes(s)) return true;
      if (["false", "f", "0", "no", "n", "off"].includes(s)) return false;
    }
    return null;
  };
  const toIntOrNull = (v) => {
    const val = toNull(v);
    return val === null ? null : Number(val);
  };
  const toDateOrNull = (v) => toNull(v);

  const normalized = keys.map((k) => {
    const v = updates[k];
    if (
      k === "visitor_type_id" ||
      k === "project_id" ||
      k === "department_id" ||
      k === "host_id" ||
      k === "entrance_id" ||
      k === "height_cm"
    ) {
      return toIntOrNull(v);
    }
    if (
      k === "date_of_birth" ||
      k === "work_order_expiry" ||
      k === "pvc_expiry" ||
      k === "smartphone_expiry" ||
      k === "laptop_expiry" ||
      k === "valid_from" ||
      k === "valid_to"
    ) {
      return toDateOrNull(v);
    }
    if (
      k === "smartphone_allowed" ||
      k === "laptop_allowed" ||
      k === "ops_area_permitted" ||
      k === "can_register_labours"
    ) {
      return toBoolOrNull(v);
    }
    return toNull(v);
  });

  const setClause = keys.map((k, idx) => `${k}=$${idx + 2}`).join(", ");
  const values = [id, ...normalized];

  const query = `
    UPDATE visitors
    SET ${setClause}, updated_at = NOW()
    WHERE id = $1
    RETURNING *;
  `;

  const result = await db.query(query, values);
  return result.rows[0];
};

// =====================================================
// STATUS UPDATE WITH AUDIT
// =====================================================

export const updateStatus = async (visitorId, newStatus, changedBy, reason) => {
  const visitor = await findById(visitorId);

  await db.query(
    `INSERT INTO visitor_status_audit 
     (visitor_id, old_status, new_status, changed_by, reason)
     VALUES ($1,$2,$3,$4,$5)`,
    [visitorId, visitor.status, newStatus, changedBy, reason]
  );

  return update(visitorId, { status: newStatus });
};

// =====================================================
// DOCUMENTS
// =====================================================

export const addDocument = async (visitor_id, doc_type, doc_number, expiry_date, file_path) => {
  const result = await db.query(
    `INSERT INTO visitor_documents 
     (visitor_id, doc_type, doc_number, expiry_date, file_path)
     VALUES ($1,$2,$3,$4,$5) RETURNING *`,
    [visitor_id, doc_type, doc_number, expiry_date, file_path]
  );
  return result.rows[0];
};

export const getDocuments = async (visitor_id) => {
  const result = await db.query(
    `SELECT * FROM visitor_documents 
     WHERE visitor_id=$1 ORDER BY uploaded_at DESC`,
    [visitor_id]
  );
  return result.rows;
};

// =====================================================
// BIOMETRIC
// =====================================================

export const enrollBiometric = async (visitor_id, biometric_hash, algorithm = "SHA256") => {
  const result = await db.query(
    `INSERT INTO biometric_data (visitor_id, biometric_hash, algorithm)
     VALUES ($1,$2,$3) RETURNING *`,
    [visitor_id, biometric_hash, algorithm]
  );
  return result.rows[0];
};

export const getBiometric = async (visitor_id) => {
  const result = await db.query(
    `SELECT * FROM biometric_data 
     WHERE visitor_id=$1 ORDER BY enrolled_at DESC LIMIT 1`,
    [visitor_id]
  );
  return result.rows[0];
};

export const updateBiometricById = async (biometric_id, biometric_hash, algorithm = "SHA256") => {
  const result = await db.query(
    `UPDATE biometric_data
     SET biometric_hash = $2,
         algorithm = $3,
         enrolled_at = NOW()
     WHERE id = $1
     RETURNING *`,
    [biometric_id, biometric_hash, algorithm]
  );
  return result.rows[0];
};

export const deleteBiometricById = async (biometric_id) => {
  const result = await db.query(
    `DELETE FROM biometric_data
     WHERE id = $1
     RETURNING *`,
    [biometric_id]
  );
  return result.rows[0];
};

// =====================================================
// RFID
// =====================================================

export const createRFIDCard = async (visitor_id, card_uid, qr_code, issue_date, expiry_date) => {
  const result = await db.query(
    `INSERT INTO rfid_cards 
     (visitor_id, card_uid, qr_code, issue_date, expiry_date, card_status)
     VALUES ($1,$2,$3,$4,$5,'ACTIVE') RETURNING *`,
    [visitor_id, card_uid, qr_code, issue_date, expiry_date]
  );
  return result.rows[0];
};

export const getRFIDCardByUID = async (card_uid) => {
  const result = await db.query(
    `SELECT * FROM rfid_cards 
     WHERE card_uid=$1 AND card_status='ACTIVE'`,
    [card_uid]
  );
  return result.rows[0];
};

export const getRFIDCardAnyByUID = async (card_uid) => {
  const result = await db.query(
    `SELECT * FROM rfid_cards
     WHERE card_uid = $1
     LIMIT 1`,
    [card_uid]
  );
  return result.rows[0];
};

export const getRFIDCardByVisitor = async (visitor_id) => {
  const result = await db.query(
    `SELECT *
     FROM rfid_cards
     WHERE visitor_id = $1
     ORDER BY created_at DESC
     LIMIT 1`,
    [visitor_id]
  );
  return result.rows[0];
};

export const getActiveRFIDCardByVisitor = async (visitor_id) => {
  const result = await db.query(
    `SELECT *
     FROM rfid_cards
     WHERE visitor_id = $1
       AND card_status = 'ACTIVE'
     ORDER BY created_at DESC
     LIMIT 1`,
    [visitor_id]
  );
  return result.rows[0];
};

export const updateRFIDCardById = async (card_id, data = {}) => {
  const updates = [];
  const values = [card_id];
  let i = 2;

  if (data.issue_date !== undefined) {
    updates.push(`issue_date = $${i++}`);
    values.push(data.issue_date || null);
  }
  if (data.expiry_date !== undefined) {
    updates.push(`expiry_date = $${i++}`);
    values.push(data.expiry_date || null);
  }
  if (data.card_status !== undefined) {
    updates.push(`card_status = $${i++}`);
    values.push(data.card_status || null);
  }
  if (data.visitor_id !== undefined) {
    updates.push(`visitor_id = $${i++}`);
    values.push(data.visitor_id || null);
  }
  if (data.qr_code !== undefined) {
    updates.push(`qr_code = $${i++}`);
    values.push(data.qr_code || null);
  }

  if (!updates.length) return null;

  const result = await db.query(
    `UPDATE rfid_cards
     SET ${updates.join(", ")}
     WHERE id = $1
     RETURNING *`,
    values
  );
  return result.rows[0];
};

export const deleteRFIDCardById = async (card_id) => {
  const result = await db.query(
    `DELETE FROM rfid_cards
     WHERE id = $1
     RETURNING *`,
    [card_id]
  );
  return result.rows[0];
};

export const getCardStockByUid = async (uid) => {
  const result = await db.query(
    `SELECT *
     FROM rfid_cards_stock
     WHERE uid = $1
     LIMIT 1`,
    [uid]
  );
  return result.rows[0];
};

export const getAvailableCardStock = async (search, limit = 20) => {
  const result = await db.query(
    `SELECT uid
     FROM rfid_cards_stock
     WHERE status = 'AVAILABLE'
       AND ($1::text IS NULL OR uid::text ILIKE $1)
     ORDER BY uid
     LIMIT $2`,
    [search, limit]
  );
  return result.rows;
};

export const markCardStockAssigned = async (uid) => {
  await db.query(
    `UPDATE rfid_cards_stock
     SET status = 'ASSIGNED'
     WHERE uid = $1`,
    [uid]
  );
};

export const markCardStockAvailable = async (uid) => {
  await db.query(
    `UPDATE rfid_cards_stock
     SET status = 'AVAILABLE'
     WHERE uid = $1`,
    [uid]
  );
};

export const removeMasterWhitelist = async (visitor_id) => {
  await db.query(`DELETE FROM master_whitelist WHERE visitor_id = $1`, [visitor_id]);
};

// =====================================================
// MASTER WHITELIST SYNC
// =====================================================

export const updateMasterWhitelist = async (visitor_id) => {
  const visitor = await exports.findById(visitor_id);
  const rfid = await exports.getRFIDCardByUID(visitor.card_uid);
  const bio = await exports.getBiometric(visitor_id);

  if (!rfid || !bio) {
    throw new Error("Visitor must have RFID + Biometric enrolled");
  }

  const result = await db.query(
    `INSERT INTO master_whitelist
     (visitor_id, rfid_uid, biometric_hash,
      smartphone_allowed, laptop_allowed, ops_area_permitted, valid_until)
     VALUES ($1,$2,$3,$4,$5,$6,$7)
     ON CONFLICT (visitor_id) DO UPDATE SET
       rfid_uid=$2,
       biometric_hash=$3,
       smartphone_allowed=$4,
       laptop_allowed=$5,
       ops_area_permitted=$6,
       valid_until=$7,
       last_synced=NOW()
     RETURNING *`,
    [
      visitor_id,
      rfid.card_uid,
      bio.biometric_hash,
      visitor.smartphone_allowed,
      visitor.laptop_allowed,
      visitor.ops_area_permitted,
      visitor.valid_to,
    ]
  );

  return result.rows[0];
};

// =====================================================
// VISITOR GATE PERMISSIONS
// =====================================================

// Get gates assigned to visitor
export const getVisitorGatePermissions = async (visitor_id) => {
  const result = await db.query(
    `SELECT gate_id
     FROM visitor_gate_permissions
     WHERE visitor_id = $1`,
    [visitor_id]
  );

  return result.rows.map(r => r.gate_id);
};


// Set gate permissions (used during create)
export const setVisitorGatePermissions = async (
  visitor_id,
  gateIds = [],
  client = db
) => {

  if (!gateIds.length) return;

  const values = gateIds
    .map((_, i) => `($1,$${i + 2})`)
    .join(",");

  await client.query(
    `INSERT INTO visitor_gate_permissions (visitor_id, gate_id)
     VALUES ${values}
     ON CONFLICT (visitor_id, gate_id) DO NOTHING`,
    [visitor_id, ...gateIds]
  );
};


// Update gate permissions (used during update)
export const updateVisitorGatePermissions = async (
  visitor_id,
  gateIds = []
) => {

  const client = await db.connect();

  try {

    await client.query("BEGIN");

    await client.query(
      `DELETE FROM visitor_gate_permissions
       WHERE visitor_id = $1`,
      [visitor_id]
    );

    if (gateIds.length) {

      const values = gateIds
        .map((_, i) => `($1,$${i + 2})`)
        .join(",");

      await client.query(
        `INSERT INTO visitor_gate_permissions (visitor_id, gate_id)
         VALUES ${values}`,
        [visitor_id, ...gateIds]
      );

    }

    await client.query("COMMIT");

  } catch (err) {

    await client.query("ROLLBACK");
    throw err;

  } finally {

    client.release();

  }
};

export const extendDocument = async (docId, expiryDate) => {

  const result = await db.query(
    `
    UPDATE visitor_documents
    SET expiry_date = $1
    WHERE id = $2
    RETURNING *
    `,
    [expiryDate, docId]
  )

  return result.rows[0]

}

export const deleteDocument = async (docId) => {

  const result = await db.query(
    `
    DELETE FROM visitor_documents
    WHERE id = $1
    RETURNING id
    `,
    [docId]
  )

  return result.rowCount > 0

}
