import db from "../config/db.js";
import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";
import env from "../config/env.js";
export const login = async (req, res) => {
  const { username, password } = req.body;

  const result = await db.query(
    `SELECT 
        u.id,
        u.username,
        u.password_hash,
        u.role_id,
        r.role_name,
        v.can_register_labours
     FROM users u
     JOIN roles r ON u.role_id = r.id
     LEFT JOIN visitors v ON v.id = u.id
     WHERE u.username=$1`,
    [username]
  );

  if (result.rows.length === 0)
    return res.status(401).json({ message: "Invalid credentials" });

  const user = result.rows[0];

  const valid = await bcrypt.compare(password, user.password_hash);
  if (!valid)
    return res.status(401).json({ message: "Invalid credentials" });

  const token = jwt.sign(
    { id: user.id, role: user.role_name },
    env.jwtSecret,
    { expiresIn: "8h" }
  );

  res.json({
    token,
    user: {
      id: user.id,
      username: user.username,
      role: user.role_name,
      can_register_labours: user.can_register_labours, // 🔥 CRITICAL
    },
  });
};
export const me = async (req, res) => {
  const userId = req.user?.id;
  const result = await db.query(
    `SELECT 
        u.id,
        u.username,
        u.full_name,
        u.phone,
        u.role_id,
        u.is_active,
        r.role_name,
        r.can_export_pdf,
        r.can_export_excel,
        v.can_register_labours
     FROM users u
     JOIN roles r ON u.role_id = r.id
     LEFT JOIN visitors v ON v.id = u.id
     WHERE u.id = $1`,
    [userId]
  );

  if (result.rows.length === 0) {
    return res.status(404).json({ message: "User not found" });
  }

  res.json({ user: result.rows[0] });
};

export const changePassword = async (req, res) => {
  const userId = req.user?.id;
  const { current_password, new_password } = req.body;

  if (!current_password || !new_password) {
    return res.status(400).json({ message: "Current and new password are required" });
  }

  if (new_password.length < 8) {
    return res.status(400).json({ message: "New password must be at least 8 characters" });
  }

  const result = await db.query(
    "SELECT password_hash FROM users WHERE id = $1",
    [userId]
  );

  if (result.rows.length === 0) {
    return res.status(404).json({ message: "User not found" });
  }

  const valid = await bcrypt.compare(current_password, result.rows[0].password_hash);
  if (!valid) {
    return res.status(401).json({ message: "Current password is incorrect" });
  }

  const saltRounds = 10;
  const password_hash = await bcrypt.hash(new_password, saltRounds);

  await db.query(
    "UPDATE users SET password_hash = $1 WHERE id = $2",
    [password_hash, userId]
  );

  res.json({ message: "Password updated successfully" });
};
