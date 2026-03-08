import api from './axios'

export const addToBlacklist = (payload) => api.post('/blacklist', payload)
export const checkBlacklist = (payload) => api.post('/blacklist/check', payload)
export const listBlacklist = (params = {}) => api.get('/blacklist', { params })
export const removeBlacklist = (blacklist_id) => api.delete(`/blacklist/${blacklist_id}`)

export default { addToBlacklist, checkBlacklist, listBlacklist, removeBlacklist }
