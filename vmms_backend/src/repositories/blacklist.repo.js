import db from "../config/db.js";
import * as encryption from "../utils/encryption.util.js";

// =====================================================
// BLACKLIST OPERATIONS
// =====================================================

// -----------------------------------------------------
// Generic Check (Used in gate / visitor flow)
// -----------------------------------------------------
export const check = async (visitor) => {
  const aadhaar_hash = visitor.aadhaar
    ? encryption.hashAadhaarForBlacklist(visitor.aadhaar)
    : null;

  const phone = visitor.primary_phone || null;

  const query = `
    SELECT 1 FROM blacklist
    WHERE ($1::text IS NOT NULL AND aadhaar_hash = $1)
       OR ($2::text IS NOT NULL AND phone = $2)
    LIMIT 1;
  `;

  const result = await db.query(query, [aadhaar_hash, phone]);
  return result.rowCount > 0;
};

// -----------------------------------------------------
// Check by Aadhaar
// -----------------------------------------------------
export const checkByAadhaar = async (aadhaar) => {
  const aadhaar_hash = encryption.hashAadhaarForBlacklist(aadhaar);

  const query = `
    SELECT * FROM blacklist
    WHERE aadhaar_hash = $1
    LIMIT 1;
  `;

  const result = await db.query(query, [aadhaar_hash]);
  return result.rows[0] || null;
};

// -----------------------------------------------------
// Check by Phone
// -----------------------------------------------------
export const checkByPhone = async (phone) => {
  const query = `
    SELECT * FROM blacklist
    WHERE phone = $1
    LIMIT 1;
  `;

  const result = await db.query(query, [phone]);
  return result.rows[0] || null;
};

// -----------------------------------------------------
// Check by Biometric
// -----------------------------------------------------
export const checkByBiometric = async (biometric_hash) => {
  const query = `
    SELECT * FROM blacklist
    WHERE biometric_hash = $1
    LIMIT 1;
  `;

  const result = await db.query(query, [biometric_hash]);
  return result.rows[0] || null;
};

// -----------------------------------------------------
// Add to Blacklist
// -----------------------------------------------------
export const addToBlacklist = async (
  aadhaar,
  phone,
  biometric_hash,
  reason,
  block_type
) => {
  const aadhaar_hash = aadhaar
    ? encryption.hashAadhaarForBlacklist(aadhaar)
    : null;

  const query = `
    INSERT INTO blacklist (
      aadhaar_hash,
      phone,
      biometric_hash,
      reason,
      block_type
    )
    VALUES ($1, $2, $3, $4, $5)
    RETURNING *;
  `;

  const values = [
    aadhaar_hash || null,
    phone || null,
    biometric_hash || null,
    reason || null,
    block_type || null,
  ];

  const result = await db.query(query, values);
  return result.rows[0];
};

// -----------------------------------------------------
// Remove from Blacklist
// -----------------------------------------------------
export const removeFromBlacklist = async (id) => {
  const query = `
    DELETE FROM blacklist
    WHERE id = $1;
  `;
  await db.query(query, [id]);
};

// -----------------------------------------------------
// Get All Entries
// -----------------------------------------------------
export const getBlacklist = async () => {
  const query = `
    SELECT *
    FROM blacklist
    ORDER BY created_at DESC;
  `;

  const result = await db.query(query);
  return result.rows;
};

// -----------------------------------------------------
// Get Entry by ID
// -----------------------------------------------------
export const getBlacklistById = async (id) => {
  const query = `
    SELECT *
    FROM blacklist
    WHERE id = $1
    LIMIT 1;
  `;

  const result = await db.query(query, [id]);
  return result.rows[0] || null;
};