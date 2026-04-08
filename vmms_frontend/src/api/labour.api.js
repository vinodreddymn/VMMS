import api from './axios'

// =====================================
// LABOUR ENDPOINTS
// =====================================

// Get ALL labours (global listing)
export const getAllLabours = () =>
  api.get('/labour')

// Get labours for a specific supervisor
export const getLaboursBySupervisor = (supervisorId) =>
  api.get(`/labour/supervisor/${supervisorId}`)

// Register labour (token auto-assigned by backend)
export const createLabour = (payload) =>
  api.post('/labour', payload)


// =====================================
// RFID TOKEN ENDPOINTS
// =====================================

// Validate token at gate entry
export const validateLabourToken = (tokenUid) =>
  api.get(`/labour/tokens/validate/${tokenUid}`)

// Search available RFID tokens (optional feature if backend supports)
export const getAvailableTokens = (search = '', limit = 20) =>
  api.get('/labour/tokens/available', {
    params: { search, limit },
  })

// Return token after checkout (de-register & make reusable)
export const returnLabourToken = (payload) =>
  api.post('/labour/tokens/return', payload)

// Force checkout stale labour (admin only)
export const forceCheckoutLabour = (labourId) =>
  api.post('/labour/tokens/force-checkout', { labour_id: labourId })


// =====================================
// MANIFEST ENDPOINTS
// =====================================

// Create (or reuse) today's manifest for supervisor
export const createManifest = (payload) =>
  api.post('/labour/manifests', payload)

// Get manifest with labour list
export const getManifest = (manifestId) =>
  api.get(`/labour/manifests/${manifestId}`)

// Get manifests for a specific date (via analytics endpoint)
export const getManifestsByDate = (date) =>
  api.get('/labour/analytics', { params: { date } })

// Get labour analytics for a specific date
export const getLabourAnalytics = (date) =>
  api.get('/labour/analytics', {
    params: { date },
  })

// Update manifest (sign/approve)
export const updateManifest = (manifestId, payload) =>
  api.put(`/labour/manifests/${manifestId}`, payload)

// Download / view manifest PDF
export const getManifestPdf = (manifestId) =>
  api.get(`/labour/manifests/${manifestId}/pdf`, {
    responseType: 'blob',
  })

// Get today's manifest for a supervisor
export const getTodayManifestBySupervisor = (supervisorId) =>
  api.get(`/labour/manifests/supervisor/${supervisorId}`)

// Get all manifests for a supervisor
export const getManifestHistoryBySupervisor = (supervisorId) =>
  api.get(`/labour/manifests/supervisor/${supervisorId}/history`)


// =====================================
// NO-SHOW DETECTION
// =====================================

export const checkNoShows = () =>
  api.post('/labour/check-noshows')


// =====================================
// DEFAULT EXPORT
// =====================================

export default {
  // Labour
  getAllLabours,
  getLaboursBySupervisor,
  createLabour,

  // Tokens
  validateLabourToken,
  getAvailableTokens,
  returnLabourToken,
  forceCheckoutLabour,

  // Manifest
  createManifest,
  getManifest,
  getManifestsByDate,
  updateManifest,
  getManifestPdf,
  getTodayManifestBySupervisor,
  getManifestHistoryBySupervisor,

  // Analytics
  getLabourAnalytics,

  // No-show
  checkNoShows,
}
