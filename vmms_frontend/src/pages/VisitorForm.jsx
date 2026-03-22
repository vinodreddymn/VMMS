import React, { useEffect, useState } from 'react'
import { useNavigate, useParams } from 'react-router-dom'
import { getMasters } from '../api/master.api'
import useAuthStore from '../store/auth.store'
import { normalizeRole, canCreateVisitor, canEditVisitor } from '../utils/visitorPermissions'
import blacklistApi from '../api/blacklist.api'
import {
  Box, Typography, TextField, Button, Paper, Grid,
  Avatar, Divider, MenuItem, Chip, CircularProgress,
  FormGroup, FormControlLabel, Checkbox, Alert, Stack
} from '@mui/material'
import { createVisitor, updateVisitor, getVisitor } from '../api/visitor.api'

export default function VisitorsForm() {
  const { id } = useParams()
  const navigate = useNavigate()
  const isEdit = Boolean(id)
  const user = useAuthStore((s) => s.user)
  const role = normalizeRole(user)
  const allowCreate = canCreateVisitor(role)
  const allowEdit = canEditVisitor(role)

  const [loading, setLoading] = useState(false)
  const [mastersLoading, setMastersLoading] = useState(true)
  const [errors, setErrors] = useState({})

  const [projects, setProjects] = useState([])
  const [departments, setDepartments] = useState([])
  const [visitorTypes, setVisitorTypes] = useState([])
  const [hosts, setHosts] = useState([])
  const [gates, setGates] = useState([])
  const [filteredProjects, setFilteredProjects] = useState([])
  const [filteredHosts, setFilteredHosts] = useState([])
  const [form, setForm] = useState({
    visitor_type_id: '',
    pass_no: '',
    project_id: '',
    department_id: '',
    host_id: '',
    entrance_id: '',
    first_name: '',
    last_name: '',
    designation: '',
    gender: '',
    company_name: '',
    company_address: '',
    primary_phone: '',
    alternate_phone: '',
    email: '',
    date_of_birth: '',
    blood_group: '',
    height_cm: '',
    visible_marks: '',
    temp_address: '',
    perm_address: '',
    work_order_no: '',
    work_order_expiry: '',
    police_verification_certificate_number: '',
    pvc_expiry: '',
    aadhaar: '',
    smartphone_allowed: false,
    smartphone_expiry: '',
    laptop_allowed: false,
    laptop_make: '',
    laptop_model: '',
    laptop_serial: '',
    laptop_expiry: '',
    ops_area_permitted: false,
    can_register_labours: false,
    valid_from: '',
    valid_to: '',
    allowed_gates: [],
    vehicle_number: '',
    vehicle_make: '',
    vehicle_model: '',
    vehicle_color: ''
  })


  useEffect(() => {

    if (!form.department_id) {
      setFilteredProjects([])
      return
    }

    const list = projects.filter(
      p => Number(p.department_id) === Number(form.department_id)
    )

    setFilteredProjects(list)

  }, [form.department_id, projects])



  useEffect(() => {

    if (!form.department_id) {
      setFilteredProjects([])
      return
    }

    const list = projects.filter(
      p => Number(p.department_id) === Number(form.department_id)
    )

    console.log("Filtered projects:", list)

    setFilteredProjects(list)

  }, [form.department_id, projects])

  useEffect(() => {

    if (!form.department_id) {
      setFilteredHosts([])
      return
    }

    let list = hosts.filter(
      h => Number(h.department_id) === Number(form.department_id)
    )

    // If project selected, filter hosts assigned to that project
    if (form.project_id) {
      list = list.filter(h =>
        Array.isArray(h.projects) &&
        h.projects.some(
          p => Number(p.project_id) === Number(form.project_id)
        )
      )
    }

    setFilteredHosts(list)

  }, [form.department_id, form.project_id, hosts])

  /* ---------- Load Master Data ---------- */
  useEffect(() => {
    async function fetchMasters() {
      try {
        const res = await getMasters()
        const data = res.data.data

        setProjects(data.projects || [])
        setDepartments(data.departments || [])
        setVisitorTypes(data.visitorTypes || [])
        setHosts(data.hosts || [])
        setGates(data.gates || [])
      } catch (err) {
        console.error('Failed to load master data', err)
      } finally {
        setMastersLoading(false)
      }
    }

    fetchMasters()
  }, [])

  /* ---------- Load Visitor (Edit Mode) ---------- */
  useEffect(() => {
    if (!isEdit) return
    async function fetchVisitor() {
      try {
        setLoading(true)
        const res = await getVisitor(id)
        const v = res?.data?.visitor || res?.data?.data || {}
        const toDate = (val) => (val ? new Date(val).toISOString().split('T')[0] : '')
        const toBool = (val) => {
          if (typeof val === 'boolean') return val
          if (val === 'true' || val === 't' || val === 1 || val === '1') return true
          return false
        }
        const safe = (val) => (val === null || val === undefined ? '' : val)

        setForm((prev) => ({
          ...prev,
          ...Object.fromEntries(
            Object.entries(v).map(([k, val]) => [k, safe(val)])
          ),
          aadhaar: '',
          date_of_birth: toDate(v.date_of_birth),
          work_order_expiry: toDate(v.work_order_expiry),
          pvc_expiry: toDate(v.pvc_expiry),
          smartphone_expiry: toDate(v.smartphone_expiry),
          laptop_expiry: toDate(v.laptop_expiry),
          valid_from: toDate(v.valid_from),
          valid_to: toDate(v.valid_to),
          smartphone_allowed: toBool(v.smartphone_allowed),
          laptop_allowed: toBool(v.laptop_allowed),
          ops_area_permitted: toBool(v.ops_area_permitted),
          can_register_labours: toBool(v.can_register_labours),
          vehicle_number: safe(v.vehicle_number),
          vehicle_make: safe(v.vehicle_make),
          vehicle_model: safe(v.vehicle_model),
          vehicle_color: safe(v.vehicle_color),
          allowed_gates: (res?.data?.allowed_gates || []).map((g) => Number(g)),
        }))
      } catch (err) {
        console.error('Failed to load visitor', err)
      } finally {
        setLoading(false)
      }
    }
    fetchVisitor()
  }, [id, isEdit])

  const handleChange = (e) => {
    const { name, value } = e.target
    const normalizedValue =
      typeof value === "string" && name !== "email"
        ? value.toUpperCase()
        : value

    if (name === "allowed_gates") {
      const selected = Array.isArray(value)
        ? value.map((v) => Number(v))
        : []
      setForm(prev => ({ ...prev, allowed_gates: selected }))
      return
    }

    if (name === "department_id") {
      setForm(prev => ({
        ...prev,
        department_id: normalizedValue,
        project_id: '',
        host_id: ''
      }))
      return
    }

    if (name === "project_id") {
      setForm(prev => ({
        ...prev,
        project_id: normalizedValue,
        host_id: ''
      }))
      return
    }

    setForm(prev => ({ ...prev, [name]: normalizedValue }))
  }

  const handleBoolChange = (key) => (e) => {
    setForm(prev => ({ ...prev, [key]: e.target.checked }))
  }

  const handleSubmit = async () => {
    if (isEdit ? !allowEdit : !allowCreate) {
      alert('You do not have permission to perform this action.')
      return
    }

    const nextErrors = {}
    const phone = form.primary_phone?.trim()
    const aadhaar = form.aadhaar?.trim()

    if (!form.first_name?.trim()) nextErrors.first_name = 'First name is required'
    if (!phone) nextErrors.primary_phone = 'Primary phone is required'
    else if (!/^\d{10,15}$/.test(phone)) nextErrors.primary_phone = 'Phone must be 10-15 digits'

    if (!form.visitor_type_id) nextErrors.visitor_type_id = 'Visitor type is required'
    if (!form.department_id) nextErrors.department_id = 'Department is required'
    if (!form.project_id) nextErrors.project_id = 'Project is required'
    if (!form.host_id) nextErrors.host_id = 'Host is required'
    if (!form.entrance_id) nextErrors.entrance_id = 'Entrance gate is required'
    if (!form.allowed_gates?.length) nextErrors.allowed_gates = 'Select at least one allowed gate'

    if (!isEdit && !form.pass_no?.trim()) nextErrors.pass_no = 'Pass number is required'
    if (!isEdit && !aadhaar) nextErrors.aadhaar = 'Aadhaar is required'
    if (aadhaar && !/^\d{12}$/.test(aadhaar)) nextErrors.aadhaar = 'Aadhaar must be 12 digits'

    if (form.email && !/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(form.email)) nextErrors.email = 'Invalid email'

    const toDate = (val) => (val ? new Date(val) : null)
    const validFrom = toDate(form.valid_from)
    const validTo = toDate(form.valid_to)
    if (validFrom && validTo && validFrom > validTo) nextErrors.valid_to = 'Valid to must be after valid from'

    setErrors(nextErrors)
    if (Object.keys(nextErrors).length) return

    try {
      setLoading(true)
      // Blacklist check
      try {
        const payload = {}
        if (form.aadhaar) payload.aadhaar = form.aadhaar
        if (!payload.aadhaar && form.primary_phone) payload.phone = form.primary_phone
        if (payload.aadhaar || payload.phone) {
          const res = await blacklistApi.checkBlacklist(payload)
          if (res?.data?.isBlacklisted) {
            const entry = res.data.entry || {}
            alert(
              `Blacklisted entry found.\nReason: ${entry.reason || 'N/A'}\nType: ${entry.block_type || 'N/A'}`
            )
            setLoading(false)
            return
          }
        }
      } catch (err) {
        console.error('Blacklist check failed', err)
        setLoading(false)
        setErrors({ ...nextErrors, blacklist: 'Blacklist check failed, please retry' })
        return
      }

      const payload = {
        ...form,
        smartphone_allowed: Boolean(form.smartphone_allowed),
        laptop_allowed: Boolean(form.laptop_allowed),
        ops_area_permitted: Boolean(form.ops_area_permitted),
        can_register_labours: Boolean(form.can_register_labours),
        allowed_gates: (form.allowed_gates || []).map((g) => Number(g)).filter((g) => !Number.isNaN(g)),
      }
      if (isEdit) {
        await updateVisitor(id, payload)
        navigate(`/visitors/${id}`)
      } else {
        const res = await createVisitor(payload)
        const newId = res?.data?.visitor?.id
        if (newId) {
          navigate(`/visitors/${newId}`)
        } else {
          navigate('/visitors')
        }
      }
    } catch (err) {
      console.error(err)
      alert(err?.response?.data?.error || 'Error saving visitor')
    } finally {
      setLoading(false)
    }
  }

  if (loading || mastersLoading) {
    return (
      <Box display="flex" justifyContent="center" mt={5}>
        <CircularProgress />
      </Box>
    )
  }

  if (isEdit ? !allowEdit : !allowCreate) {
    return (
      <AccessDenied
        title="Access Restricted"
        message="You do not have permission to create or edit visitor profiles."
        onBack={() => navigate('/visitors')}
      />
    )
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

  <Avatar sx={{width:80,height:80,bgcolor:"#1e293b"}}>
  {form.first_name?.[0]}
  </Avatar>

  <Box>

  <Typography variant="h5" fontWeight={700}>
  {isEdit ? "Edit Visitor" : "Add New Visitor"}
  </Typography>

  <Typography sx={{opacity:0.8}}>
  {form.first_name} {form.last_name}
  </Typography>

  <Stack direction="row" spacing={1} sx={{mt:1}}>

  <Chip
  label={isEdit ? "Editing Visitor" : "New Registration"}
  size="small"
  sx={{bgcolor:"#3b82f6",color:"#fff",fontWeight:600}}
  />



  </Stack>

  </Box>
  </Box>

  </Paper>



  {/* ================= BASIC INFORMATION ================= */}

  <SectionCard title="Basic Information">

  <Grid container spacing={2}>

  <Field
  select
  label="Visitor Type"
  name="visitor_type_id"
  value={form.visitor_type_id}
  onChange={handleChange}
  error={Boolean(errors.visitor_type_id)}
  helperText={errors.visitor_type_id}
  >
  {visitorTypes.map(v=>(
  <MenuItem key={v.id} value={v.id}>
  {v.type_name}
  </MenuItem>
  ))}
  </Field>


  <Field
  label="Visitor Pass No"
  name="pass_no"
  value={form.pass_no}
  onChange={handleChange}
  error={Boolean(errors.pass_no)}
  helperText={errors.pass_no}
  disabled={isEdit}
  />


  <Field
  select
  label="Department"
  name="department_id"
  value={form.department_id}
  onChange={handleChange}
  >
  {departments.map(d=>(
  <MenuItem key={d.id} value={d.id}>
  {d.department_name}
  </MenuItem>
  ))}
  </Field>


  <Field
  select
  label="Project"
  name="project_id"
  value={
    mastersLoading
      ? ''
      : filteredProjects.some((p) => String(p.id) === String(form.project_id))
      ? form.project_id
      : ''
  }
  onChange={handleChange}
  disabled={!form.department_id}
  >
  {filteredProjects.map(p=>(
  <MenuItem key={p.id} value={p.id}>
  {p.project_name}
  </MenuItem>
  ))}
  </Field>


  <Field
  select
  label="Host"
  name="host_id"
  value={
    mastersLoading
      ? ''
      : filteredHosts.some((h) => String(h.id) === String(form.host_id))
      ? form.host_id
      : ''
  }
  onChange={handleChange}
  disabled={!form.project_id}
  >
  {filteredHosts.map(h=>(
  <MenuItem key={h.id} value={h.id}>
  {h.host_name}
  </MenuItem>
  ))}
  </Field>


  <Field
  label="First Name"
  name="first_name"
  value={form.first_name}
  onChange={handleChange}
  error={Boolean(errors.first_name)}
  helperText={errors.first_name}
  />


  <Field
  label="Last Name"
  name="last_name"
  value={form.last_name}
  onChange={handleChange}
  />


  <Field
  select
  label="Gender"
  name="gender"
  value={form.gender}
  onChange={handleChange}
  >
  <MenuItem value="">Select</MenuItem>
  <MenuItem value="MALE">Male</MenuItem>
  <MenuItem value="FEMALE">Female</MenuItem>
  <MenuItem value="OTHER">Other</MenuItem>
  </Field>


  <Field label="Designation" name="designation" value={form.designation} onChange={handleChange}/>

  <Field label="Company Name" name="company_name" value={form.company_name} onChange={handleChange}/>

  <Field fullWidth label="Company Address" name="company_address" value={form.company_address} onChange={handleChange}/>

  <Field
  label={isEdit ? "Aadhaar (optional)" : "Aadhaar"}
  name="aadhaar"
  value={form.aadhaar}
  onChange={handleChange}
  error={Boolean(errors.aadhaar)}
  helperText={errors.aadhaar}
  />

  <Field select label="Blood Group" name="blood_group" value={form.blood_group} onChange={handleChange}>
  <MenuItem value="">Select</MenuItem>
  <MenuItem value="A+">A+</MenuItem>
  <MenuItem value="A-">A-</MenuItem>
  <MenuItem value="B+">B+</MenuItem>
  <MenuItem value="B-">B-</MenuItem>
  <MenuItem value="AB+">AB+</MenuItem>
  <MenuItem value="AB-">AB-</MenuItem>
  <MenuItem value="O+">O+</MenuItem>
  <MenuItem value="O-">O-</MenuItem>
  </Field>

  <Field label="Height (cm)" name="height_cm" value={form.height_cm} onChange={handleChange}/>

  <Field label="Visible Marks" name="visible_marks" value={form.visible_marks} onChange={handleChange}/>

  <Field
  type="date"
  label="Date of Birth"
  name="date_of_birth"
  value={form.date_of_birth}
  onChange={handleChange}
  InputLabelProps={{shrink:true}}
  />

  </Grid>

  </SectionCard>



  {/* ================= CONTACT ================= */}

  <SectionCard title="Contact Details">

  <Grid container spacing={2}>

  <Field
  label="Primary Phone"
  name="primary_phone"
  value={form.primary_phone}
  onChange={handleChange}
  error={Boolean(errors.primary_phone)}
  helperText={errors.primary_phone}
  />

  <Field label="Alternate Phone" name="alternate_phone" value={form.alternate_phone} onChange={handleChange}/>

  <Field fullWidth label="Email" name="email" value={form.email} onChange={handleChange}/>

  <Field fullWidth label="Temporary Address" name="temp_address" value={form.temp_address} onChange={handleChange}/>

  <Field fullWidth label="Permanent Address" name="perm_address" value={form.perm_address} onChange={handleChange}/>

  </Grid>

  </SectionCard>

  {/* ================= VEHICLE DETAILS ================= */}

  <SectionCard title="Vehicle Details">

  <Grid container spacing={2}>

  <Field label="Vehicle Number" name="vehicle_number" value={form.vehicle_number} onChange={handleChange}/>
  <Field label="Make" name="vehicle_make" value={form.vehicle_make} onChange={handleChange}/>
  <Field label="Model" name="vehicle_model" value={form.vehicle_model} onChange={handleChange}/>
  <Field label="Color" name="vehicle_color" value={form.vehicle_color} onChange={handleChange}/>

  </Grid>

  </SectionCard>



  {/* ================= CLEARANCE ================= */}

  <SectionCard title="Clearance & Compliance">

  <Grid container spacing={2}>

  <Field label="Work Order No" name="work_order_no" value={form.work_order_no} onChange={handleChange}/>

  <Field
  type="date"
  label="Work Order Expiry"
  name="work_order_expiry"
  value={form.work_order_expiry}
  onChange={handleChange}
  InputLabelProps={{shrink:true}}
  />

  <Field
  label="PVC Number"
  name="police_verification_certificate_number"
  value={form.police_verification_certificate_number}
  onChange={handleChange}
  />

  <Field
  type="date"
  label="PVC Expiry"
  name="pvc_expiry"
  value={form.pvc_expiry}
  onChange={handleChange}
  InputLabelProps={{shrink:true}}
  />

  </Grid>

  </SectionCard>



  {/* ================= GATE PERMISSIONS ================= */}

  <SectionCard title="Gate Permissions">

  <Grid container spacing={2}>

  <Grid size={{ xs: 12, sm: 6 }}>
    <TextField
      select
      fullWidth
      label="Allowed Gates"
      name="allowed_gates"
      value={form.allowed_gates}
      onChange={handleChange}
      SelectProps={{
        multiple: true,
        renderValue: (selected) => {
          if (!selected?.length) return "All gates"
          const names = gates
            .filter((g) => selected.includes(g.id))
            .map((g) => g.gate_name || g.name || `Gate ${g.id}`)
          return names.join(", ")
        }
      }}
      helperText="Select one or more gates. Leave empty for all gates."
    >
      {gates.map((g) => (
        <MenuItem key={g.id} value={g.id}>
          <Checkbox checked={form.allowed_gates.includes(g.id)} />
          <Typography sx={{ ml: 1 }}>{g.gate_name || g.name}</Typography>
        </MenuItem>
      ))}
    </TextField>
  </Grid>

  </Grid>

  </SectionCard>



  {/* ================= ACCESS PERMISSIONS ================= */}

  <SectionCard title="Access Permissions">

  <Stack direction="row" spacing={2} flexWrap="wrap">

  <FormControlLabel
  control={<Checkbox checked={form.smartphone_allowed} onChange={handleBoolChange("smartphone_allowed")}/>}
  label="Smartphone Allowed"
  />

  <FormControlLabel
  control={<Checkbox checked={form.laptop_allowed} onChange={handleBoolChange("laptop_allowed")}/>}
  label="Laptop Allowed"
  />

  <FormControlLabel
  control={<Checkbox checked={form.ops_area_permitted} onChange={handleBoolChange("ops_area_permitted")}/>}
  label="Ops Area Permitted"
  />

  <FormControlLabel
  control={<Checkbox checked={form.can_register_labours} onChange={handleBoolChange("can_register_labours")}/>}
  label="Labour Supervisor"
  />

  </Stack>


  {form.smartphone_allowed && (

  <Grid container spacing={2} mt={1}>

  <Field
  type="date"
  label="Smartphone Expiry"
  name="smartphone_expiry"
  value={form.smartphone_expiry}
  onChange={handleChange}
  InputLabelProps={{shrink:true}}
  />

  </Grid>

  )}


  {form.laptop_allowed && (

  <Grid container spacing={2} mt={1}>

  <Field label="Laptop Make" name="laptop_make" value={form.laptop_make} onChange={handleChange}/>

  <Field label="Laptop Model" name="laptop_model" value={form.laptop_model} onChange={handleChange}/>

  <Field label="Laptop Serial" name="laptop_serial" value={form.laptop_serial} onChange={handleChange}/>

  <Field
  type="date"
  label="Laptop Expiry"
  name="laptop_expiry"
  value={form.laptop_expiry}
  onChange={handleChange}
  InputLabelProps={{shrink:true}}
  />

  </Grid>

  )}

  </SectionCard>



  {/* ================= PASS VALIDITY ================= */}

  <SectionCard title="Pass Validity">

  <Grid container spacing={2}>

  <Field
  type="date"
  label="Valid From"
  name="valid_from"
  value={form.valid_from}
  onChange={handleChange}
  InputLabelProps={{shrink:true}}
  />

  <Field
  type="date"
  label="Valid To"
  name="valid_to"
  value={form.valid_to}
  onChange={handleChange}
  InputLabelProps={{shrink:true}}
  />

  </Grid>

  </SectionCard>



  {/* ================= ACTIONS ================= */}

  <Paper
  sx={{
  p:2,
  borderRadius:3,
  display:"flex",
  justifyContent:"flex-end",
  gap:2
  }}
  >

  <Button variant="outlined" onClick={()=>navigate("/visitors")}>
  Cancel
  </Button>

  <Button variant="contained" onClick={handleSubmit}>
  {isEdit ? "Update Visitor" : "Create Visitor"}
  </Button>

  </Paper>

  </Box>
  )
}

/* ---------- Reusable ---------- */

function SectionCard({title,children}){

  return(

  <Paper
  sx={{
  p:2.5,
  mb:3,
  borderRadius:3,
  border:"1px solid rgba(15,23,42,0.08)"
  }}
  >

  <Typography variant="h6" fontWeight={600} sx={{mb:2}}>
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

function Field(props) {
  return (
    <Grid size={{ xs: 12, sm: 6 }}>
      <TextField fullWidth variant="outlined" {...props} />
    </Grid>
  )
}

function AccessDenied({ title, message, onBack }) {
  return (
    <Paper sx={{ p: 3, maxWidth: 720, mx: 'auto' }}>
      <Alert severity="warning" sx={{ mb: 2 }}>
        <Typography fontWeight={700}>{title}</Typography>
        <Typography variant="body2">{message}</Typography>
      </Alert>
      <Box display="flex" justifyContent="flex-end">
        <Button variant="contained" onClick={onBack}>
          Back to Visitors
        </Button>
      </Box>
    </Paper>
  )
}
