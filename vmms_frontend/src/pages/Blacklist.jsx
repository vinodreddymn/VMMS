import React, { useEffect, useState } from 'react'
import DataTable from '../components/common/DataTable'
import { listBlacklist, removeBlacklist } from '../api/blacklist.api'
import Button from '@mui/material/Button'
import BlacklistForm from './BlacklistForm'
import Snackbar from '@mui/material/Snackbar'
import Alert from '@mui/material/Alert'

export default function Blacklist() {
  const [items, setItems] = useState([])
  const [loading, setLoading] = useState(true)
  const [formOpen, setFormOpen] = useState(false)
  const [snackbar, setSnackbar] = useState({ open: false, severity: 'success', message: '' })

  function fetch() {
    setLoading(true)
    listBlacklist()
      .then((res) => setItems(res.data.data || []))
      .catch((err) => console.error(err))
      .finally(() => setLoading(false))
  }

  useEffect(() => { fetch() }, [])

  return (
    <div style={{ padding: 20 }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <h2>Blacklist</h2>
        <Button variant="contained" onClick={() => setFormOpen(true)}>Add</Button>
      </div>

      {loading ? <p>Loading...</p> : (
        <DataTable
          columns={[
            { key: 'blacklist_id', label: 'ID' },
            { key: 'aadhaar_last4', label: 'Aadhaar (last4)' },
            { key: 'phone', label: 'Phone' },
            { key: 'reason', label: 'Reason' },
            { key: 'block_type', label: 'Block Type' },
          ]}
          data={items}
          actions={[{ label: 'Remove', onClick: (row) => { removeBlacklist(row.blacklist_id).then(() => { setSnackbar({ open: true, severity: 'success', message: 'Removed' }); fetch() }).catch((e) => { setSnackbar({ open: true, severity: 'error', message: 'Remove failed' }) }) } }]}
        />
      )}

      <BlacklistForm open={formOpen} onClose={() => setFormOpen(false)} onSaved={(res) => { if (res?.success) setSnackbar({ open: true, severity: 'success', message: 'Added' }); else setSnackbar({ open: true, severity: 'error', message: res?.message || 'Failed' }); fetch() }} />

      <Snackbar open={snackbar.open} autoHideDuration={3000} onClose={() => setSnackbar({ ...snackbar, open: false })}>
        <Alert severity={snackbar.severity} sx={{ width: '100%' }}>{snackbar.message}</Alert>
      </Snackbar>
    </div>
  )
}
