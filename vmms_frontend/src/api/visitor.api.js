import api from './axios'

export const listVisitors = (params = {}) => {
  return api.get('/visitors', { params })
}

export const getVisitor = (visitor_id) => api.get(`/visitors/${visitor_id}`)

export const createVisitor = (payload) => api.post('/visitors', payload)


export const updateVisitor = (visitor_id, payload) =>
	api.put(`/visitors/${visitor_id}`, payload)

// visitor.api.js

// visitor.api.js
export const uploadVisitorDocument = (visitorId, formData) =>
  api.post(`/visitors/${visitorId}/documents`, formData, {
    headers: { 'Content-Type': 'multipart/form-data' }
  })
export const getVisitorDocuments = (visitorId) =>
  api.get(`/visitors/${visitorId}/documents`)

export const extendVisitorDocument = (docId, expiry_date) =>
  api.put(`/visitors/visitor-documents/${docId}/extend`, { expiry_date })

export const deleteVisitorDocument = (docId) =>
  api.delete(`/visitors/visitor-documents/${docId}`)

export const issueRFIDCard = (visitorIdOrPayload, data) => {
  let visitorId = visitorIdOrPayload
  let payload = data
  if (visitorIdOrPayload && typeof visitorIdOrPayload === 'object') {
    visitorId = visitorIdOrPayload.visitor_id
    payload = visitorIdOrPayload
  }
  return api.post(`/visitors/${visitorId}/rfid-card`, payload)
}

export const getRFIDCard = (visitorId) =>
  api.get(`/visitors/${visitorId}/rfid-card`)

export const getAvailableRFIDCards = (search = '', limit = 20) =>
  api.get('/visitors/rfid-cards/available', {
    params: { search, limit },
  })

export const updateRFIDCard = (visitorId, payload) =>
  api.put(`/visitors/${visitorId}/rfid-card`, payload)

export const deleteRFIDCard = (visitorId) =>
  api.delete(`/visitors/${visitorId}/rfid-card`)

export const enrollBiometric = (visitorIdOrPayload, data) => {
  let visitorId = visitorIdOrPayload
  let payload = data
  if (visitorIdOrPayload && typeof visitorIdOrPayload === 'object') {
    visitorId = visitorIdOrPayload.visitor_id
    payload = visitorIdOrPayload
  }
  return api.post(`/visitors/${visitorId}/biometric`, payload)
}

export const getBiometric = (visitorId) =>
  api.get(`/visitors/${visitorId}/biometric`)

export const updateBiometric = (visitorId, payload) =>
  api.put(`/visitors/${visitorId}/biometric`, payload)

export const deleteBiometric = (visitorId) =>
  api.delete(`/visitors/${visitorId}/biometric`)

export const uploadVisitorPhoto = (visitorId, formData) =>
  api.post(`/visitors/${visitorId}/photo`, formData, {
    headers: { 'Content-Type': 'multipart/form-data' }
  })

export default {
  listVisitors,
  getVisitor,
  createVisitor,
  updateVisitor,
  uploadVisitorDocument,
  uploadVisitorPhoto,
  issueRFIDCard,
  getRFIDCard,
  getAvailableRFIDCards,
  updateRFIDCard,
  deleteRFIDCard,
  enrollBiometric,
  getBiometric,
  updateBiometric,
  deleteBiometric
}
