import db from "../config/db.js";
// =====================================================
// MATERIAL MANAGEMENT
// =====================================================

export const createMaterial = async (category, make, model, serial_number, description, is_returnable) => {
  const query = `
    INSERT INTO materials (category, make, model, serial_number, description, is_returnable)
    VALUES ($1, $2, $3, $4, $5, $6) RETURNING *;
  `;
  const result = await db.query(query, [category, make, model, serial_number, description, is_returnable]);
  return result.rows[0];
};

export const getMaterial = async (material_id) => {
  const query = "SELECT * FROM materials WHERE id = $1";
  const result = await db.query(query, [material_id]);
  return result.rows[0];
};

export const getAllMaterials = async () => {
  const query = "SELECT * FROM materials ORDER BY category, make";
  const result = await db.query(query);
  return result.rows;
};

// =====================================================
// MATERIAL TRANSACTIONS
// =====================================================

export const insertTransaction = async (visitor_id, material_id, quantity, direction) => {
  const query = `
    INSERT INTO material_transactions (visitor_id, material_id, quantity, direction, transaction_time)
    VALUES ($1, $2, $3, $4, NOW()) RETURNING *;
  `;
  const result = await db.query(query, [visitor_id, material_id, quantity, direction]);

  // Update balance
  await exports.updateBalance(visitor_id, material_id);

  return result.rows[0];
};

export const getTransactions = async (visitor_id) => {
  const query = `
    SELECT mt.*, m.category, m.make, m.model, m.serial_number
    FROM material_transactions mt
    JOIN materials m ON mt.material_id = m.id
    WHERE mt.visitor_id = $1
    ORDER BY mt.transaction_time DESC
  `;
  const result = await db.query(query, [visitor_id]);
  return result.rows;
};

// =====================================================
// MATERIAL BALANCE
// =====================================================

export const getBalance = async (visitor_id) => {
  const query = `
    SELECT mb.*, m.category, m.make, m.model
    FROM material_balance mb
    JOIN materials m ON mb.material_id = m.id
    WHERE mb.visitor_id = $1 AND mb.balance > 0
    ORDER BY m.category, m.make
  `;
  const result = await db.query(query, [visitor_id]);
  return result.rows;
};

export const updateBalance = async (visitor_id, material_id) => {
  const query = `
    INSERT INTO material_balance (visitor_id, material_id, balance, last_updated)
    SELECT $1, $2,
      SUM(CASE WHEN direction='IN' THEN quantity ELSE -quantity END),
      NOW()
    FROM material_transactions
    WHERE visitor_id = $1 AND material_id = $2
    ON CONFLICT (visitor_id, material_id) DO UPDATE SET
      balance = (
        SELECT SUM(CASE WHEN direction='IN' THEN quantity ELSE -quantity END)
        FROM material_transactions
        WHERE visitor_id = $1 AND material_id = $2
      ),
      last_updated = NOW()
    RETURNING *;
  `;
  const result = await db.query(query, [visitor_id, material_id]);
  return result.rows[0];
};

export const getVisitorBalance = async (visitor_id) => {
  const result = await db.query(
    `SELECT material_id,
     SUM(CASE WHEN direction='IN' THEN quantity ELSE -quantity END) as balance
     FROM material_transactions
     WHERE visitor_id=$1
     GROUP BY material_id
     HAVING SUM(CASE WHEN direction='IN' THEN quantity ELSE -quantity END) > 0`,
    [visitor_id]
  );
  return result.rows;
};

export const getPendingReturns = async () => {
  const query = `
    SELECT mb.*, v.id as visitor_id, v.full_name, v.host_id, h.phone as host_phone
    FROM material_balance mb
    JOIN visitors v ON mb.visitor_id = v.id
    JOIN hosts h ON v.host_id = h.id
    WHERE mb.balance > 0
    ORDER BY mb.last_updated DESC
  `;
  const result = await db.query(query);
  return result.rows;
};