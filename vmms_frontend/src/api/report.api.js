import api from './axios'

export const exportPdf = (params = {}) => api.get('/reports/export-pdf', { params })
export const exportExcel = (params = {}) => api.get('/reports/export-excel', { params })

export default { exportPdf, exportExcel }
