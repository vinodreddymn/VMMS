import api from './axios'

// =====================================================
// UNIFIED MASTERS ENDPOINT
// =====================================================

export const getMasters = () => api.get('/masters')


/* =====================================================
   BACKWARD COMPATIBILITY HELPERS
   (Older pages can still call these)
===================================================== */

// Projects
export const getProjects = async () => {
  const res = await getMasters()
  return { data: { projects: res.data?.data?.projects || [] } }
}

// Departments
export const getDepartments = async () => {
  const res = await getMasters()
  return { data: { departments: res.data?.data?.departments || [] } }
}

// Visitor Types
export const getVisitorTypes = async () => {
  const res = await getMasters()
  return { data: { visitorTypes: res.data?.data?.visitorTypes || [] } }
}

// Hosts = internal employees acting as host
export const getHosts = async () => {
  const res = await getMasters()
  return { data: { visitors: res.data?.data?.hosts || [] } }
}

// Gates (NEW)
export const getGates = async () => {
  const res = await getMasters()
  return { data: { gates: res.data?.data?.gates || [] } }
}