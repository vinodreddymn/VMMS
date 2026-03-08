#!/usr/bin/env node
/*
  Usage: node scripts/generate_password_hashes.js
  This will print SQL UPDATE statements to set `password_hash` for sample users.
  Edit the `entries` array to change usernames or plaintext passwords.
*/
const bcrypt = require('bcrypt');

const entries = [
  { username: 'admin', password: 'admin123' },
  { username: 'security_head', password: 'admin123' },
  { username: 'enrollment', password: 'admin123' }
];

(async () => {
  const rounds = 10;
  for (const e of entries) {
    const hash = await bcrypt.hash(e.password, rounds);
    // Output a SQL update statement
    console.log(`-- password for ${e.username}`);
    console.log(`UPDATE users SET password_hash = '${hash.replace(/'/g, "''")}' WHERE username = '${e.username}';\n`);
  }
})();
