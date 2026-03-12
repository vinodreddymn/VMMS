import * as repo from "../repositories/labour.repo.js";
import * as visitorRepo from "../repositories/visitor.repo.js";
export const createLabour = async (data) => {
  // Ensure supervisor exists
  const supervisor = await visitorRepo.findById(data.supervisor_id);
  if (!supervisor) throw new Error("Invalid Supervisor");

  const parsedAge =
    data.age === undefined || data.age === null || String(data.age).trim() === ""
      ? null
      : Number(data.age);
  const ageValue = Number.isFinite(parsedAge) ? parsedAge : null;

  return repo.createLabour(
    data.supervisor_id,
    data.full_name,
    data.phone,
    data.aadhaar,
    data.gender ?? null,
    ageValue
  );
};

export const getBySupervisor = async (supervisorId) => {
  return repo.findBySupervisor(supervisorId);
};
