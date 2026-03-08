import fs from "fs";
import path from "path";

const uploadsRoot = "uploads";
const visitorsRoot = path.join(uploadsRoot, "visitors");

export const ensureVisitorFolders = async (visitorId) => {
  const id = String(visitorId);
  const visitorDir = path.join(process.cwd(), visitorsRoot, id);
  await fs.promises.mkdir(path.join(visitorDir, "documents"), { recursive: true });
  await fs.promises.mkdir(path.join(visitorDir, "live"), { recursive: true });
  await fs.promises.mkdir(path.join(visitorDir, "labours"), { recursive: true });
  await fs.promises.mkdir(path.join(visitorDir, "manifests"), { recursive: true });
  return visitorDir;
};

export const getVisitorPhotoDestination = async (visitorId) => {
  await ensureVisitorFolders(visitorId);
  return path.join(visitorsRoot, String(visitorId));
};

export const getVisitorDocumentsDestination = async (visitorId) => {
  await ensureVisitorFolders(visitorId);
  return path.join(visitorsRoot, String(visitorId), "documents");
};

export const getVisitorManifestPaths = async (visitorId, filename) => {
  await ensureVisitorFolders(visitorId);
  const relativePosix = path.posix.join(
    "uploads",
    "visitors",
    String(visitorId),
    "manifests",
    filename
  );
  const absolutePath = path.join(
    process.cwd(),
    "uploads",
    "visitors",
    String(visitorId),
    "manifests",
    filename
  );
  return { relativePosix, absolutePath };
};

export const getVisitorLivePhotoPaths = async (visitorId, filename) => {
  await ensureVisitorFolders(visitorId);
  const relativePosix = path.posix.join(
    "uploads",
    "visitors",
    String(visitorId),
    "live",
    filename
  );
  const absolutePath = path.join(
    process.cwd(),
    "uploads",
    "visitors",
    String(visitorId),
    "live",
    filename
  );
  return { relativePosix, absolutePath };
};

export const getSupervisorLabourPhotoPaths = async (supervisorId, filename) => {
  await ensureVisitorFolders(supervisorId);
  const relativePosix = path.posix.join(
    "uploads",
    "visitors",
    String(supervisorId),
    "labours",
    filename
  );
  const absolutePath = path.join(
    process.cwd(),
    "uploads",
    "visitors",
    String(supervisorId),
    "labours",
    filename
  );
  return { relativePosix, absolutePath };
};

export const toPosixRelativePath = (filePath) =>
  String(filePath).split(path.sep).join(path.posix.sep);
