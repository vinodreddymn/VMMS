import db from "../config/db.js";
import logger from "../utils/logger.util.js";
/* =====================================================
   USER MANAGEMENT
===================================================== */

import bcrypt from "bcrypt";
export const createUser = async (req, res) => {
  try {
    const { username, password, full_name, phone, role_id } = req.body;

    if (!username || !password || !role_id) {
      return res.status(400).json({ message: "Username, password and role are required" });
    }

    // 🔐 Hash password
    const saltRounds = 10;
    const password_hash = await bcrypt.hash(password, saltRounds);

    const query = `
      INSERT INTO users (username, password_hash, full_name, phone, role_id, is_active)
      VALUES ($1, $2, $3, $4, $5, TRUE)
      RETURNING id, username, full_name, phone, role_id, is_active;
    `;

    const result = await db.query(query, [
      username,
      password_hash,
      full_name,
      phone,
      role_id,
    ]);

    logger.info(`User created: ${username}`);
    res.status(201).json({ success: true, user: result.rows[0] });
  } catch (error) {
    logger.error("Create user error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};

export const getUsers = async (req, res) => {
  try {
    const query = `
      SELECT u.*, r.role_name
      FROM users u
      LEFT JOIN roles r ON u.role_id = r.id
      ORDER BY u.created_at DESC;
    `;

    const result = await db.query(query);
    res.json({ success: true, users: result.rows });
  } catch (error) {
    logger.error("Get users error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};

export const updateUser = async (req, res) => {
  try {
    const { id } = req.params;
    const { full_name, phone, role_id, is_active } = req.body;

    await db.query(
      `UPDATE users
       SET full_name=$1,
           phone=$2,
           role_id=$3,
           is_active = COALESCE($4, is_active)
       WHERE id=$5`,
      [full_name, phone, role_id, is_active ?? null, id]
    );

    const result = await db.query(`
      SELECT u.*, r.role_name
      FROM users u
      LEFT JOIN roles r ON u.role_id = r.id
      WHERE u.id=$1
    `, [id]);

    res.json({ success: true, user: result.rows[0] });
  } catch (error) {
    logger.error("Update user error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};

export const deactivateUser = async (req, res) => {
  try {
    const { id } = req.params;

    const query = `
      UPDATE users
      SET is_active = FALSE
      WHERE id = $1
      RETURNING *;
    `;

    const result = await db.query(query, [id]);

    logger.warn(`User deactivated: ID ${id}`);
    res.json({ success: true, user: result.rows[0] });
  } catch (error) {
    logger.error("Deactivate user error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};

/* =====================================================
   PROJECT MANAGEMENT
   projects.department_id → departments.id
===================================================== */

export const createProject = async (req, res) => {
  try {
    const { project_name, department_id } = req.body;

    const query = `
      INSERT INTO projects (project_name, department_id, is_active)
      VALUES ($1, $2, TRUE)
      RETURNING *;
    `;

    const result = await db.query(query, [project_name, department_id]);

    res.status(201).json({ success: true, project: result.rows[0] });
  } catch (error) {
    logger.error("Create project error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};

export const getProjects = async (req, res) => {
  try {
    const query = `
      SELECT p.*, d.department_name
      FROM projects p
      LEFT JOIN departments d ON p.department_id = d.id
      WHERE p.is_active = TRUE
      ORDER BY p.project_name;
    `;

    const result = await db.query(query);
    res.json({ success: true, projects: result.rows });
  } catch (error) {
    logger.error("Get projects error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};



/* =====================================================
   HOST MANAGEMENT
   hosts.department_id → departments.id
   projects.department_id → departments.id
===================================================== */

const validateProjectsBelongToDepartment = async (client, department_id, project_ids) => {
  if (!project_ids || project_ids.length === 0) return true;

  const checkQuery = `
    SELECT id
    FROM projects
    WHERE id = ANY($1) AND department_id = $2;
  `;

  const result = await client.query(checkQuery, [project_ids, department_id]);

  if (result.rows.length !== project_ids.length) {
    throw new Error("One or more projects do not belong to the host's department");
  }

  return true;
};

export const createHost = async (req, res) => {
  const client = await db.connect();
  try {
    const { host_name, phone, email, department_id, project_ids = [] } = req.body;

    await client.query("BEGIN");

    // 🔒 Validate projects belong to department
    await validateProjectsBelongToDepartment(client, department_id, project_ids);

    const hostResult = await client.query(
      `INSERT INTO hosts (host_name, phone, email, department_id, is_active)
       VALUES ($1, $2, $3, $4, TRUE)
       RETURNING *`,
      [host_name, phone, email, department_id]
    );

    const host = hostResult.rows[0];

    for (const pid of project_ids) {
      await client.query(
        `INSERT INTO host_projects (host_id, project_id)
         VALUES ($1, $2)
         ON CONFLICT DO NOTHING`,
        [host.id, pid]
      );
    }

    await client.query("COMMIT");

    res.status(201).json({ success: true, host });
  } catch (error) {
    await client.query("ROLLBACK");
    logger.error("Create host error:", error);
    res.status(400).json({ success: false, error: error.message });
  } finally {
    client.release();
  }
};

export const getHosts = async (req, res) => {
  try {
    const query = `
      SELECT 
        h.id,
        h.host_name,
        h.phone,
        h.email,
        h.department_id,
        d.department_name,
        h.is_active,
        COALESCE(
          json_agg(
            json_build_object(
              'project_id', p.id,
              'project_name', p.project_name
            )
          ) FILTER (WHERE p.id IS NOT NULL),
          '[]'
        ) AS projects
      FROM hosts h
      LEFT JOIN departments d ON h.department_id = d.id
      LEFT JOIN host_projects hp ON hp.host_id = h.id
      LEFT JOIN projects p ON hp.project_id = p.id
      WHERE h.is_active = TRUE
      GROUP BY h.id, d.department_name
      ORDER BY h.host_name;
    `;

    const result = await db.query(query);

    res.json({ success: true, hosts: result.rows });
  } catch (error) {
    logger.error("Get hosts error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};

export const updateHost = async (req, res) => {
  const client = await db.connect();
  try {
    const { id } = req.params;
    const { host_name, phone, email, department_id, is_active, project_ids = [] } = req.body;

    await client.query("BEGIN");

    await client.query(
      `UPDATE hosts
       SET host_name=$1,
           phone=$2,
           email=$3,
           department_id=$4,
           is_active = COALESCE($5, is_active)
       WHERE id=$6`,
      [host_name, phone, email, department_id, is_active ?? null, id]
    );

    // Remove old mappings
    await client.query(`DELETE FROM host_projects WHERE host_id=$1`, [id]);

    // Insert new mappings
    for (const pid of project_ids) {
      await client.query(
        `INSERT INTO host_projects (host_id, project_id)
         VALUES ($1, $2)
         ON CONFLICT DO NOTHING`,
        [id, pid]
      );
    }

    await client.query("COMMIT");

    // Return updated host with projects
    const result = await client.query(`
      SELECT 
        h.id,
        h.host_name,
        h.phone,
        h.email,
        h.department_id,
        d.department_name,
        h.is_active,
        COALESCE(
          json_agg(
            json_build_object(
              'project_id', p.id,
              'project_name', p.project_name
            )
          ) FILTER (WHERE p.id IS NOT NULL),
          '[]'
        ) AS projects
      FROM hosts h
      LEFT JOIN departments d ON h.department_id = d.id
      LEFT JOIN host_projects hp ON hp.host_id = h.id
      LEFT JOIN projects p ON hp.project_id = p.id
      WHERE h.id = $1
      GROUP BY h.id, d.department_name;
    `, [id]);

    res.json({ success: true, host: result.rows[0] });
  } catch (error) {
    await client.query("ROLLBACK");
    logger.error("Update host error:", error);
    res.status(500).json({ success: false, error: error.message });
  } finally {
    client.release();
  }
};

export const getHostProjects = async (req, res) => {
  try {
    const { id } = req.params;

    const query = `
      SELECT 
        p.id AS project_id,
        p.project_name,
        p.department_id,
        d.department_name
      FROM host_projects hp
      JOIN projects p ON hp.project_id = p.id
      LEFT JOIN departments d ON p.department_id = d.id
      WHERE hp.host_id = $1
      ORDER BY p.project_name;
    `;

    const result = await db.query(query, [id]);

    res.json({ success: true, projects: result.rows });
  } catch (error) {
    logger.error("Get host projects error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};

export const assignProjectsToHost = async (req, res) => {
  const client = await db.connect();
  try {
    const { id } = req.params;
    const { project_ids = [] } = req.body;

    await client.query("BEGIN");

    // Get host department
    const hostRes = await client.query(
      `SELECT department_id FROM hosts WHERE id = $1`,
      [id]
    );

    if (hostRes.rowCount === 0) {
      throw new Error("Host not found");
    }

    const department_id = hostRes.rows[0].department_id;

    // 🔒 Validate department match
    await validateProjectsBelongToDepartment(client, department_id, project_ids);

    for (const pid of project_ids) {
      await client.query(
        `INSERT INTO host_projects (host_id, project_id)
         VALUES ($1, $2)
         ON CONFLICT DO NOTHING`,
        [id, pid]
      );
    }

    await client.query("COMMIT");

    res.json({ success: true, message: "Projects assigned successfully" });
  } catch (error) {
    await client.query("ROLLBACK");
    logger.error("Assign projects error:", error);
    res.status(400).json({ success: false, error: error.message });
  } finally {
    client.release();
  }
};

export const removeProjectFromHost = async (req, res) => {
  try {
    const { id, projectId } = req.params;

    await db.query(
      `DELETE FROM host_projects
       WHERE host_id = $1 AND project_id = $2`,
      [id, projectId]
    );

    res.json({ success: true, message: "Project removed from host" });
  } catch (error) {
    logger.error("Remove project from host error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};

export const replaceHostProjects = async (req, res) => {
  const client = await db.connect();
  try {
    const { id } = req.params;
    const { project_ids = [] } = req.body;

    await client.query("BEGIN");

    // Fetch host department
    const hostRes = await client.query(
      `SELECT department_id FROM hosts WHERE id = $1`,
      [id]
    );

    if (hostRes.rowCount === 0) {
      throw new Error("Host not found");
    }

    const department_id = hostRes.rows[0].department_id;

    // 🔒 Validate
    await validateProjectsBelongToDepartment(client, department_id, project_ids);

    // Replace mappings
    await client.query(`DELETE FROM host_projects WHERE host_id = $1`, [id]);

    for (const pid of project_ids) {
      await client.query(
        `INSERT INTO host_projects (host_id, project_id)
         VALUES ($1, $2)`,
        [id, pid]
      );
    }

    await client.query("COMMIT");

    res.json({ success: true, message: "Host projects updated successfully" });
  } catch (error) {
    await client.query("ROLLBACK");
    logger.error("Replace host projects error:", error);
    res.status(400).json({ success: false, error: error.message });
  } finally {
    client.release();
  }
};

/* =====================================================
   GATE MANAGEMENT
   gates.entrance_id → entrances.id
===================================================== */

export const createGate = async (req, res) => {
  try {
    const { gate_name, entrance_id, ip_address, device_serial } = req.body;

    const query = `
      INSERT INTO gates (gate_name, entrance_id, ip_address, device_serial, is_active)
      VALUES ($1, $2, $3, $4, TRUE)
      RETURNING *;
    `;

    const result = await db.query(query, [gate_name, entrance_id, ip_address, device_serial]);

    res.status(201).json({ success: true, gate: result.rows[0] });
  } catch (error) {
    logger.error("Create gate error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};

export const getGates = async (req, res) => {
  try {
    const query = `
      SELECT g.*, e.entrance_name
      FROM gates g
      LEFT JOIN entrances e ON g.entrance_id = e.id
      WHERE g.is_active = TRUE
      ORDER BY g.gate_name;
    `;

    const result = await db.query(query);

    res.json({ success: true, gates: result.rows });
  } catch (error) {
    logger.error("Get gates error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};

/* =====================================================
   ROLE MANAGEMENT
   roles(id, role_name, can_export_pdf, can_export_excel)
===================================================== */

export const getRoles = async (req, res) => {
  try {
    const query = `
      SELECT id, role_name, can_export_pdf, can_export_excel
      FROM roles
      ORDER BY role_name;
    `;

    const result = await db.query(query);

    res.json({ success: true, roles: result.rows });
  } catch (error) {
    logger.error("Get roles error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};

export const createRole = async (req, res) => {
  try {
    const { role_name, can_export_pdf, can_export_excel } = req.body;

    const query = `
      INSERT INTO roles (role_name, can_export_pdf, can_export_excel)
      VALUES ($1, $2, $3)
      RETURNING *;
    `;

    const result = await db.query(query, [
      role_name,
      can_export_pdf || false,
      can_export_excel || false,
    ]);

    res.status(201).json({ success: true, role: result.rows[0] });
  } catch (error) {
    logger.error("Create role error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};

/* =====================================================
   PROJECT CRUD (ADD THESE)
===================================================== */

export const updateProject = async (req, res) => {
  try {
    const { id } = req.params;
    const { project_name, department_id, is_active } = req.body;

    const query = `
      UPDATE projects
      SET project_name = $1,
          department_id = $2,
          is_active = COALESCE($3, is_active)
      WHERE id = $4
      RETURNING *;
    `;

    const result = await db.query(query, [
      project_name,
      department_id,
      is_active ?? null,
      id,
    ]);

    res.json({ success: true, project: result.rows[0] });
  } catch (error) {
    logger.error("Update project error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};

export const deleteProject = async (req, res) => {
  try {
    const { id } = req.params;

    const query = `
      UPDATE projects
      SET is_active = FALSE
      WHERE id = $1
      RETURNING *;
    `;

    const result = await db.query(query, [id]);

    res.json({ success: true, project: result.rows[0] });
  } catch (error) {
    logger.error("Delete project error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};

/* =====================================================
   GATE UPDATE (ADD THIS)
===================================================== */

export const updateGate = async (req, res) => {
  try {
    const { id } = req.params;
    const { gate_name, entrance_id, ip_address, device_serial, is_active } = req.body;

    await db.query(
      `UPDATE gates
       SET gate_name=$1,
           entrance_id=$2,
           ip_address=$3,
           device_serial=$4,
           is_active = COALESCE($5, is_active)
       WHERE id=$6`,
      [gate_name, entrance_id, ip_address, device_serial, is_active ?? null, id]
    );

    const result = await db.query(`
      SELECT g.*, e.entrance_name
      FROM gates g
      LEFT JOIN entrances e ON g.entrance_id = e.id
      WHERE g.id = $1
    `, [id]);

    res.json({ success: true, gate: result.rows[0] });
  } catch (error) {
    logger.error("Update gate error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};
/* =====================================================
   ROLE UPDATE (ADD THIS)
===================================================== */

export const updateRole = async (req, res) => {
  try {
    const { id } = req.params;
    const { role_name, can_export_pdf, can_export_excel } = req.body;

    const query = `
      UPDATE roles
      SET role_name = $1,
          can_export_pdf = $2,
          can_export_excel = $3
      WHERE id = $4
      RETURNING *;
    `;

    const result = await db.query(query, [
      role_name,
      can_export_pdf,
      can_export_excel,
      id,
    ]);

    res.json({ success: true, role: result.rows[0] });
  } catch (error) {
    logger.error("Update role error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};

/* =====================================================
   DEPARTMENT MANAGEMENT
   departments(id, department_name, is_active)
===================================================== */

export const getDepartments = async (req, res) => {
  try {
    const query = `
      SELECT id, department_name, is_active, created_at
      FROM departments
      WHERE is_active = TRUE
      ORDER BY department_name;
    `

    const result = await db.query(query)
    res.json({ success: true, departments: result.rows })
  } catch (error) {
    logger.error("Get departments error:", error)
    res.status(500).json({ success: false, error: error.message })
  }
}

export const createDepartment = async (req, res) => {
  try {
    const { department_name } = req.body

    const query = `
      INSERT INTO departments (department_name, is_active)
      VALUES ($1, TRUE)
      RETURNING *;
    `

    const result = await db.query(query, [department_name])

    res.status(201).json({ success: true, department: result.rows[0] })
  } catch (error) {
    logger.error("Create department error:", error)
    res.status(500).json({ success: false, error: error.message })
  }
}

export const updateDepartment = async (req, res) => {
  try {
    const { id } = req.params;
    const { department_name, is_active } = req.body;

    const query = `
      UPDATE departments
      SET department_name = $1,
          is_active = COALESCE($2, is_active)
      WHERE id = $3
      RETURNING *;
    `;

    const result = await db.query(query, [
      department_name,
      is_active ?? null,
      id,
    ]);

    res.json({ success: true, department: result.rows[0] });
  } catch (error) {
    logger.error("Update department error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};

export const deleteDepartment = async (req, res) => {
  try {
    const { id } = req.params

    const query = `
      UPDATE departments
      SET is_active = FALSE
      WHERE id = $1
      RETURNING *;
    `

    const result = await db.query(query, [id])

    res.json({ success: true, department: result.rows[0] })
  } catch (error) {
    logger.error("Delete department error:", error)
    res.status(500).json({ success: false, error: error.message })
  }
}

/* =====================================================
   ENTRANCE MANAGEMENT
   entrances(id, entrance_code, entrance_name, is_main_gate)
===================================================== */

export const getEntrances = async (req, res) => {
  try {
    const query = `
      SELECT id, entrance_code, entrance_name, is_main_gate
      FROM entrances
      ORDER BY entrance_code;
    `

    const result = await db.query(query)

    res.json({ success: true, entrances: result.rows })
  } catch (error) {
    logger.error("Get entrances error:", error)
    res.status(500).json({ success: false, error: error.message })
  }
}

export const createEntrance = async (req, res) => {
  try {
    const { entrance_code, entrance_name, is_main_gate } = req.body

    const query = `
      INSERT INTO entrances (entrance_code, entrance_name, is_main_gate)
      VALUES ($1, $2, $3)
      RETURNING *;
    `

    const result = await db.query(query, [
      entrance_code,
      entrance_name,
      is_main_gate || false,
    ])

    res.status(201).json({ success: true, entrance: result.rows[0] })
  } catch (error) {
    logger.error("Create entrance error:", error)
    res.status(500).json({ success: false, error: error.message })
  }
}

export const updateEntrance = async (req, res) => {
  try {
    const { id } = req.params
    const { entrance_code, entrance_name, is_main_gate } = req.body

    const query = `
      UPDATE entrances
      SET entrance_code = $1,
          entrance_name = $2,
          is_main_gate = $3
      WHERE id = $4
      RETURNING *;
    `

    const result = await db.query(query, [
      entrance_code,
      entrance_name,
      is_main_gate,
      id,
    ])

    res.json({ success: true, entrance: result.rows[0] })
  } catch (error) {
    logger.error("Update entrance error:", error)
    res.status(500).json({ success: false, error: error.message })
  }
}

export const deleteEntrance = async (req, res) => {
  try {
    const { id } = req.params

    const query = `DELETE FROM entrances WHERE id = $1 RETURNING *;`
    const result = await db.query(query, [id])

    res.json({ success: true, entrance: result.rows[0] })
  } catch (error) {
    logger.error("Delete entrance error:", error)
    res.status(500).json({ success: false, error: error.message })
  }
}

/* =====================================================
   RFID STOCK ADMIN
===================================================== */

const parseUidInput = (value) => {
  if (Array.isArray(value)) {
    return value
      .map((uid) => String(uid || "").trim())
      .filter(Boolean);
  }

  return String(value || "")
    .split(/[\n,;\s]+/g)
    .map((uid) => uid.trim())
    .filter(Boolean);
};

const handleMissingTableError = (res, error, tableName) => {
  if (error?.code === "42P01" || error?.code === "42703") {
    return res.status(500).json({
      success: false,
      error: `${tableName} schema is outdated. Please run the latest migrations.`,
    });
  }
  return res.status(500).json({ success: false, error: error.message });
};

const ensureVisitorCardStockSchema = async () => {
  await db.query(`
    CREATE TABLE IF NOT EXISTS rfid_cards_stock (
      id BIGSERIAL PRIMARY KEY,
      uid VARCHAR(100) UNIQUE NOT NULL,
      status VARCHAR(20) NOT NULL DEFAULT 'AVAILABLE',
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
  `);
  await db.query(`ALTER TABLE rfid_cards_stock ADD COLUMN IF NOT EXISTS removed_reason TEXT`);
  await db.query(`ALTER TABLE rfid_cards_stock ADD COLUMN IF NOT EXISTS created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP`);
  await db.query(`ALTER TABLE rfid_cards_stock ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP`);
};

const ensureLabourTokenStockSchema = async () => {
  await db.query(`
    CREATE TABLE IF NOT EXISTS rfid_stock (
      id BIGSERIAL PRIMARY KEY,
      uid VARCHAR(100) UNIQUE NOT NULL,
      status VARCHAR(20) NOT NULL DEFAULT 'AVAILABLE',
      removed_reason TEXT,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
  `);
  await db.query(`ALTER TABLE rfid_stock ADD COLUMN IF NOT EXISTS removed_reason TEXT`);
  await db.query(`ALTER TABLE rfid_stock ADD COLUMN IF NOT EXISTS created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP`);
  await db.query(`ALTER TABLE rfid_stock ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP`);
};

export const getVisitorRFIDCardStock = async (req, res) => {
  try {
    await ensureVisitorCardStockSchema();
    const search = req.query.search ? `%${req.query.search}%` : null;
    const result = await db.query(
      `
      SELECT
        s.id,
        s.uid,
        s.status,
        COALESCE(s.removed_reason, '') AS removed_reason,
        s.created_at,
        s.updated_at,
        rc.visitor_id,
        v.pass_no AS visitor_pass_no,
        v.full_name AS visitor_name,
        v.company_name,
        (rc.id IS NOT NULL) AS assigned
      FROM rfid_cards_stock s
      LEFT JOIN rfid_cards rc
        ON rc.card_uid = s.uid
       AND rc.card_status = 'ACTIVE'
      LEFT JOIN visitors v
        ON v.id = rc.visitor_id
      WHERE (
        $1::text IS NULL
        OR s.uid ILIKE $1
        OR COALESCE(v.full_name, '') ILIKE $1
        OR COALESCE(v.pass_no, '') ILIKE $1
      )
      ORDER BY s.updated_at DESC NULLS LAST, s.created_at DESC NULLS LAST, s.id DESC
      LIMIT 1000
      `,
      [search]
    );

    res.json({ success: true, stock: result.rows });
  } catch (error) {
    logger.error("Get visitor RFID stock error:", error);
    return handleMissingTableError(res, error, "rfid_cards_stock");
  }
};

export const addVisitorRFIDCardStock = async (req, res) => {
  try {
    await ensureVisitorCardStockSchema();
    const uids = parseUidInput(req.body.uids || req.body.uid);
    if (!uids.length) {
      return res.status(400).json({ success: false, error: "At least one UID is required" });
    }

    const uniqueUids = [...new Set(uids)];
    const result = await db.query(
      `
      INSERT INTO rfid_cards_stock (uid, status, removed_reason, updated_at)
      SELECT x.uid, 'AVAILABLE', NULL, NOW()
      FROM unnest($1::text[]) AS x(uid)
      ON CONFLICT (uid) DO NOTHING
      RETURNING id, uid, status, removed_reason, created_at, updated_at
      `,
      [uniqueUids]
    );

    const skipped = uniqueUids.length - result.rowCount;
    res.status(201).json({
      success: true,
      inserted: result.rowCount,
      skipped,
      stock: result.rows,
    });
  } catch (error) {
    logger.error("Add visitor RFID stock error:", error);
    return handleMissingTableError(res, error, "rfid_cards_stock");
  }
};

export const markVisitorRFIDCardStockDamaged = async (req, res) => {
  try {
    await ensureVisitorCardStockSchema();
    const { id } = req.params;
    const reason = String(req.body.reason || "").trim();
    if (!reason) {
      return res.status(400).json({ success: false, error: "Reason is required" });
    }

    const assignmentCheck = await db.query(
      `
      SELECT rc.id
      FROM rfid_cards_stock s
      LEFT JOIN rfid_cards rc
        ON rc.card_uid = s.uid
       AND rc.card_status = 'ACTIVE'
      WHERE s.id = $1
      `,
      [id]
    );

    if (!assignmentCheck.rowCount) {
      return res.status(404).json({ success: false, error: "RFID stock item not found" });
    }

    if (assignmentCheck.rows[0].id) {
      return res.status(400).json({
        success: false,
        error: "RFID is currently assigned. Reassign/unassign first.",
      });
    }

    const result = await db.query(
      `
      UPDATE rfid_cards_stock
      SET status = 'DAMAGED',
          removed_reason = $2,
          updated_at = NOW()
      WHERE id = $1
        AND status = 'AVAILABLE'
      RETURNING id, uid, status, removed_reason, created_at, updated_at
      `,
      [id, reason]
    );

    if (!result.rowCount) {
      return res.status(400).json({
        success: false,
        error: "Only AVAILABLE RFID stock can be marked as damaged",
      });
    }

    res.json({ success: true, stock: result.rows[0] });
  } catch (error) {
    logger.error("Mark visitor RFID stock damaged error:", error);
    return handleMissingTableError(res, error, "rfid_cards_stock");
  }
};

export const getLabourRFIDStock = async (req, res) => {
  try {
    await ensureLabourTokenStockSchema();
    const search = req.query.search ? `%${req.query.search}%` : null;
    const result = await db.query(
      `
      SELECT
        s.id,
        s.uid,
        s.status,
        COALESCE(s.removed_reason, '') AS removed_reason,
        s.created_at,
        s.updated_at,
        lt.id AS token_id,
        lt.labour_id,
        l.full_name AS labour_name,
        l.supervisor_id,
        v.pass_no AS supervisor_pass_no,
        v.full_name AS supervisor_name,
        (lt.id IS NOT NULL) AS assigned
      FROM rfid_stock s
      LEFT JOIN labour_tokens lt
        ON lt.token_uid = s.uid
       AND lt.status = 'ACTIVE'
      LEFT JOIN labours l
        ON l.id = lt.labour_id
      LEFT JOIN visitors v
        ON v.id = l.supervisor_id
      WHERE (
        $1::text IS NULL
        OR s.uid ILIKE $1
        OR COALESCE(l.full_name, '') ILIKE $1
        OR COALESCE(v.full_name, '') ILIKE $1
      )
      ORDER BY s.updated_at DESC NULLS LAST, s.created_at DESC NULLS LAST, s.id DESC
      LIMIT 1000
      `,
      [search]
    );

    res.json({ success: true, stock: result.rows });
  } catch (error) {
    logger.error("Get labour RFID stock error:", error);
    return handleMissingTableError(res, error, "rfid_stock");
  }
};

export const addLabourRFIDStock = async (req, res) => {
  try {
    await ensureLabourTokenStockSchema();
    const uids = parseUidInput(req.body.uids || req.body.uid);
    if (!uids.length) {
      return res.status(400).json({ success: false, error: "At least one UID is required" });
    }

    const uniqueUids = [...new Set(uids)];
    const result = await db.query(
      `
      INSERT INTO rfid_stock (uid, status, removed_reason, updated_at)
      SELECT x.uid, 'AVAILABLE', NULL, NOW()
      FROM unnest($1::text[]) AS x(uid)
      ON CONFLICT (uid) DO NOTHING
      RETURNING id, uid, status, removed_reason, created_at, updated_at
      `,
      [uniqueUids]
    );

    const skipped = uniqueUids.length - result.rowCount;
    res.status(201).json({
      success: true,
      inserted: result.rowCount,
      skipped,
      stock: result.rows,
    });
  } catch (error) {
    logger.error("Add labour RFID stock error:", error);
    return handleMissingTableError(res, error, "rfid_stock");
  }
};

export const markLabourRFIDStockDamaged = async (req, res) => {
  try {
    await ensureLabourTokenStockSchema();
    const { id } = req.params;
    const reason = String(req.body.reason || "").trim();
    if (!reason) {
      return res.status(400).json({ success: false, error: "Reason is required" });
    }

    const assignmentCheck = await db.query(
      `
      SELECT lt.id
      FROM rfid_stock s
      LEFT JOIN labour_tokens lt
        ON lt.token_uid = s.uid
       AND lt.status = 'ACTIVE'
      WHERE s.id = $1
      `,
      [id]
    );

    if (!assignmentCheck.rowCount) {
      return res.status(404).json({ success: false, error: "RFID stock item not found" });
    }

    if (assignmentCheck.rows[0].id) {
      return res.status(400).json({
        success: false,
        error: "RFID token is currently assigned. Return token first.",
      });
    }

    const result = await db.query(
      `
      UPDATE rfid_stock
      SET status = 'DAMAGED',
          removed_reason = $2,
          updated_at = NOW()
      WHERE id = $1
        AND status = 'AVAILABLE'
      RETURNING id, uid, status, removed_reason, created_at, updated_at
      `,
      [id, reason]
    );

    if (!result.rowCount) {
      return res.status(400).json({
        success: false,
        error: "Only AVAILABLE RFID stock can be marked as damaged",
      });
    }

    res.json({ success: true, stock: result.rows[0] });
  } catch (error) {
    logger.error("Mark labour RFID stock damaged error:", error);
    return handleMissingTableError(res, error, "rfid_stock");
  }
};
