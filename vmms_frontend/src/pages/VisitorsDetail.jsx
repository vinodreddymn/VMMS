import React, { useEffect, useState } from 'react'
import { useParams, useNavigate } from 'react-router-dom'
import { getVisitor } from '../api/visitor.api'
import labourApi from '../api/labour.api'
import { getGates } from '../api/master.api'
import useAuthStore from '../store/auth.store'
import { normalizeRole, canEditVisitor } from '../utils/visitorPermissions'
import {
  Box, Typography, Divider, Chip, CircularProgress,
  Avatar, Paper, Tabs, Tab, Table, TableHead,
  TableRow, TableCell, TableBody, Button, Stack, Alert
} from '@mui/material'

export default function VisitorsDetail() {
  const { id } = useParams()
  const navigate = useNavigate()
  const user = useAuthStore((s) => s.user)
  const role = normalizeRole(user)
  const allowEdit = canEditVisitor(role)

  const [profile, setProfile] = useState(null)
  const [loading, setLoading] = useState(true)
  const [tab, setTab] = useState(0)
  const [manifests, setManifests] = useState([])
  const [manifestsLoading, setManifestsLoading] = useState(false)
  const [gates, setGates] = useState([])

  useEffect(() => {
    getGates()
      .then((res) => {
        setGates(res?.data?.gates || [])
      })
      .catch(() => setGates([]))
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

  const formatBool = (v) => (v ? 'Yes' : 'No')
  const formatDate = (d) => (d ? new Date(d).toLocaleDateString() : '-')

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

  const { visitor, documents, biometric, allowed_gates } = profile
  const allowedGateNames =
    gates
      .filter(g => allowed_gates?.includes(g.id))
      .map(g => g.gate_name)

  const fullName = `${visitor.first_name || ''} ${visitor.last_name || ''}`.trim()

  const fileBase = import.meta.env.VITE_FILE_BASE_URL || 'http://localhost:5000'

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
    src={visitor.enrollment_photo_path ? `${fileBase}/${visitor.enrollment_photo_path}` : ""}
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

  <Chip
  label={visitor.status}
  size="small"
  color={visitor.status === "ACTIVE" ? "success" : "default"}
  sx={{ mt:1, fontWeight:600 }}
  />

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


  {/* ================= TABS ================= */}

  <Paper sx={{mb:3,borderRadius:3}}>

  <Tabs
  value={tab}
  onChange={(e,v)=>setTab(v)}
  variant="scrollable"
  scrollButtons="auto"
  >

  <Tab label="Profile"/>
  <Tab label="Documents"/>
  <Tab label="RFID Card"/>
  <Tab label="Biometric"/>

  {visitor.can_register_labours && (
  <Tab label="Labour Manifests"/>
  )}

  </Tabs>

  </Paper>


  {/* ================= PROFILE ================= */}

  {tab===0 && (

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
  <Info label="Host" value={visitor.host_name}/>
  <Info label="Gender" value={visitor.gender}/>
  <Info label="Blood Group" value={visitor.blood_group}/>
  <Info label="Height (cm)" value={visitor.height_cm}/>
  <Info label="Date of Birth" value={formatDate(visitor.date_of_birth)}/>
  <Info label="Visible Marks" value={visitor.visible_marks}/>
  <Info label="Pass Valid From" value={formatDate(visitor.valid_from)}/>
  <Info label="Pass Valid Upto" value={formatDate(visitor.valid_to)}/>

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

  {allowedGateNames?.length ? (

  allowedGateNames.map((g,i)=>(
  <Chip key={i} label={g} color="primary" variant="outlined"/>
  ))

  ):(

  <Typography variant="body2">
  No gate restrictions
  </Typography>

  )}

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

  {tab===1 && (

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
  ? <Button size="small" onClick={()=>window.open(`${fileBase}/${d.file_path}`)}>View</Button>
  : "-"
  ]) || []}
  />

  </Box>

  )}



  {/* ================= RFID ================= */}

  {tab===2 && (

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



  {/* ================= BIOMETRIC ================= */}

  {tab===3 && (

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

  {tab===4 && visitor.can_register_labours && (

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
  ? <Button size="small" onClick={()=>window.open(`${fileBase}/${m.pdf_path}`)}>View PDF</Button>
  : "-"
  ])}
  />

  )}

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


