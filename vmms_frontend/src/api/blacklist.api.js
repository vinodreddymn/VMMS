import api from "./axios";

// =====================================================
// ENDPOINTS
// =====================================================
const BASE_URL = "/blacklist";

// =====================================================
// BLACKLIST API
// =====================================================

// Add to blacklist
export const addToBlacklist = (payload) => {
  return api.post(`${BASE_URL}`, payload);
};

// Check blacklist (gate / enrollment)
export const checkBlacklist = (payload) => {
  return api.post(`${BASE_URL}/check`, payload);
};

// Get all blacklist entries (supports query params)
export const listBlacklist = (params = {}) => {
  return api.get(`${BASE_URL}`, { params });
};

// Remove from blacklist
export const removeBlacklist = (blacklistId) => {
  return api.delete(`${BASE_URL}/${blacklistId}`);
};

// =====================================================
// EXPORT (optional grouped usage)
// =====================================================
const blacklistApi = {
  addToBlacklist,
  checkBlacklist,
  listBlacklist,
  removeBlacklist,
};

export default blacklistApi;