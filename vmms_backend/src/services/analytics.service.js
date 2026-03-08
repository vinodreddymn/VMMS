import * as repo from "../repositories/analytics.repo.js";
export const liveMuster = async () => {
  return repo.liveMuster();
};
export const peakHours = async () => repo.peakHours();
export const gateLoad = async () => repo.gateLoad();
export const riskScoring = async () => repo.riskScoring();
export const visitorTrends = async () => repo.visitorTrends();
