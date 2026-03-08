import api from './axios'

export const getMuster = () => api.get('/analytics/muster')

export const getLiveMuster = () => api.get('/analytics/live-muster')

export const getDailyStats = (date) => api.get(`/analytics/daily-stats?date=${date}`)

export const getGateStats = (from_date, to_date) => 
  api.get(`/analytics/gate-stats?from_date=${from_date}&to_date=${to_date}`)

export const getProjectStats = (from_date, to_date) =>
  api.get(`/analytics/project-stats?from_date=${from_date}&to_date=${to_date}`)

export const getPeakHours = (from_date, to_date) =>
  api.get(`/analytics/peak-hours?from_date=${from_date}&to_date=${to_date}`)

export const getRiskScores = (limit = 50) =>
  api.get(`/analytics/risk-scoring?limit=${limit}`)

export const getVisitorTrends = (from_date, to_date) =>
  api.get(`/analytics/visitor-trends?from_date=${from_date}&to_date=${to_date}`)

export const getGatePerformance = (from_date, to_date) =>
  api.get(`/analytics/gate-performance?from_date=${from_date}&to_date=${to_date}`)

export const getMaterialAnalytics = (from_date, to_date) =>
  api.get(`/analytics/material-analytics?from_date=${from_date}&to_date=${to_date}`)

export const getLabourAnalytics = (from_date, to_date) =>
  api.get(`/analytics/labour-analytics?from_date=${from_date}&to_date=${to_date}`)

export const getTransactions = (params = {}) =>
  api.get('/analytics/transactions', { params })

export const exportTransactionsCsv = (params = {}) =>
  api.get('/analytics/transactions/export-csv', { params, responseType: 'blob' })

export const exportTransactionsPdf = (params = {}) =>
  api.get('/analytics/transactions/export-pdf', { params, responseType: 'blob' })

export default { 
  getMuster, 
  getLiveMuster, 
  getDailyStats, 
  getGateStats, 
  getProjectStats,
  getPeakHours,
  getRiskScores,
  getVisitorTrends,
  getGatePerformance,
  getMaterialAnalytics,
  getLabourAnalytics,
  getTransactions,
  exportTransactionsCsv,
  exportTransactionsPdf
}
