import * as repo from "../repositories/visitor.repo.js";

// Create Visitor
export const createVisitor = async (data) => {
  return await repo.createVisitor(data);
};

// Get Visitors with Filters
export const getVisitors = async (filters) => {
  return await repo.getVisitors(filters);
};

// Get Visitor by ID
export const getVisitorById = async (id) => {
  return await repo.findById(id);
};

// Get Visitor by Pass Number
export const getVisitorByPassNo = async (passNo) => {
  return await repo.findByPassNo(passNo);
};

// Get Visitor by RFID Card UID
export const getVisitorByCard = async (cardUid) => {
  return await repo.findByCard(cardUid);
};