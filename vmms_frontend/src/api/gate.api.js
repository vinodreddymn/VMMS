import api from './axios'

// ======================================
// GATE HEALTH
// ======================================

export const updateGateHealth = (payload) =>
  api.post('/gate/health', payload)

export const getGateHealth = (gate_id) =>
  api.get(`/gate/health/${gate_id}`)

export const getAllGateHealth = () =>
  api.get('/gate/health')

// ======================================
// LIVE MUSTER
// ======================================

export const getMuster = () =>
  api.get('/gate/muster')

// ======================================
// ACCESS LOGS
// ======================================

export const getGateLogs = (params) =>
  api.get('/gate/logs', { params })

// ======================================
// SEARCH PERSON (Manual Gate)
// ======================================

export const searchPerson = (query) =>
  api.get('/gate/search', {
    params: { query }
  })

// ======================================
// MANUAL ENTRY / OVERRIDE
// ======================================

export const manualGateEntry = (payload) =>
  api.post('/gate/manual-entry', payload)

// ======================================
// EXPORT
// ======================================

export default {
  updateGateHealth,
  getGateHealth,
  getAllGateHealth,
  getMuster,
  getGateLogs,
  searchPerson,
  manualGateEntry
}