import React, { useEffect, useMemo, useState } from 'react'
import {
  Box,
  Button,
  Chip,
  CircularProgress,
  Divider,
  Paper,
  Stack,
  Tab,
  Tabs,
  TextField,
  Typography
} from '@mui/material'
import DownloadIcon from '@mui/icons-material/Download'
import RefreshIcon from '@mui/icons-material/Refresh'

import DataTable from '../components/common/DataTable'
import { listVisitors } from '../api/visitor.api'
import { listBlacklist } from '../api/blacklist.api'
import { getUsers } from '../api/admin.api'
import { getTransactions, exportTransactionsCsv, exportTransactionsPdf } from '../api/analytics.api'

const toDateInput = (d = new Date()) => d.toISOString().split('T')[0]
const sevenDaysAgo = () => {
  const d = new Date()
  d.setDate(d.getDate() - 7)
  return toDateInput(d)
}

const downloadBlob = (blob, filename) => {
  const url = window.URL.createObjectURL(blob)
  const link = document.createElement('a')
  link.href = url
  link.download = filename
  link.click()
  window.URL.revokeObjectURL(url)
}

export default function Reports() {
  const [tab, setTab] = useState('summary')
  const [loading, setLoading] = useState(false)
  const [dateRange, setDateRange] = useState({ from: sevenDaysAgo(), to: toDateInput() })

  const [visitors, setVisitors] = useState([])
  const [blacklist, setBlacklist] = useState([])
  const [users, setUsers] = useState([])
  const [visitorTx, setVisitorTx] = useState([])
  const [labourTx, setLabourTx] = useState([])

  const [error, setError] = useState(null)

  const fetchVisitors = async () => {
    const res = await listVisitors({ limit: 500 })
    setVisitors(res.data.visitors || [])
  }

  const fetchBlacklist = async () => {
    const res = await listBlacklist({ limit: 500 })
    setBlacklist(res.data.blacklist || [])
  }

  const fetchUsers = async () => {
    const res = await getUsers()
    setUsers(res.data.users || [])
  }

  const fetchTransactions = async () => {
    const base = {
      from_date: dateRange.from,
      to_date: dateRange.to,
      limit: 500
    }
    const [vRes, lRes] = await Promise.all([
      getTransactions({ ...base, person_type: 'VISITOR' }),
      getTransactions({ ...base, person_type: 'LABOUR' })
    ])
    setVisitorTx(vRes.data?.rows || [])
    setLabourTx(lRes.data?.rows || [])
  }

  const refreshAll = async () => {
    setLoading(true)
    setError(null)
    try {
      await Promise.all([
        fetchVisitors(),
        fetchBlacklist(),
        fetchUsers(),
        fetchTransactions()
      ])
    } catch (err) {
      console.error(err)
      setError('Failed to load some datasets')
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    refreshAll()
  }, [dateRange.from, dateRange.to])

  const visitorColumns = [
    { key: 'id', label: 'ID', width: '80px' },
    { key: 'full_name', label: 'Name' },
    { key: 'visitor_type_name', label: 'Type' },
    { key: 'primary_phone', label: 'Phone' },
    { key: 'company_name', label: 'Company' },
    { key: 'project_name', label: 'Project' },
    { key: 'status', label: 'Status' },
  ]

  const blacklistColumns = [
    { key: 'id', label: 'ID', width: '80px' },
    { key: 'full_name', label: 'Name' },
    { key: 'phone', label: 'Phone' },
    { key: 'aadhaar_last4', label: 'Aadhaar Last4' },
    { key: 'reason', label: 'Reason' },
    { key: 'created_at', label: 'Created' },
  ]

  const userColumns = [
    { key: 'id', label: 'ID', width: '80px' },
    { key: 'username', label: 'Username' },
    { key: 'full_name', label: 'Full Name' },
    { key: 'phone', label: 'Phone' },
    { key: 'role_name', label: 'Role' },
    { key: 'is_active', label: 'Active', render: (val) => (val ? 'Yes' : 'No') },
  ]

  const txColumns = [
    { key: 'full_name', label: 'Name' },
    { key: 'pass_no', label: 'Pass / Token' },
    { key: 'direction', label: 'Dir', width: '60px' },
    { key: 'status', label: 'Status', width: '80px' },
    { key: 'project_name', label: 'Project' },
    { key: 'department_name', label: 'Department' },
    { key: 'gate_name', label: 'Gate' },
    { key: 'scan_time', label: 'Scan Time', render: (v) => (v ? new Date(v).toLocaleString() : '-') },
  ]

  const summaryCards = useMemo(() => ([
    { label: 'Registered Visitors', value: visitors.length },
    { label: 'Blacklist Entries', value: blacklist.length },
    { label: 'Admin / Users', value: users.length },
    { label: 'Visitor Transactions', value: visitorTx.length },
    { label: 'Labour Transactions', value: labourTx.length },
  ]), [visitors.length, blacklist.length, users.length, visitorTx.length, labourTx.length])

  const exportTx = async (type, fmt) => {
    const params = {
      person_type: type,
      from_date: dateRange.from,
      to_date: dateRange.to,
      page: 1,
      limit: 1000
    }
    const fn = fmt === 'csv' ? exportTransactionsCsv : exportTransactionsPdf
    const res = await fn(params)
    downloadBlob(res.data, `${type.toLowerCase()}_transactions.${fmt}`)
  }

  return (
    <Box sx={{ p: 3 }}>
      <Stack direction="row" justifyContent="space-between" alignItems="center" mb={2}>
        <Box>
          <Typography variant="h5" fontWeight={700}>Reports & Exports</Typography>
          <Typography variant="body2" color="text.secondary">
            One place to pull visitor, labour, blacklist, and admin data with exports.
          </Typography>
        </Box>
        <Stack direction="row" spacing={1}>
          <TextField
            label="From"
            type="date"
            size="small"
            value={dateRange.from}
            onChange={(e) => setDateRange((d) => ({ ...d, from: e.target.value }))}
            InputLabelProps={{ shrink: true }}
          />
          <TextField
            label="To"
            type="date"
            size="small"
            value={dateRange.to}
            onChange={(e) => setDateRange((d) => ({ ...d, to: e.target.value }))}
            InputLabelProps={{ shrink: true }}
          />
          <Button startIcon={<RefreshIcon />} onClick={refreshAll} disabled={loading} variant="outlined">
            Refresh
          </Button>
        </Stack>
      </Stack>

      <Stack direction="row" spacing={1} flexWrap="wrap" mb={2}>
        {summaryCards.map((c) => (
          <Paper key={c.label} sx={{ p: 2, minWidth: 160, borderRadius: 2, border: '1px solid #e2e8f0' }}>
            <Typography variant="body2" color="text.secondary">{c.label}</Typography>
            <Typography variant="h6" fontWeight={800}>{c.value}</Typography>
          </Paper>
        ))}
      </Stack>

      <Paper sx={{ borderRadius: 2, mb: 2, border: '1px solid #e2e8f0' }}>
        <Tabs value={tab} onChange={(_, v) => setTab(v)} variant="scrollable" scrollButtons>
          <Tab value="summary" label="Summary" />
          <Tab value="visitors" label="Visitors" />
          <Tab value="blacklist" label="Blacklist" />
          <Tab value="visitorTx" label="Visitor Transactions" />
          <Tab value="labourTx" label="Labour Transactions" />
          <Tab value="admin" label="Admin / Users" />
        </Tabs>
      </Paper>

      {loading && (
        <Box sx={{ textAlign: 'center', py: 5 }}>
          <CircularProgress />
        </Box>
      )}

      {!loading && error && (
        <Box sx={{ mb: 2 }}>
          <Typography color="error">{error}</Typography>
        </Box>
      )}

      {!loading && tab === 'visitors' && (
        <Paper sx={{ p: 2, borderRadius: 2, border: '1px solid #e2e8f0' }}>
          <Typography variant="h6" mb={1}>Registered Visitors</Typography>
          <DataTable columns={visitorColumns} data={visitors} maxHeight={520} />
        </Paper>
      )}

      {!loading && tab === 'blacklist' && (
        <Paper sx={{ p: 2, borderRadius: 2, border: '1px solid #e2e8f0' }}>
          <Typography variant="h6" mb={1}>Blacklist</Typography>
          <DataTable columns={blacklistColumns} data={blacklist} maxHeight={520} />
        </Paper>
      )}

      {!loading && tab === 'visitorTx' && (
        <Paper sx={{ p: 2, borderRadius: 2, border: '1px solid #e2e8f0' }}>
          <Stack direction="row" justifyContent="space-between" mb={1}>
            <Typography variant="h6">Visitor Transactions</Typography>
            <Stack direction="row" spacing={1}>
              <Button size="small" startIcon={<DownloadIcon />} onClick={() => exportTx('VISITOR', 'csv')}>CSV</Button>
              <Button size="small" startIcon={<DownloadIcon />} onClick={() => exportTx('VISITOR', 'pdf')}>PDF</Button>
            </Stack>
          </Stack>
          <DataTable columns={txColumns} data={visitorTx} maxHeight={520} />
        </Paper>
      )}

      {!loading && tab === 'labourTx' && (
        <Paper sx={{ p: 2, borderRadius: 2, border: '1px solid #e2e8f0' }}>
          <Stack direction="row" justifyContent="space-between" mb={1}>
            <Typography variant="h6">Labour Transactions</Typography>
            <Stack direction="row" spacing={1}>
              <Button size="small" startIcon={<DownloadIcon />} onClick={() => exportTx('LABOUR', 'csv')}>CSV</Button>
              <Button size="small" startIcon={<DownloadIcon />} onClick={() => exportTx('LABOUR', 'pdf')}>PDF</Button>
            </Stack>
          </Stack>
          <DataTable columns={txColumns} data={labourTx} maxHeight={520} />
        </Paper>
      )}

      {!loading && tab === 'admin' && (
        <Paper sx={{ p: 2, borderRadius: 2, border: '1px solid #e2e8f0' }}>
          <Typography variant="h6" mb={1}>Admin / Users</Typography>
          <DataTable columns={userColumns} data={users} maxHeight={520} />
        </Paper>
      )}

      {!loading && tab === 'summary' && (
        <Paper sx={{ p: 2, borderRadius: 2, border: '1px solid #e2e8f0' }}>
          <Typography variant="h6" mb={1}>Overview</Typography>
          <Stack direction="row" spacing={1} mb={2} flexWrap="wrap">
            <Chip label={`Visitors: ${visitors.length}`} />
            <Chip label={`Blacklist: ${blacklist.length}`} />
            <Chip label={`Users: ${users.length}`} />
            <Chip label={`Visitor Tx: ${visitorTx.length}`} />
            <Chip label={`Labour Tx: ${labourTx.length}`} />
          </Stack>
          <Divider />
          <Typography variant="body2" color="text.secondary" mt={2}>
            Use the tabs above to drill into each dataset and export as CSV/PDF where available.
          </Typography>
        </Paper>
      )}
    </Box>
  )
}
