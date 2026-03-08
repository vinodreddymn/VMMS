import api from './axios'

export const listMaterials = (params = {}) => api.get('/materials', { params })
export const createMaterial = (payload) => api.post('/materials', payload)
export const recordTransaction = (payload) => api.post('/materials/transaction', payload)
export const getMaterialBalance = (visitor_id) => api.get(`/materials/balance/${visitor_id}`)
export const getPendingReturns = () => api.get('/materials/pending-returns')

export default { listMaterials, createMaterial, recordTransaction, getMaterialBalance, getPendingReturns }
