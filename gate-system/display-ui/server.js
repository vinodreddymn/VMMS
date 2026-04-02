import express from "express";
import path from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();
app.use(express.static(__dirname));

const PORT = process.env.DISPLAY_PORT || 4173;
app.listen(PORT, () => {
  console.log(`Gate display UI at http://127.0.0.1:${PORT}`);
  console.log(`Open with ?gate=1&server=127.0.0.1:3200`);
});
