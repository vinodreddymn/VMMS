import React, { useEffect, useState, useCallback, useMemo, useRef } from 'react'
import { listVisitors } from '../api/visitor.api'
import { useNavigate } from 'react-router-dom'
import useAuthStore from '../store/auth.store'
import { normalizeRole, canCreateVisitor, canEditVisitor } from '../utils/visitorPermissions'

import DataTable from '../components/common/DataTable'
import SearchBar from '../components/common/SearchBar'
import Pagination from '../components/common/Pagination'

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
  const [page, setPage] = useState(1)
  const [limit] = useState(25)
  const [total, setTotal] = useState(0)
  const [typeCounts, setTypeCounts] = useState([])
  const [stats, setStats] = useState({
    total: 0, active: 0, expired: 0, inactive: 0, expiring: 0, soft_lock: 0
  })
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
    const params = { q: query, page, limit }
    if (selectedType !== 'ALL') params.type = selectedType
    listVisitors(params)
      .then((res) => {
        const data = res.data
        const allVisitors = data.visitors || []
        setVisitors(allVisitors)
        setTotal(data.total || allVisitors.length)
        setTypeCounts(data.typeCounts || [])
        if (data.stats) setStats(data.stats)

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
  }, [query, page, limit, selectedType])

  useEffect(() => {
    fetchVisitors()
  }, [fetchVisitors])

  /* ---------------- SEARCH DEBOUNCE ---------------- */
  useEffect(() => {
    clearTimeout(debounceRef.current)
    debounceRef.current = setTimeout(() => {
      setQuery(searchInput)
      setPage(1)
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
      SOFT_LOCK: 'warning'
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

  const typeCountMap = useMemo(() => {
    const map = new Map()
    typeCounts.forEach(t => map.set(t.type, t.count))
    return map
  }, [typeCounts])

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
          serial_no: (page - 1) * limit + index + 1,
          pass_no: v.pass_no || v.visitor_pass_no || '-',
          full_name: `${v.first_name || ''} ${v.last_name || ''}`.trim(),
          type: v.visitor_type_name || v.type_name || '-',
          organization: v.company_name || '-',
          phone: v.primary_phone || '-',
          valid_to: v.valid_to || null,
          status,
        }
      })
  }, [visitors, selectedType, page, limit])

  /* ---------------- GET TYPE COUNT ---------------- */
  const getTypeCount = (type) => {
    if (type === 'ALL') return stats.total || 0
    return typeCountMap.get(type) || 0
  }

  const totalPages = Math.max(1, Math.ceil((total || 0) / limit) || 1)

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
    <Container maxWidth="xxl">

      {/* SEARCH and New Registration*/}
      <Paper
        sx={{
          p: 1,
          mb: 2,
          borderRadius: 2,
          border: "1px solid #e2e8f0"
        }}
      >
        <Box
          sx={{
            display: "flex",
            alignItems: "center",
            justifyContent: "space-between",
            gap: 2,
            flexWrap: "wrap"
          }}
        >
          {/* Search */}
          <Box sx={{ flex: 1, minWidth: 260 }}>
            <SearchBar
              value={searchInput}
              onChange={setSearchInput}
              placeholder="Search by Pass No, Name, Phone or Organization..."
            />
          </Box>

          {/* Register Button */}
          <Tooltip
            title={
              allowCreate
                ? "Register new visitor"
                : "Only ENROLLMENT_STAFF_VISITORS can register"
            }
          >
            <span>
              <Button
                variant="contained"
                startIcon={<AddIcon />}
                onClick={() => navigate("/visitors/new")}
                disabled={!allowCreate}
                sx={{
                  bgcolor: "#38bdf8",
                  color: "#0f172a",
                  height: 40,
                  "&:hover": { bgcolor: "#7dd3fc" }
                }}
              >
                Register
              </Button>
            </span>
          </Tooltip>
        </Box>
      </Paper>

      <Box sx={{ display: 'flex', gap: 1.5, flexWrap: 'wrap', mb: 2 }}>
        <Chip label={`Total: ${stats.total || 0}`} sx={{ fontWeight: 600 }} />
        <Chip label={`Active: ${stats.active || 0}`} color="success" sx={{ fontWeight: 600 }} />
        <Chip label={`Expiring Soon: ${stats.expiring || 0}`} color="warning" sx={{ fontWeight: 600 }} />
        <Chip label={`Expired: ${stats.expired || 0}`} color="error" sx={{ fontWeight: 600 }} />
        <Chip label={`Inactive: ${stats.inactive || 0}`} sx={{ fontWeight: 600 }} />
        <Chip label={`Soft Locked: ${stats.soft_lock || 0}`} color="error" sx={{ fontWeight: 600 }} />
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
          <Box sx={{ p: 1.5, display: 'flex', justifyContent: 'flex-end' }}>
            <Pagination page={page} totalPages={totalPages} onChange={setPage} />
          </Box>
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
