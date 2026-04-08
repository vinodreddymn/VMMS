import React, { useEffect, useMemo, useState } from 'react'
import { useParams, useNavigate } from 'react-router-dom'
import { getVisitor } from '../api/visitor.api'
import labourApi from '../api/labour.api'
import { getMasters } from '../api/master.api'
import { getTransactions } from '../api/analytics.api'
import useAuthStore from '../store/auth.store'
import CheckCircleIcon from '@mui/icons-material/CheckCircle'
import CancelIcon from '@mui/icons-material/Cancel'
import LoginIcon from '@mui/icons-material/Login'
import LogoutIcon from '@mui/icons-material/Logout'
import { normalizeRole, canEditVisitor } from '../utils/visitorPermissions'
import {
  Box, Typography, Divider, Chip, CircularProgress,
  Avatar, Paper, Tabs, Tab, Table, TableHead,
  TableRow, TableCell, TableBody, Button, Stack, Alert, TextField
} from '@mui/material'
import VisitorHistoryTab from '../components/visitor/VisitorHistoryTab'
import LabourHistoryTab from '../components/visitor/LabourHistoryTab'

export default function VisitorsDetail() {
  const { id } = useParams()
  const navigate = useNavigate()
  const user = useAuthStore((s) => s.user)
  const role = normalizeRole(user)
  const allowEdit = canEditVisitor(role)

  const [profile, setProfile] = useState(null)
  const [loading, setLoading] = useState(true)
  const [tab, setTab] = useState('profile')
  const [manifests, setManifests] = useState([])
  const [manifestsLoading, setManifestsLoading] = useState(false)
  const [gates, setGates] = useState([])
  const [entrances, setEntrances] = useState([])
  const [hosts, setHosts] = useState([])

  const todayISO = () => new Date().toISOString().split('T')[0]

  const [historyFrom, setHistoryFrom] = useState(() => todayISO())
  const [historyTo, setHistoryTo] = useState(() => todayISO())
  const [visitorHistory, setVisitorHistory] = useState([])
  const [visitorHistoryLoading, setVisitorHistoryLoading] = useState(false)
  const [visitorStatus, setVisitorStatus] = useState('-')

  const [labourHistoryFrom, setLabourHistoryFrom] = useState(() => todayISO())
  const [labourHistoryTo, setLabourHistoryTo] = useState(() => todayISO())
  const [labourHistory, setLabourHistory] = useState([])
  const [labourHistoryLoading, setLabourHistoryLoading] = useState(false)

  useEffect(() => {
    getMasters()
      .then((res) => {
        const data = res?.data?.data || {}
        setGates(data.gates || [])
        setEntrances(data.entrances || [])
        setHosts(data.hosts || [])
      })
      .catch(() => {
        setGates([])
        setEntrances([])
        setHosts([])
      })
  }, [])

  useEffect(() => {
    let mounted = true
    setLoading(true)

    getVisitor(id)
      .then((res) => {
        if (!mounted) return
        const data = res.data
        setProfile(data)

        if (data?.visitor?.can_register_labours) {
          setManifestsLoading(true)
          labourApi
            .getManifestHistoryBySupervisor(id)
            .then((mRes) => {
              if (!mounted) return
              setManifests(mRes?.data?.manifests || [])
            })
            .catch(() => {
              if (!mounted) return
              setManifests([])
            })
            .finally(() => mounted && setManifestsLoading(false))

        } else {
          setManifests([])
        }
      })
      .finally(() => mounted && setLoading(false))

    return () => (mounted = false)
  }, [id])


  // Latest overall status (independent of date filter)
  useEffect(() => {
    let mounted = true
    getTransactions({
      person_type: 'VISITOR',
      person_id: id,
      limit: 1,
      page: 1,
    })
      .then((res) => {
        if (!mounted) return
        const latest = res?.data?.rows?.[0]
        if (latest && latest.status !== 'FAILED') {
          setVisitorStatus(latest.direction === 'IN' ? 'Inside' : 'Outside')
        } else {
          setVisitorStatus('No logs')
        }
      })
      .catch(() => mounted && setVisitorStatus('No logs'))

    return () => {
      mounted = false
    }
  }, [id])

  // Visitor transactions for selected date
  useEffect(() => {
    if (tab !== 'visitorHistory') return
    let mounted = true
    setVisitorHistoryLoading(true)
    getTransactions({
      person_type: 'VISITOR',
      from_date: historyFrom,
      to_date: historyTo,
      person_id: id,
      limit: 200,
      page: 1,
    })
      .then((res) => {
        if (!mounted) return
        const rows = res?.data?.rows || []
        setVisitorHistory(rows)
      })
      .catch(() => {
        if (!mounted) return
        setVisitorHistory([])
      })
      .finally(() => mounted && setVisitorHistoryLoading(false))

    return () => {
      mounted = false
    }
  }, [tab, historyFrom, historyTo, id])

  // Labours transactions for selected date
  useEffect(() => {
    if (tab !== 'labourHistory' || !profile?.visitor?.can_register_labours) return
    let mounted = true
    setLabourHistoryLoading(true)
    getTransactions({
      person_type: 'LABOUR',
      from_date: labourHistoryFrom,
      to_date: labourHistoryTo,
      supervisor_id: id,
      limit: 200,
      page: 1,
    })
      .then((res) => {
        if (!mounted) return
        setLabourHistory(res?.data?.rows || [])
      })
      .catch(() => mounted && setLabourHistory([]))
      .finally(() => mounted && setLabourHistoryLoading(false))

    return () => {
      mounted = false
    }
  }, [tab, labourHistoryFrom, labourHistoryTo, id, profile?.visitor?.can_register_labours])

  const formatBool = (v) => (v ? 'Yes' : 'No')
  const formatDate = (d) => (d ? new Date(d).toLocaleDateString() : '-')
  const formatDateTime = (d) => (d ? new Date(d).toLocaleString() : '-')

  const tabs = useMemo(() => {
    const base = [
      { key: 'profile', label: 'Profile' },
      { key: 'documents', label: 'Documents' },
      { key: 'rfid', label: 'RFID Card' },
      { key: 'biometric', label: 'Biometric' },
      { key: 'visitorHistory', label: 'Visitor History' },
    ]
    if (profile?.visitor?.can_register_labours) {
      base.push(
        { key: 'labourManifests', label: 'Labour Manifests' },
        { key: 'labourHistory', label: 'Labour History' },
      )
    }
    return base
  }, [profile?.visitor?.can_register_labours])

  if (loading) {
    return (
      <Box display="flex" justifyContent="center" mt={5}>
        <CircularProgress />
      </Box>
    )
  }

  if (!profile?.visitor) {
    return <Typography>Visitor not found</Typography>
  }

  const { visitor, documents, biometric, allowed_gates, soft_lock_reason } = profile
  const visitorEntranceName =
    visitor.entrance_name ||
    entrances.find(e => Number(e.id) === Number(visitor.entrance_id))?.entrance_name ||
    (visitor.entrance_id ? `Entrance ${visitor.entrance_id}` : null)
  const lockReason =
    visitor.status === "SOFT_LOCK"
      ? (
        soft_lock_reason ||
        visitor.soft_lock_reason ||
        visitor.lock_reason ||
        visitor.reason ||
        "Compliance issue detected"
      )
      : null;
  const allowedGateIds = Array.from(new Set((allowed_gates || []).map(Number).filter(Boolean)))
  const allowedGateNames = Array.from(
    new Set(
      gates
        .filter(g => allowedGateIds.includes(Number(g.id)))
        .map(g => g.gate_name || `Gate ${g.id}`)
    )
  )
  const gateLabels = allowedGateIds.length
    ? (allowedGateNames.length ? allowedGateNames : allowedGateIds.map(g => `Gate ${g}`))
    : ['All Gates']
  const allowedEntranceNames = Array.from(
    new Set(
      gates
        .filter(g => allowedGateIds.includes(Number(g.id)))
        .map(g => g.entrance_id)
        .filter(Boolean)
        .map(eid => entrances.find(e => Number(e.id) === Number(eid))?.entrance_name || `Entrance ${eid}`)
    )
  )
  if (visitorEntranceName && !allowedEntranceNames.includes(visitorEntranceName)) {
    allowedEntranceNames.unshift(visitorEntranceName)
  }
  const hostLookup = hosts.find(h => Number(h.id) === Number(visitor.host_id))
  const hostDisplay =
    visitor.host_name ||
    hostLookup?.host_name ||
    hostLookup?.full_name ||
    hostLookup?.name ||
    visitor.host_full_name ||
    visitor.host ||
    (visitor.host_id ? `Host ID: ${visitor.host_id}` : "-")

  const fullName = `${visitor.first_name || ''} ${visitor.last_name || ''}`.trim()

  const fileBase =
    import.meta.env.VITE_FILE_BASE_URL ||
    (import.meta.env.VITE_API_BASE_URL
      ? import.meta.env.VITE_API_BASE_URL.replace(/\/api\/?$/, '')
      : window.location.origin)

  const makeFileUrl = (path) => {
    if (!path) return ''
    if (path.startsWith('data:')) return path
    if (/^https?:\/\//.test(path)) return path
    return `${fileBase}/${path.replace(/^\/+/, '')}`
  }

  return (
  <Box>

  {/* ================= HEADER ================= */}

  <Paper
    sx={{
      p:3,
      mb:3,
      borderRadius:3,
      display:"flex",
      justifyContent:"space-between",
      alignItems:"center",
      flexWrap:"wrap",
      gap:2,
      background:"linear-gradient(135deg,#0f172a,#1e40af)",
      color:"#fff"
    }}
  >

  <Box display="flex" alignItems="center" gap={2}>

  <Avatar
    src={makeFileUrl(visitor.enrollment_photo_path)}
    sx={{ width:90, height:90, border:"3px solid rgba(255,255,255,0.4)" }}
  >
    {fullName?.[0]}
  </Avatar>

  <Box>

  <Typography variant="h5" fontWeight={700}>
  {fullName}
  </Typography>

  <Typography variant="body2" sx={{opacity:0.85}}>
  Pass No : {visitor.pass_no}
  </Typography>

  <Typography variant="body2" sx={{opacity:0.85}}>
  {visitor.company_name || "Company Not Provided"}
  </Typography>
  <Box sx={{ display: "flex", gap: 1, mt: 1 }}>
  <Chip
    icon={
      visitor.status === "ACTIVE"
        ? <CheckCircleIcon />
        : visitor.status === "SOFT_LOCK"
        ? <CancelIcon />
        : <CancelIcon />
    }
    label={
      visitor.status === "ACTIVE"
        ? "Active Visitor"
        : visitor.status === "SOFT_LOCK"
        ? "Soft Locked"
        : "Inactive Visitor"
    }
    size="small"
    color={
      visitor.status === "ACTIVE"
        ? "success"
        : visitor.status === "SOFT_LOCK"
        ? "warning"
        : "error"
    }
    sx={{
      mt: 1,
      fontWeight: 600,
      borderRadius: 2
    }}
  />

  {/* Current Presence Status */}
  <Chip
    icon={visitorStatus === "Inside" ? <LoginIcon /> : <LogoutIcon />}
    label={visitorStatus === "Inside" ? "Currently Inside Facility" : "Currently Outside"}
    size="small"
    color={
      visitorStatus === "Inside"
        ? "success"
        : visitorStatus === "Outside"
        ? "default"
        : "warning"
    }
    variant="outlined"
    sx={{
      mt: 1,
      fontWeight: 600,
      borderRadius: 2
    }}
  />
  </Box>

  </Box>
  </Box>


  {/* ACTION BUTTONS */}

  {allowEdit && (

  <Stack direction="row" spacing={1}>

  <Button
  variant="outlined"
  sx={{ bgcolor:"rgba(255,255,255,0.08)", color:"#fff" }}
  onClick={()=>navigate(`/visitors/${id}/photo`)}
  >
  Upload Photo
  </Button>

  <Button
  variant="contained"
  onClick={()=>navigate(`/visitors/${id}/edit`)}
  >
  Edit Profile
  </Button>

  </Stack>

  )}

  </Paper>


  {/* VIEW ONLY ALERT */}

  {!allowEdit && (

  <Alert severity="info" sx={{mb:2}}>
  You have view-only access for this visitor profile.
  </Alert>

  )}

  {visitor.status === "SOFT_LOCK" && (
    <Alert severity="warning" sx={{ mb: 2 }}>
      <Typography fontWeight={600}>Soft Locked</Typography>
      <Typography variant="body2">
        {lockReason}
      </Typography>
    </Alert>
  )}


  {/* ================= TABS ================= */}

  <Paper sx={{mb:3,borderRadius:3}}>

  <Tabs
  value={tab}
  onChange={(e,v)=>setTab(v)}
  variant="scrollable"
  scrollButtons="auto"
  >

  {tabs.map((t)=>(
    <Tab key={t.key} value={t.key} label={t.label}/>
  ))}

  </Tabs>

  </Paper>


  {/* ================= PROFILE ================= */}

  {tab==='profile' && (

  <Box>

  {/* BASIC INFO */}

  <SectionCard title="Basic Information">

  <GridInfo>

  <Info label="Pass Number" value={visitor.pass_no}/>
  <Info label="Visitor Type" value={visitor.visitor_type_name}/>
  <Info label="Company Name" value={visitor.company_name}/>
  <Info label="Designation" value={visitor.designation}/>
  <Info label="Department" value={visitor.department_name}/>
  <Info label="Project" value={visitor.project_name}/>
  <Info label="Entrance" value={visitorEntranceName || '-'} />
  <Info label="Host" value={hostDisplay}/>
  <Info label="Gender" value={visitor.gender}/>
  <Info label="Blood Group" value={visitor.blood_group}/>
  <Info label="Height (cm)" value={visitor.height_cm}/>
  <Info label="Date of Birth" value={formatDate(visitor.date_of_birth)}/>
  <Info label="Visible Marks" value={visitor.visible_marks}/>
  <Info label="Pass Valid From" value={formatDate(visitor.valid_from)}/>
  <Info label="Pass Valid Upto" value={formatDate(visitor.valid_to)}/>
  {visitor.status === "SOFT_LOCK" && (
    <Info label="Soft Lock Reason" value={lockReason}/>
  )}

  </GridInfo>

  </SectionCard>



  {/* CONTACT */}

  <SectionCard title="Contact Details">

  <GridInfo>

  <Info label="Primary Phone" value={visitor.primary_phone}/>
  <Info label="Alternate Phone" value={visitor.alternate_phone}/>
  <Info label="Email" value={visitor.email}/>
  <Info label="Temporary Address" value={visitor.temp_address}/>
  <Info label="Permanent Address" value={visitor.perm_address}/>

  </GridInfo>

  </SectionCard>

  {/* VEHICLE */}

  <SectionCard title="Vehicle Details">
    <GridInfo>
      <Info label="Vehicle Number" value={visitor.vehicle_number}/>
      <Info label="Make" value={visitor.vehicle_make}/>
      <Info label="Model" value={visitor.vehicle_model}/>
      <Info label="Color" value={visitor.vehicle_color}/>
    </GridInfo>
  </SectionCard>



  {/* CLEARANCE */}

  <SectionCard title="Clearance & Compliance">

  <GridInfo>

  <Info label="Work Order No" value={visitor.work_order_no}/>
  <Info label="Work Order Expiry" value={formatDate(visitor.work_order_expiry)}/>
  <Info label="PVC Number" value={visitor.police_verification_certificate_number}/>
  <Info label="PVC Expiry" value={formatDate(visitor.pvc_expiry)}/>

  </GridInfo>

  </SectionCard>



  {/* GATE PERMISSIONS */}

  <SectionCard title="Gate Permissions">

  <Box display="flex" gap={1} flexWrap="wrap">

  {allowedEntranceNames.length ? (
    allowedEntranceNames.map((n,i)=>(
      <Chip key={`entr-${i}`} label={n} color="secondary" variant="outlined"/>
    ))
  ) : null}

  {gateLabels.map((g,i)=>(
    <Chip key={i} label={g} color="primary" variant="outlined"/>
  ))}

  </Box>

  </SectionCard>



  {/* ACCESS PERMISSIONS */}

  {(
  visitor.smartphone_allowed ||
  visitor.laptop_allowed ||
  visitor.ops_area_permitted ||
  visitor.can_register_labours
  ) && (

  <SectionCard title="Access Permissions">

  <Box display="flex" gap={1} flexWrap="wrap" mb={2}>

  {visitor.smartphone_allowed && (
  <Chip label="Smartphone Allowed" color="success"/>
  )}

  {visitor.laptop_allowed && (
  <Chip label="Laptop Allowed" color="success"/>
  )}

  {visitor.ops_area_permitted && (
  <Chip label="Operations Area Access" color="success"/>
  )}

  {visitor.can_register_labours && (
  <Chip label="Labour Supervisor Permission" color="success"/>
  )}

  </Box>

  <GridInfo>

  {visitor.smartphone_allowed && (
  <Info
  label="Smartphone Expiry"
  value={formatDate(visitor.smartphone_expiry)}
  />
  )}

  {visitor.laptop_allowed && (
  <Info
  label="Laptop Expiry"
  value={formatDate(visitor.laptop_expiry)}
  />
  )}

  </GridInfo>

  </SectionCard>

  )}



  {/* LAPTOP DETAILS */}

  {visitor.laptop_allowed && (

  <SectionCard title="Laptop Details">

  <GridInfo>

  <Info label="Laptop Make" value={visitor.laptop_make}/>
  <Info label="Laptop Model" value={visitor.laptop_model}/>
  <Info label="Laptop Serial Number" value={visitor.laptop_serial}/>
  <Info label="Laptop Expiry" value={formatDate(visitor.laptop_expiry)}/>

  </GridInfo>

  </SectionCard>

  )}

  </Box>

  )}



  {/* ================= DOCUMENTS ================= */}

  {tab==='documents' && (

  <Box>

  {allowEdit && (

  <Stack direction="row" justifyContent="flex-end" mb={2}>

  <Button
  variant="contained"
  onClick={()=>navigate(`/visitors/${id}/upload-document`)}
  >
  Upload / Edit Documents
  </Button>

  </Stack>

  )}

  <DataTableSimple
  columns={["Type","Number","Expiry","File"]}
  rows={documents?.map(d=>[
  d.doc_type,
  d.doc_number,
  formatDate(d.expiry_date),
  d.file_path
  ? <Button size="small" onClick={()=>window.open(makeFileUrl(d.file_path))}>View</Button>
  : "-"
  ]) || []}
  />

  </Box>

  )}



  {/* ================= RFID ================= */}

  {tab==='rfid' && (

  <Box>

  {allowEdit && (

  <Stack direction="row" justifyContent="flex-end" mb={2}>

  <Button
  variant="contained"
  onClick={()=>navigate(`/visitors/${id}/rfid`)}
  >
  Issue / Edit RFID
  </Button>

  </Stack>

  )}

  <Typography>
  RFID Issued : {visitor.card_uid ? "Yes" : "No"}
  </Typography>

  {visitor.card_uid && (
  <Typography>
  Card UID : {visitor.card_uid}
  </Typography>
  )}

  </Box>

  )}



  {/* ================= VISITOR HISTORY ================= */}

  {tab==='visitorHistory' && (

  <Box>

  <VisitorHistoryTab
    historyFrom={historyFrom}
    historyTo={historyTo}
    setHistoryFrom={setHistoryFrom}
    setHistoryTo={setHistoryTo}
    visitorStatus={visitorStatus}
    visitorHistory={visitorHistory}
    loading={visitorHistoryLoading}
    formatDateTime={formatDateTime}
  />

  </Box>

  )}



  {/* ================= BIOMETRIC ================= */}

  {tab==='biometric' && (

  <Box>

  {allowEdit && (

  <Stack direction="row" justifyContent="flex-end" mb={2}>

  <Button
  variant="contained"
  onClick={()=>navigate(`/visitors/${id}/biometric`)}
  >
  {biometric ? "Update Biometric" : "Enroll Biometric"}
  </Button>

  </Stack>

  )}

  <Typography>
  Biometric Enrolled : {biometric ? "Yes" : "No"}
  </Typography>

  {biometric && (
  <Typography>
  Algorithm : {biometric.algorithm}
  </Typography>
  )}

  </Box>

  )}



  {/* ================= LABOUR MANIFESTS ================= */}

  {tab==='labourManifests' && visitor.can_register_labours && (

  <Box>

  {manifestsLoading ? (

  <Box display="flex" justifyContent="center" mt={3}>
  <CircularProgress size={24}/>
  </Box>

  ):(

  <DataTableSimple
  columns={["Manifest No","Date","Signed","PDF"]}
  rows={(manifests||[]).map(m=>[
  m.manifest_number || m.id,
  formatDate(m.manifest_date),
  m.signed ? "Yes":"No",
  m.pdf_path
  ? <Button size="small" onClick={()=>window.open(makeFileUrl(m.pdf_path))}>View PDF</Button>
  : "-"
  ])}
  />

  )}

  </Box>

  )}

  {/* ================= LABOUR HISTORY ================= */}

  {tab==='labourHistory' && visitor.can_register_labours && (

  <Box>



  <LabourHistoryTab
    labourHistoryFrom={labourHistoryFrom}
    labourHistoryTo={labourHistoryTo}
    setLabourHistoryFrom={setLabourHistoryFrom}
    setLabourHistoryTo={setLabourHistoryTo}
    labourHistory={labourHistory}
    loading={labourHistoryLoading}
    formatDateTime={formatDateTime}
    manifests={manifests}
    fileBase={fileBase}
  />

  </Box>

  )}

  </Box>
  )
}

/* ---------- Reusable UI ---------- */

function SectionCard({title, children}){

  return (

  <Paper
  sx={{
  p:2.5,
  mb:3,
  borderRadius:3,
  border:"1px solid rgba(15,23,42,0.08)"
  }}
  >

  <Typography
  variant="h6"
  fontWeight={600}
  sx={{mb:2}}
  >
  {title}
  </Typography>

  {children}

  </Paper>

  )

  }

function Section({ title, children }) {
  return (
    <>
      <Typography variant="h6" gutterBottom>{title}</Typography>
      <Divider sx={{ mb: 2 }} />
      {children}
      <Divider sx={{ my: 3 }} />
    </>
  )
}

function GridInfo({ children }) {
  return (
    <Box display="grid" gridTemplateColumns="repeat(2, 1fr)" gap={2}>
      {children}
    </Box>
  )
}

function Info({ label, value }) {
  return (
    <Box>
      <Typography variant="caption" color="text.secondary">{label}</Typography>
      <Typography variant="body1">{value || '-'}</Typography>
    </Box>
  )
}

function DataTableSimple({ columns, rows }) {
  return (
    <Table size="small">
      <TableHead>
        <TableRow>
          {columns.map((c, i) => <TableCell key={i}><b>{c}</b></TableCell>)}
        </TableRow>
      </TableHead>
      <TableBody>
        {rows.length === 0 ? (
          <TableRow>
            <TableCell colSpan={columns.length} align="center">No data</TableCell>
          </TableRow>
        ) : rows.map((row, i) => (
          <TableRow key={i}>
            {row.map((cell, j) => <TableCell key={j}>{cell}</TableCell>)}
          </TableRow>
        ))}
      </TableBody>
    </Table>
  )
}
