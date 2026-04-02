import fs from "fs";
import path from "path";
import env from "../config/env.js";

const uploadsRoot = env.paths?.uploadsDir || path.resolve(process.cwd(), "uploads");
const uploadsUrlSegment = env.paths?.uploadsUrlSegment || "uploads";
const visitorsRoot = path.join(uploadsRoot, "visitors");

const toPublicPosix = (...segments) =>
  path.posix.join(uploadsUrlSegment, ...segments);

export const ensureVisitorFolders = async (visitorId) => {
  const id = String(visitorId);
  const visitorDir = path.join(visitorsRoot, id);
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
    uploadsUrlSegment,
    "visitors",
    String(visitorId),
    "manifests",
    filename
  );
  const absolutePath = path.join(
    uploadsRoot,
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
    uploadsUrlSegment,
    "visitors",
    String(visitorId),
    "live",
    filename
  );
  const absolutePath = path.join(
    uploadsRoot,
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
    uploadsUrlSegment,
    "visitors",
    String(supervisorId),
    "labours",
    filename
  );
  const absolutePath = path.join(
    uploadsRoot,
    "visitors",
    String(supervisorId),
    "labours",
    filename
  );
  return { relativePosix, absolutePath };
};

export const toPosixRelativePath = (filePath) => {
  if (!filePath) return "";

  const absolute = path.isAbsolute(filePath)
    ? filePath
    : path.resolve(filePath);

  const relativeToUploads = path.relative(uploadsRoot, absolute);
  const insideUploads =
    relativeToUploads &&
    !relativeToUploads.startsWith("..") &&
    !path.isAbsolute(relativeToUploads);

  const normalized = insideUploads
    ? toPublicPosix(relativeToUploads.split(path.sep).join(path.posix.sep))
    : absolute.split(path.sep).join(path.posix.sep);

  return normalized;
};
