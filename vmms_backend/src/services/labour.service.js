import * as repo from "../repositories/labour.repo.js";
import * as visitorRepo from "../repositories/visitor.repo.js";
export const createLabour = async (data) => {
  // Ensure supervisor exists
  const supervisor = await visitorRepo.findById(data.supervisor_id);
  if (!supervisor) throw new Error("Invalid Supervisor");

  return repo.create(data);
};

export const getBySupervisor = async (supervisorId) => {
  return repo.findBySupervisor(supervisorId);
};