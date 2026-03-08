import React, { useEffect, useState, useCallback, useMemo, useRef } from 'react'
import { listVisitors } from '../api/visitor.api'
import { useNavigate } from 'react-router-dom'
import useAuthStore from '../store/auth.store'
import { normalizeRole, canCreateVisitor, canEditVisitor } from '../utils/visitorPermissions'

import DataTable from '../components/common/DataTable'
import SearchBar from '../components/common/SearchBar'

import {
  Box,
  Typography,
  Button,
  Chip,
  Tooltip,
  CircularProgress,
  Snackbar,
  Alert,
  Container,
  Tabs,
  Tab,
  Paper
} from '@mui/material'

import RefreshIcon from '@mui/icons-material/Refresh'
import AddIcon from '@mui/icons-material/Add'
import WarningAmberIcon from '@mui/icons-material/WarningAmber'
import SecurityIcon from '@mui/icons-material/Security'

export default function VisitorsList() {
  const user = useAuthStore((s) => s.user)
  const role = normalizeRole(user)
  const allowCreate = canCreateVisitor(role)
  const allowEdit = canEditVisitor(role)

  const [visitors, setVisitors] = useState([])
  const [loading, setLoading] = useState(true)
  const [query, setQuery] = useState('')
  const [searchInput, setSearchInput] = useState('')
  const [visitorTypes, setVisitorTypes] = useState([])
  const [selectedType, setSelectedType] = useState('ALL')
  const debounceRef = useRef()
  const navigate = useNavigate()

  const [snackbar, setSnackbar] = useState({
    open: false,
    severity: 'success',
    message: '',
  })

  /* ---------------- FETCH VISITORS ---------------- */
  const fetchVisitors = useCallback(() => {
    setLoading(true)
    listVisitors({ q: query })
      .then((res) => {
        const data = res.data
        const allVisitors = data.visitors || []
        setVisitors(allVisitors)

        // Extract unique visitor types from data
        const types = Array.from(
          new Set(
            allVisitors
              .map((v) => v.visitor_type_name || v.type_name || 'Unknown')
              .filter(Boolean)
          )
        ).sort()

        setVisitorTypes(['ALL', ...types])
      })
      .catch((err) => {
        setVisitors([])
        setSnackbar({
          open: true,
          severity: 'error',
          message: err?.response?.data?.error || 'Failed to load visitors',
        })
      })
      .finally(() => setLoading(false))
  }, [query])

  useEffect(() => {
    fetchVisitors()
  }, [fetchVisitors])

  /* ---------------- SEARCH DEBOUNCE ---------------- */
  useEffect(() => {
    clearTimeout(debounceRef.current)
    debounceRef.current = setTimeout(() => {
      setQuery(searchInput)
    }, 400)
    return () => clearTimeout(debounceRef.current)
  }, [searchInput])

  /* ---------------- HELPERS ---------------- */
  const formatDate = (val) => (val ? new Date(val).toLocaleDateString() : '-')

  const deriveStatus = (v) => {
    if (!v.valid_to) return 'INACTIVE'
    const today = new Date()
    const expiry = new Date(v.valid_to)
    return expiry >= today ? 'ACTIVE' : 'EXPIRED'
  }

  const isExpiringSoon = (date) => {
    if (!date) return false
    const today = new Date()
    const expiry = new Date(date)
    const diffDays = (expiry - today) / (1000 * 60 * 60 * 24)
    return diffDays <= 7 && diffDays >= 0
  }

  const getStatusChip = (status) => {
    const map = {
      ACTIVE: 'success',
      EXPIRED: 'error',
      BLOCKED: 'error',
      INACTIVE: 'default',
    }
    return (
      <Chip
        label={status}
        color={map[status] || 'default'}
        size="small"
        sx={{ fontWeight: 700, textTransform: 'uppercase', letterSpacing: 0.6 }}
      />
    )
  }

  const stats = useMemo(() => {
    let active = 0
    let expired = 0
    let expiring = 0
    let inactive = 0

    visitors.forEach((v) => {
      const status = v.status || deriveStatus(v)
      if (status === 'ACTIVE') active += 1
      if (status === 'EXPIRED') expired += 1
      if (status === 'INACTIVE') inactive += 1
      if (isExpiringSoon(v.valid_to)) expiring += 1
    })

    return { total: visitors.length, active, expired, inactive, expiring }
  }, [visitors])

  /* ---------------- PROCESS DATA & FILTER BY TYPE ---------------- */
  const processedVisitors = useMemo(() => {
    return visitors
      .filter((v) => {
        if (selectedType === 'ALL') return true
        return (v.visitor_type_name || v.type_name) === selectedType
      })
      .map((v, index) => {
        const status = v.status || deriveStatus(v)
        return {
          id: v.id,
          serial_no: index + 1,
          pass_no: v.pass_no || v.visitor_pass_no || '-',
          full_name: `${v.first_name || ''} ${v.last_name || ''}`.trim(),
          type: v.visitor_type_name || v.type_name || '-',
          organization: v.company_name || '-',
          phone: v.primary_phone || '-',
          valid_to: v.valid_to || null,
          status,
        }
      })
  }, [visitors, selectedType])

  /* ---------------- GET TYPE COUNT ---------------- */
  const getTypeCount = (type) => {
    if (type === 'ALL') return visitors.length
    return visitors.filter((v) => (v.visitor_type_name || v.type_name) === type).length
  }

  const actions = useMemo(() => {
    const base = [
      {
        label: 'View',
        onClick: (row) => navigate(`/visitors/${row.id}`),
        color: 'primary'
      }
    ]
    if (allowEdit) {
      base.push({
        label: 'Edit',
        onClick: (row) => navigate(`/visitors/${row.id}/edit`),
        color: 'primary'
      })
    }
    return base
  }, [allowEdit, navigate])

  /* ---------------- COLUMNS ---------------- */
  const columns = [
    { key: 'serial_no', label: '#', width: '50px', align: 'center' },
    { key: 'pass_no', label: 'Pass No', width: '120px' },
    { key: 'full_name', label: 'Visitor Name' },
    { key: 'type', label: 'Type', width: '130px' },
    { key: 'organization', label: 'Organization' },
    { key: 'phone', label: 'Contact', width: '140px' },
    {
      key: 'status',
      label: 'Status',
      width: '120px',
      align: 'center',
      render: (status, row) => getStatusChip(status || row.status),
    },
    {
      key: 'valid_to',
      label: 'Valid Till',
      width: '150px',
      align: 'center',
      render: (valid_to, row) => (
        <Box display="flex" alignItems="center" gap={0.6} justifyContent="center">
          {formatDate(valid_to || row.valid_to)}
          {isExpiringSoon(valid_to || row.valid_to) && (
            <Tooltip title="Pass expiring within 7 days">
              <WarningAmberIcon color="warning" fontSize="small" sx={{ flexShrink: 0 }} />
            </Tooltip>
          )}
        </Box>
      ),
    },
  ]

  /* ---------------- RENDER ---------------- */
  return (
    <Container maxWidth="xl" sx={{ py: 2.5 }}>
      {/* HEADER */}
      <Paper
        elevation={0}
        sx={{
          p: 2.5,
          mb: 2.5,
          borderRadius: 3,
          border: '1px solid rgba(15,23,42,0.08)',
          background:
            'linear-gradient(135deg, rgba(15,23,42,0.92), rgba(30,64,175,0.92))',
          color: '#f8fafc',
          boxShadow: '0 16px 40px rgba(15,23,42,0.2)'
        }}
      >
        <Box
          sx={{
            display: 'flex',
            justifyContent: 'space-between',
            alignItems: 'center',
            flexWrap: 'wrap',
            gap: 2
          }}
        >
          <Box>
            <Typography variant="h5" fontWeight={700} sx={{ mb: 0.5 }}>
              Visitor Clearance Console
            </Typography>
            <Typography variant="body2" sx={{ opacity: 0.8 }}>
              INS Rajali - Naval Airfield Visitor Management
            </Typography>
            <Box sx={{ mt: 1, display: 'flex', gap: 1, flexWrap: 'wrap' }}>
              <Chip
                label={allowEdit ? 'Edit Access' : 'View Only'}
                size="small"
                sx={{
                  bgcolor: allowEdit ? 'rgba(34,197,94,0.2)' : 'rgba(248,113,113,0.2)',
                  color: '#f8fafc',
                  border: '1px solid rgba(255,255,255,0.2)',
                  fontWeight: 600
                }}
              />
              <Chip
                label={allowCreate ? 'Can Register Visitors' : 'Registration Restricted'}
                size="small"
                sx={{
                  bgcolor: allowCreate ? 'rgba(59,130,246,0.25)' : 'rgba(148,163,184,0.2)',
                  color: '#f8fafc',
                  border: '1px solid rgba(255,255,255,0.2)',
                  fontWeight: 600
                }}
              />
              <Chip
                label={`Role: ${role}`}
                size="small"
                sx={{
                  bgcolor: 'rgba(15,23,42,0.5)',
                  color: '#e2e8f0',
                  border: '1px solid rgba(255,255,255,0.15)',
                  fontWeight: 600
                }}
              />
            </Box>
          </Box>

          <Box sx={{ display: 'flex', gap: 1 }}>
            <Button
              variant="outlined"
              size="small"
              startIcon={<RefreshIcon />}
              onClick={fetchVisitors}
              disabled={loading}
              sx={{
                borderColor: 'rgba(255,255,255,0.6)',
                color: '#f8fafc',
                '&:hover': { borderColor: '#f8fafc' }
              }}
            >
              Refresh
            </Button>

            <Tooltip title={allowCreate ? 'Register new visitor' : 'Only ENROLLMENT_STAFF_VISITORS can register'}>
              <span>
                <Button
                  variant="contained"
                  size="small"
                  startIcon={<AddIcon />}
                  onClick={() => navigate('/visitors/new')}
                  disabled={!allowCreate}
                  sx={{
                    bgcolor: '#38bdf8',
                    color: '#0f172a',
                    '&:hover': { bgcolor: '#7dd3fc' }
                  }}
                >
                  Register
                </Button>
              </span>
            </Tooltip>
          </Box>
        </Box>
      </Paper>

      {/* SEARCH */}
      <Paper sx={{ p: 2, mb: 2, borderRadius: 2, border: '1px solid #e2e8f0' }}>
        <SearchBar
          value={searchInput}
          onChange={setSearchInput}
          placeholder="Search by Pass No, Name, Phone or Organization..."
        />
      </Paper>

      <Box sx={{ display: 'flex', gap: 1.5, flexWrap: 'wrap', mb: 2 }}>
        <Chip label={`Total: ${stats.total}`} sx={{ fontWeight: 600 }} />
        <Chip label={`Active: ${stats.active}`} color="success" sx={{ fontWeight: 600 }} />
        <Chip label={`Expiring Soon: ${stats.expiring}`} color="warning" sx={{ fontWeight: 600 }} />
        <Chip label={`Expired: ${stats.expired}`} color="error" sx={{ fontWeight: 600 }} />
        <Chip label={`Inactive: ${stats.inactive}`} sx={{ fontWeight: 600 }} />
      </Box>

      {/* TABS */}
      <Paper elevation={0} sx={{ border: '1px solid #e2e8f0', borderBottom: 'none', borderRadius: '12px 12px 0 0' }}>
        <Tabs
          value={selectedType}
          onChange={(e, newValue) => setSelectedType(newValue)}
          variant="scrollable"
          scrollButtons="auto"
          sx={{
            '& .MuiTabs-indicator': {
              backgroundColor: '#1d4ed8',
              height: 3,
              borderRadius: 2
            },
            '& .MuiTab-root': {
              textTransform: 'none',
              fontWeight: 600,
              fontSize: '0.9rem',
              color: '#475569'
            }
          }}
        >
          {visitorTypes.map((type) => (
            <Tab
              key={type}
              label={
                <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                  <Typography variant="body2" sx={{ fontWeight: 600 }}>
                    {type}
                  </Typography>
                  <Chip
                    size="small"
                    label={getTypeCount(type)}
                    sx={{ height: 20, fontWeight: 600 }}
                  />
                </Box>
              }
              value={type}
              sx={{ minWidth: 'auto', px: 2 }}
            />
          ))}
        </Tabs>
      </Paper>

      {/* TABLE */}
      {loading ? (
        <Box display="flex" justifyContent="center" alignItems="center" minHeight={300} sx={{ borderTop: '1px solid #e2e8f0' }}>
          <CircularProgress />
        </Box>
      ) : processedVisitors.length === 0 ? (
        <Paper elevation={0} sx={{ border: '1px solid #e2e8f0', borderTop: 'none', p: 3, textAlign: 'center' }}>
          <SecurityIcon sx={{ fontSize: 48, color: 'text.disabled', mb: 1 }} />
          <Typography variant="subtitle2" color="text.secondary">
            No visitor records found
          </Typography>
        </Paper>
      ) : (
        <Box sx={{ border: '1px solid #e2e8f0', borderTop: 'none', borderRadius: '0 0 12px 12px', overflow: 'hidden' }}>
          <DataTable
            columns={columns}
            data={processedVisitors}
            striped={true}
            stickyHeader={true}
            maxHeight={600}
            actions={actions}
          />
        </Box>
      )}

      {/* SNACKBAR */}
      <Snackbar
        open={snackbar.open}
        autoHideDuration={3000}
        onClose={() => setSnackbar({ ...snackbar, open: false })}
        anchorOrigin={{ vertical: 'bottom', horizontal: 'right' }}
      >
        <Alert severity={snackbar.severity} sx={{ width: '100%' }}>
          {snackbar.message}
        </Alert>
      </Snackbar>
    </Container>
  )
}

