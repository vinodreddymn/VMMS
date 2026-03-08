import { Pool } from "pg";
import env from "./env.js";

const pool = new Pool(env.db);

pool.on("connect", () => {
  console.log("PostgreSQL Connected");
});

export const query = (text, params) => pool.query(text, params);
export const connect = () => pool.connect();

export default pool;