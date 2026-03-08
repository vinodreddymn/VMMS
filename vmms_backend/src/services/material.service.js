import * as repo from "../repositories/material.repo.js";
export const transaction = async (data) => {
  return repo.insertTransaction(data);
};

export const balance = async (visitorId) => {
  return repo.getBalance(visitorId);
};