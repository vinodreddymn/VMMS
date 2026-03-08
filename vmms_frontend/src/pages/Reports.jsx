import React, { useState } from 'react'
import Button from '@mui/material/Button'
import { exportPdf, exportExcel } from '../api/report.api'

export default function Reports() {
  const [loading, setLoading] = useState(false)

  async function handlePdf() {
    setLoading(true)
    try {
      const res = await exportPdf({ report_type: 'DAILY_STATS', from_date: '2024-01-01', to_date: '2024-01-31' })
      const url = res.data.data?.pdf_url || res.data.data?.pdf_path
      alert('PDF exported: ' + url)
    } catch (err) {
      console.error(err)
      alert('Export failed')
    } finally {
      setLoading(false)
    }
  }

  async function handleExcel() {
    setLoading(true)
    try {
      const res = await exportExcel({ from_date: '2024-01-01', to_date: '2024-01-31' })
      const url = res.data.data?.excel_url
      alert('Excel exported: ' + url)
    } catch (err) {
      console.error(err)
      alert('Export failed')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div style={{ padding: 20 }}>
      <h2>Reports</h2>
      <div style={{ display: 'flex', gap: 12 }}>
        <Button variant="contained" onClick={handlePdf} disabled={loading}>Export PDF</Button>
        <Button variant="contained" onClick={handleExcel} disabled={loading}>Export Excel</Button>
      </div>
    </div>
  )
}
