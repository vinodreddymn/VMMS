import fs from "fs/promises";
import path from "path";

const mediaDir = path.join(process.cwd(), "uploads", "media");
const manifestPath = path.join(mediaDir, "_manifest.json");

const ensureMediaDir = async () => {
  await fs.mkdir(mediaDir, { recursive: true });
};

const loadManifest = async () => {
  try {
    const data = await fs.readFile(manifestPath, "utf-8");
    return JSON.parse(data);
  } catch (err) {
    if (err.code === "ENOENT") return [];
    throw err;
  }
};

const saveManifest = async (items) => {
  await fs.writeFile(manifestPath, JSON.stringify(items, null, 2));
};

const normalizeEntry = (entry) => {
  const fileName = entry.file_name || entry.filename || entry.id;
  return {
    id: entry.id || fileName,
    file_name: fileName,
    original_name: entry.original_name || entry.originalname || fileName,
    mime_type: entry.mime_type || entry.mimetype || "",
    size: entry.size || 0,
    uploaded_at: entry.uploaded_at || new Date().toISOString(),
    url: path.posix.join("uploads", "media", fileName),
  };
};

export const listMediaPublic = async (_req, res, next) => {
  try {
    await ensureMediaDir();
    const manifest = await loadManifest();
    res.json({ success: true, media: manifest.map(normalizeEntry) });
  } catch (err) {
    next(err);
  }
};

export const listMediaAdmin = async (_req, res, next) => {
  try {
    await ensureMediaDir();
    const manifest = await loadManifest();
    res.json({ success: true, media: manifest.map(normalizeEntry) });
  } catch (err) {
    next(err);
  }
};

export const uploadMedia = async (req, res, next) => {
  try {
    await ensureMediaDir();
    if (!req.file) {
      return res.status(400).json({ success: false, error: "File is required" });
    }

    const manifest = await loadManifest();
    const record = normalizeEntry({
      id: req.file.filename,
      file_name: req.file.filename,
      original_name: req.file.originalname,
      mime_type: req.file.mimetype,
      size: req.file.size,
      uploaded_at: new Date().toISOString(),
    });

    manifest.push(record);
    await saveManifest(manifest);

    res.json({ success: true, media: record });
  } catch (err) {
    next(err);
  }
};

export const deleteMedia = async (req, res, next) => {
  try {
    await ensureMediaDir();
    const { id } = req.params;
    if (!id) return res.status(400).json({ success: false, error: "Media id required" });

    const manifest = await loadManifest();
    const idx = manifest.findIndex(
      (m) => m.id === id || m.file_name === id || m.filename === id
    );

    if (idx === -1) {
      return res.status(404).json({ success: false, error: "Media not found" });
    }

    const fileName = manifest[idx].file_name || manifest[idx].id;
    const filePath = path.join(mediaDir, fileName);
    await fs.rm(filePath, { force: true });

    manifest.splice(idx, 1);
    await saveManifest(manifest);

    res.json({ success: true, message: "Media deleted" });
  } catch (err) {
    next(err);
  }
};

