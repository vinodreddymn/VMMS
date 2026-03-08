import fs from "fs";
import path from "path";
import * as visitorRepo from "../repositories/visitor.repo.js";
import * as labourRepo from "../repositories/labour.repo.js";
import {
  getSupervisorLabourPhotoPaths,
  getVisitorLivePhotoPaths,
} from "./visitor-storage.util.js";

const normalizePhotoBuffer = (photo) => {
  if (!photo) return null;
  if (Buffer.isBuffer(photo)) return photo;
  if (typeof photo !== "string") return null;
  const trimmed = photo.trim();
  if (!trimmed) return null;
  const base64 = trimmed.includes(",") ? trimmed.split(",").pop() : trimmed;
  return Buffer.from(base64, "base64");
};

export const resolvePersonInfo = async ({ personType, personId, rfidUid }) => {
  const type = String(personType || "").toUpperCase();
  let resolvedPersonId =
    personId !== undefined && personId !== null && String(personId).trim() !== ""
      ? Number(personId)
      : null;
  let supervisorId = null;

  if (type === "VISITOR") {
    if (!resolvedPersonId && rfidUid) {
      const visitor = await visitorRepo.findByCard(rfidUid);
      resolvedPersonId = visitor?.id || null;
    }
  }

  if (type === "LABOUR") {
    if (resolvedPersonId) {
      const labour = await labourRepo.getLabourById(resolvedPersonId);
      supervisorId = labour?.supervisor_id || null;
    } else if (rfidUid) {
      const token = await labourRepo.getActiveTokenByUID(rfidUid);
      resolvedPersonId = token?.labour_id || null;
      supervisorId = token?.supervisor_id || null;
    }
  }

  return { personId: resolvedPersonId, supervisorId };
};

export const saveLivePhoto = async ({
  personType,
  personId,
  rfidUid,
  gateId,
  photo,
}) => {
  const buffer = normalizePhotoBuffer(photo);
  if (!buffer) return { livePhotoPath: null, personId: null };

  const filename = `gate_${gateId || "unknown"}_${Date.now()}.jpg`;
  let livePhotoPath = null;
  let absolutePath = null;

  const info = await resolvePersonInfo({ personType, personId, rfidUid });
  const type = String(personType || "").toUpperCase();

  if (type === "VISITOR" && info.personId) {
    const paths = await getVisitorLivePhotoPaths(info.personId, filename);
    livePhotoPath = paths.relativePosix;
    absolutePath = paths.absolutePath;
  }

  if (type === "LABOUR" && info.supervisorId) {
    const paths = await getSupervisorLabourPhotoPaths(info.supervisorId, filename);
    livePhotoPath = paths.relativePosix;
    absolutePath = paths.absolutePath;
  }

  if (!absolutePath) {
    livePhotoPath = path.posix.join("uploads", filename);
    absolutePath = path.join(process.cwd(), "uploads", filename);
  }

  await fs.promises.mkdir(path.dirname(absolutePath), { recursive: true });
  fs.writeFileSync(absolutePath, buffer);

  return { livePhotoPath, personId: info.personId };
};
