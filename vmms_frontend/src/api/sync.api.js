import api from './axios'

export const getWhitelist = (params = {}) => api.get('/sync/whitelist', { params })
export const submitSyncQueue = (payload) => api.post('/sync/queue', payload)
export const getUnsyncedQueue = (params = {}) => api.get('/sync/queue', { params })

export default { getWhitelist, submitSyncQueue, getUnsyncedQueue }
