import React, { useEffect, useState } from 'react'
import DataTable from '../components/common/DataTable'
import bcrypt from 'bcryptjs'   // add at top
import {
  getUsers, addUser, updateUser, deactivateUser,
  getProjects, addProject, updateProject, deleteProject,
  getHosts, addHost, updateHost,
  getGates, addGate, updateGate,
  getRoles, createRole, updateRole,
  getDepartments, addDepartment, updateDepartment, deleteDepartment,
  getEntrances, addEntrance, updateEntrance, deleteEntrance,
  getVisitorRFIDCardStock, addVisitorRFIDCardStock, markVisitorRFIDCardStockDamaged,
  getLabourRFIDStock, addLabourRFIDStock, markLabourRFIDStockDamaged
} from '../api/admin.api'

import {
  Box, Tabs, Tab, Button, Dialog, DialogTitle, DialogContent, DialogActions,
  TextField, Typography, Stack, Switch, FormControlLabel, MenuItem,
  CircularProgress, Chip
} from '@mui/material'

export default function AdminUsers() {
  const [tab, setTab] = useState(0)
  const [loading, setLoading] = useState(false)
  const [search, setSearch] = useState('')

  const withSerial = (arr) => arr.map((r, i) => ({ ...r, sno: i + 1 }))

  /* ================= ROLES ================= */
  const [roles, setRoles] = useState([])
  const [openRole, setOpenRole] = useState(false)
  const [editingRole, setEditingRole] = useState(null)
  const [roleForm, setRoleForm] = useState({
    role_name: '', can_export_pdf: false, can_export_excel: false,
  })

  const fetchRoles = async () => {
    setLoading(true)
    try {
      const r = await getRoles()
      setRoles(r.data.roles || [])
    } finally {
      setLoading(false)
    }
  }

  /* ================= USERS ================= */
  const [users, setUsers] = useState([])
  const [openUser, setOpenUser] = useState(false)
  const [editingUser, setEditingUser] = useState(null)
  const [userForm, setUserForm] = useState({
    username: '', password: '', full_name: '', phone: '', role_id: '', is_active: true,
  })

  const fetchUsers = async () => {
    setLoading(true)
    try {
      const r = await getUsers()
      setUsers(r.data.users || [])
    } finally {
      setLoading(false)
    }
  }

  /* ================= PROJECTS ================= */
  const [projects, setProjects] = useState([])
  const [openProject, setOpenProject] = useState(false)
  const [editingProject, setEditingProject] = useState(null)
  const [projectForm, setProjectForm] = useState({ project_name: '', department_id: '' })

  const fetchProjects = async () => {
    setLoading(true)
    try {
      const r = await getProjects()
      setProjects(r.data.projects || [])
    } finally {
      setLoading(false)
    }
  }

  /* ================= HOSTS ================= */
  const [hosts, setHosts] = useState([])
  const [openHost, setOpenHost] = useState(false)
  const [editingHost, setEditingHost] = useState(null)
  const [hostForm, setHostForm] = useState({ host_name: '', phone: '', email: '', department_id: '' })
  const [selectedProjects, setSelectedProjects] = useState([])
  const [filteredProjects, setFilteredProjects] = useState([])

  const fetchHosts = async () => {
      setLoading(true)
      try {
        const r = await getHosts()
        setHosts(r.data.hosts || [])
      } finally {
        setLoading(false)
      }
    }

    useEffect(() => {
    if (!hostForm.department_id) {
      setFilteredProjects([])
      setSelectedProjects([])
      return
    }

    const filtered = projects.filter(
      p => p.department_id === hostForm.department_id
    )

    setFilteredProjects(filtered)

    // remove invalid selected projects when department changes
    setSelectedProjects(prev =>
      prev.filter(p => p.department_id === hostForm.department_id)
    )
  }, [hostForm.department_id, projects])

  /* ================= GATES ================= */
  const [gates, setGates] = useState([])
  const [openGate, setOpenGate] = useState(false)
  const [editingGate, setEditingGate] = useState(null)
  const [gateForm, setGateForm] = useState({ gate_name: '', entrance_id: '', ip_address: '', device_serial: '' })

  const fetchGates = async () => {
    setLoading(true)
    try {
      const r = await getGates()
      setGates(r.data.gates || [])
    } finally {
      setLoading(false)
    }
  }
  /* ================= DEPARTMENTS ================= */
const [departments, setDepartments] = useState([])
const [openDept, setOpenDept] = useState(false)
const [editingDept, setEditingDept] = useState(null)
const [deptForm, setDeptForm] = useState({ department_name: '', is_active: true })

const fetchDepartments = async () => {
  setLoading(true)
  try {
    const r = await getDepartments()
    setDepartments(r.data.departments || [])
  } finally {
    setLoading(false)
  }
}

/* ================= ENTRANCES ================= */
const [entrances, setEntrances] = useState([])
const [openEntrance, setOpenEntrance] = useState(false)
const [editingEntrance, setEditingEntrance] = useState(null)
const [entranceForm, setEntranceForm] = useState({
  entrance_code: '',
  entrance_name: '',
  is_main_gate: false,
})

const fetchEntrances = async () => {
  setLoading(true)
  try {
    const r = await getEntrances()
    setEntrances(r.data.entrances || [])
  } finally {
    setLoading(false)
  }
}

/* ================= VISITOR RFID CARD STOCK ================= */
const [visitorCardStock, setVisitorCardStock] = useState([])
const [visitorStockInput, setVisitorStockInput] = useState('')

const fetchVisitorCardStock = async () => {
  setLoading(true)
  try {
    const r = await getVisitorRFIDCardStock()
    setVisitorCardStock(r.data.stock || [])
  } catch (err) {
    console.error('Failed to fetch visitor RFID stock', err)
    alert(err?.response?.data?.error || 'Failed to fetch visitor RFID stock')
  } finally {
    setLoading(false)
  }
}

/* ================= LABOUR RFID TOKEN STOCK ================= */
const [labourTokenStock, setLabourTokenStock] = useState([])
const [labourStockInput, setLabourStockInput] = useState('')

const fetchLabourTokenStock = async () => {
  setLoading(true)
  try {
    const r = await getLabourRFIDStock()
    setLabourTokenStock(r.data.stock || [])
  } catch (err) {
    console.error('Failed to fetch labour token stock', err)
    alert(err?.response?.data?.error || 'Failed to fetch labour token stock')
  } finally {
    setLoading(false)
  }
}

  /* ================= LOAD PER TAB ================= */
  useEffect(() => {
    if (tab === 0) { fetchUsers(); fetchRoles() }
    if (tab === 1) { fetchProjects(); fetchDepartments() }
    if (tab === 2) fetchDepartments()
    if (tab === 3) fetchEntrances()
    if (tab === 4) { fetchHosts(); fetchDepartments(); fetchProjects() }
    if (tab === 5) { fetchGates(); fetchEntrances() }
    if (tab === 6) fetchRoles()
    if (tab === 7) fetchVisitorCardStock()
    if (tab === 8) fetchLabourTokenStock()
  }, [tab])

  /* ================= FILTER ================= */
  const filterData = (data) => {
    if (!search) return data
    return data.filter(row =>
      Object.values(row).some(v =>
        String(v ?? '').toLowerCase().includes(search.toLowerCase())
      )
    )
  }

  /* ================= CRUD HANDLERS ================= */
  const saveUser = async () => {
    if (!userForm.full_name || !userForm.role_id) {
      alert('Required fields missing')
      return
    }

    let payload = {
      full_name: userForm.full_name,
      phone: userForm.phone,
      role_id: userForm.role_id,
      is_active: userForm.is_active
    }

    // Only for new user
    if (!editingUser) {
      if (!userForm.username || !userForm.password) {
        alert('Username & Password required')
        return
      }

      const salt = await bcrypt.genSalt(10)
      const password_hash = await bcrypt.hash(userForm.password, salt)

      payload = {
        ...payload,
        username: userForm.username,
        password_hash
      }

      await addUser(payload)
    } else {
      await updateUser(editingUser.id, payload)
    }

    setOpenUser(false)
    setEditingUser(null)
    fetchUsers()
  }

  const saveProject = async () => {
    if (!projectForm.project_name) return alert('Project name required')

    if (editingProject) await updateProject(editingProject.id, projectForm)
    else await addProject(projectForm)

    await fetchProjects()   // ðŸ”¥ ensure updated joined data
    setOpenProject(false)
    setEditingProject(null)
  }

  const saveHost = async () => {
    if (!hostForm.host_name || !hostForm.phone) {
      alert('Host name & phone required')
      return
    }

    // ðŸ”’ Validate department-project match
    const invalid = selectedProjects.some(
      p => p.department_id !== hostForm.department_id
    )
    if (invalid) {
      alert("Selected projects do not belong to selected department")
      return
    }

    const payload = {
      ...hostForm,
      project_ids: selectedProjects.map(p => p.id)
    }

    try {
      if (editingHost) {
        await updateHost(editingHost.id, payload)
      } else {
        await addHost(payload)
      }

      await fetchHosts()
      setOpenHost(false)
      setEditingHost(null)
      setSelectedProjects([])
    } catch (err) {
      console.error('Error saving host:', err)
      alert(err?.response?.data?.error || 'Failed to save host')
    }
  }

  const saveGate = async () => {
    if (!gateForm.gate_name) {
      alert('Gate name required')
      return
    }

    try {
      if (editingGate) {
        await updateGate(editingGate.id, gateForm)
      } else {
        await addGate(gateForm)
      }

      await fetchGates()
      setOpenGate(false)
      setEditingGate(null)
    } catch (err) {
      console.error('Error saving gate:', err)
      alert('Failed to save gate')
    }
  }

  const saveRole = async () => {
    if (!roleForm.role_name) {
      alert('Role name required')
      return
    }

    try {
      if (editingRole) {
        await updateRole(editingRole.id, roleForm)
      } else {
        await createRole(roleForm)
      }

      await fetchRoles()
      setOpenRole(false)
      setEditingRole(null)
    } catch (err) {
      console.error('Error saving role:', err)
      alert('Failed to save role')
    }
  }

  const saveDepartment = async () => {
    if (!deptForm.department_name) {
      alert('Department name required')
      return
    }

    try {
      if (editingDept) {
        await updateDepartment(editingDept.id, deptForm)
      } else {
        await addDepartment(deptForm)
      }

      await fetchDepartments()
      setOpenDept(false)
      setEditingDept(null)
    } catch (err) {
      console.error('Error saving department:', err)
      alert('Failed to save department')
    }
  }

  const saveEntrance = async () => {
    if (!entranceForm.entrance_code) {
      alert('Entrance code required')
      return
    }

    try {
      if (editingEntrance) {
        await updateEntrance(editingEntrance.id, entranceForm)
      } else {
        await addEntrance(entranceForm)
      }

      await fetchEntrances()
      setOpenEntrance(false)
      setEditingEntrance(null)
    } catch (err) {
      console.error('Error saving entrance:', err)
      alert('Failed to save entrance')
    }
  }

  const parseStockInput = (value) =>
    String(value || '')
      .split(/[\n,;\s]+/g)
      .map((v) => v.trim())
      .filter(Boolean)

  const saveVisitorStock = async () => {
    const uids = parseStockInput(visitorStockInput)
    if (!uids.length) return alert('Enter at least one RFID UID')

    const r = await addVisitorRFIDCardStock({ uids })
    const inserted = r?.data?.inserted ?? 0
    const skipped = r?.data?.skipped ?? 0
    setVisitorStockInput('')
    await fetchVisitorCardStock()
    alert(`Added ${inserted} RFID card(s). Skipped ${skipped} duplicate(s).`)
  }

  const saveLabourStock = async () => {
    const uids = parseStockInput(labourStockInput)
    if (!uids.length) return alert('Enter at least one token UID')

    const r = await addLabourRFIDStock({ uids })
    const inserted = r?.data?.inserted ?? 0
    const skipped = r?.data?.skipped ?? 0
    setLabourStockInput('')
    await fetchLabourTokenStock()
    alert(`Added ${inserted} token(s). Skipped ${skipped} duplicate(s).`)
  }

  const markVisitorStockDamaged = async (row) => {
    const reason = window.prompt(`Reason for removing RFID ${row.uid}:`, 'Damaged')
    if (!reason) return
    await markVisitorRFIDCardStockDamaged(row.id, { reason })
    fetchVisitorCardStock()
  }

  const markLabourStockDamaged = async (row) => {
    const reason = window.prompt(`Reason for removing token ${row.uid}:`, 'Damaged')
    if (!reason) return
    await markLabourRFIDStockDamaged(row.id, { reason })
    fetchLabourTokenStock()
  }

  const confirmDelete = async (fn, id, reload) => {
    if (!window.confirm('Are you sure?')) return
    await fn(id)
    reload()
  }

  const openNewUser = () => {
  setEditingUser(null)
  setUserForm({
    username: '',
    password: '',
    full_name: '',
    phone: '',
    role_id: '',
    is_active: true,
  })
  setOpenUser(true)
}
  /* ================= RENDER ================= */
  return (
    <Box p={3}>
      <Typography variant="h5" mb={2}>Admin Master Management</Typography>

      <Tabs value={tab} onChange={(e, v) => setTab(v)} sx={{ mb: 2 }}>
        <Tab label="Users" />
        <Tab label="Projects" />
        <Tab label="Departments" />
        <Tab label="Entrances" />
        <Tab label="Hosts" />
        <Tab label="Gates" />
        <Tab label="Roles" />
        <Tab label="Visitor RFID Stock" />
        <Tab label="Labour RFID Stock" />
      </Tabs>

      <TextField
        size="small"
        placeholder="Search..."
        value={search}
        onChange={(e) => setSearch(e.target.value)}
        sx={{ mb: 2, width: 300 }}
      />

      {loading && <CircularProgress size={24} sx={{ mb: 2 }} />}

      {/* USERS */}
      {/* USERS TAB */}
      {tab === 0 && (
        <>
          <Button variant="contained" sx={{ mb: 2 }} onClick={openNewUser}>
            New User
          </Button>

          <DataTable
            columns={[
              { key: 'sno', label: 'S.No' },
              { key: 'username', label: 'Username' },
              { key: 'full_name', label: 'Full Name' },
              { key: 'phone', label: 'Phone' },
              { key: 'role_name', label: 'Role' },
              {
                key: 'is_active',
                label: 'Active',
                render: (v) => (
                  <Chip label={v ? 'Yes' : 'No'} color={v ? 'success' : 'default'} size="small" />
                )
              },
            ]}
            data={withSerial(users)}
            actions={[
              {
                label: 'Edit',
                onClick: (row) => {
                  setEditingUser(row)
                  setUserForm({
                    username: row.username,
                    password: '',
                    full_name: row.full_name,
                    phone: row.phone,
                    role_id: row.role_id,
                    is_active: row.is_active,
                  })
                  setOpenUser(true)
                },
              },
              {
                label: 'Deactivate',
                onClick: (row) => deactivateUser(row.id).then(fetchUsers),
              },
            ]}
          />
        </>
      )}

      {/* PROJECTS */}
      {tab === 1 && (
        <>
          <Button variant="contained" sx={{ mb: 1 }} onClick={() => {
            setEditingProject(null)
            setProjectForm({ project_name:'', department_id:'' })
            setOpenProject(true)
          }}>New Project</Button>

          <DataTable
            columns={[
              { key: 'sno', label: 'S.No' },
              { key: 'project_name', label: 'Project Name' },
              { key: 'department_name', label: 'Department' },
            ]}
            data={withSerial(filterData(projects))}
            actions={[
              { label: 'Edit', onClick: r => {
                setEditingProject(r)
                setProjectForm({ project_name:r.project_name, department_id:r.department_id })
                setOpenProject(true)
              }},
              { label: 'Delete', onClick: r => confirmDelete(deleteProject, r.id, fetchProjects) },
            ]}
          />
        </>
      )}


      {/* DEPARTMENTS */}
      {tab === 2 && (
        <>
          <Button variant="contained" sx={{ mb: 1 }} onClick={() => {
            setEditingDept(null)
            setDeptForm({ department_name: '', is_active: true })
            setOpenDept(true)
          }}>
            New Department
          </Button>

          <DataTable
            columns={[
              { key: 'sno', label: 'S.No' },
              { key: 'department_name', label: 'Department Name' },
              {
                key: 'is_active',
                label: 'Active',
                render: v => <Chip label={v ? 'Yes' : 'No'} size="small" />
              },
            ]}
            data={withSerial(filterData(departments))}
            actions={[
              {
                label: 'Edit',
                onClick: r => {
                  setEditingDept(r)
                  setDeptForm({ department_name: r.department_name, is_active: r.is_active })
                  setOpenDept(true)
                }
              },
              {
                label: 'Delete',
                onClick: r => confirmDelete(deleteDepartment, r.id, fetchDepartments)
              }
            ]}
          />
        </>
      )}

      {/* ENTRANCES */}
      {tab === 3 && (
        <>
          <Button variant="contained" sx={{ mb: 1 }} onClick={() => {
            setEditingEntrance(null)
            setEntranceForm({ entrance_code:'', entrance_name:'', is_main_gate:false })
            setOpenEntrance(true)
          }}>
            New Entrance
          </Button>

          <DataTable
            columns={[
              { key: 'sno', label: 'S.No' },
              { key: 'entrance_code', label: 'Code' },
              { key: 'entrance_name', label: 'Entrance Name' },
              {
                key: 'is_main_gate',
                label: 'Main Gate',
                render: v => <Chip label={v ? 'Yes' : 'No'} size="small" />
              },
            ]}
            data={withSerial(filterData(entrances))}
            actions={[
              {
                label: 'Edit',
                onClick: r => {
                  setEditingEntrance(r)
                  setEntranceForm({
                    entrance_code:r.entrance_code,
                    entrance_name:r.entrance_name,
                    is_main_gate:r.is_main_gate
                  })
                  setOpenEntrance(true)
                }
              },
              {
                label: 'Delete',
                onClick: r => confirmDelete(deleteEntrance, r.id, fetchEntrances)
              }
            ]}
          />
        </>
      )}

      {/* HOSTS */}
      {tab === 4 && (
        <>
          <Button variant="contained" sx={{ mb: 1 }} onClick={() => {
            setEditingHost(null)
            setHostForm({ host_name:'', phone:'', email:'', department_id:'' })
            setOpenHost(true)
          }}>New Host</Button>

          <DataTable
            columns={[
              { key: 'sno', label: 'S.No' },
              { key: 'host_name', label: 'Host Name' },
              { key: 'phone', label: 'Phone' },
              { key: 'email', label: 'Email' },
              { key: 'department_name', label: 'Department' },
              {
                key: 'projects',
                label: 'Projects',
                render: (_, row) => (
                  <>
                    {row.projects?.map(p => (
                      <Chip
                        key={p.project_id}
                        label={p.project_name}
                        size="small"
                        sx={{ mr: 0.5, mb: 0.5 }}
                      />
                    ))}
                  </>
                )
              },
            ]}
            data={withSerial(filterData(hosts))}
            actions={[
            {
              label: 'Edit',
              onClick: r => {
                setEditingHost(r)
                setHostForm({
                  host_name: r.host_name,
                  phone: r.phone,
                  email: r.email,
                  department_id: r.department_id
                })

                // ðŸ”¥ Normalize backend format â†’ frontend format
                setSelectedProjects(
                  (r.projects || []).map(p => ({
                    id: p.project_id,
                    project_name: p.project_name,
                    department_id: r.department_id
                  }))
                )

                setOpenHost(true)
              }
            },
          ]}
          />
        </>
      )}

      {/* GATES */}
      {tab === 5 && (
        <>
          <Button variant="contained" sx={{ mb: 1 }} onClick={() => {
            setEditingGate(null)
            setGateForm({ gate_name:'', entrance_id:'', ip_address:'', device_serial:'' })
            setOpenGate(true)
          }}>New Gate</Button>

          <DataTable
            columns={[
              { key: 'sno', label: 'S.No' },
              { key: 'gate_name', label: 'Gate Name' },
              { key: 'ip_address', label: 'IP Address' },
              { key: 'device_serial', label: 'Device Serial' },
              { key: 'entrance_name', label: 'Entrance' },
            ]}
            data={withSerial(filterData(gates))}
            actions={[
              { label: 'Edit', onClick: r => {
                setEditingGate(r)
                setGateForm({ gate_name:r.gate_name, entrance_id:r.entrance_id, ip_address:r.ip_address, device_serial:r.device_serial })
                setOpenGate(true)
              }},
            ]}
          />
        </>
      )}

      {/* ROLES */}
      {tab === 6 && (
        <>
          <Button variant="contained" sx={{ mb: 1 }} onClick={() => {
            setEditingRole(null)
            setRoleForm({ role_name:'', can_export_pdf:false, can_export_excel:false })
            setOpenRole(true)
          }}>New Role</Button>

          <DataTable
            columns={[
              { key: 'sno', label: 'S.No' },
              { key: 'role_name', label: 'Role Name' },
              { key: 'can_export_pdf', label: 'PDF Export', render:v=> <Chip label={v?'Yes':'No'} size="small"/> },
              { key: 'can_export_excel', label: 'Excel Export', render:v=> <Chip label={v?'Yes':'No'} size="small"/> },
            ]}
            data={withSerial(filterData(roles))}
            actions={[
              { label: 'Edit', onClick: r => {
                setEditingRole(r)
                setRoleForm({ role_name:r.role_name, can_export_pdf:r.can_export_pdf, can_export_excel:r.can_export_excel })
                setOpenRole(true)
              }},
            ]}
          />
        </>
      )}

      {/* VISITOR RFID CARD STOCK */}
      {tab === 7 && (
        <>
          <Stack direction={{ xs: 'column', md: 'row' }} spacing={1} sx={{ mb: 2 }}>
            <TextField
              fullWidth
              label="Add visitor RFID card UIDs"
              placeholder="Comma/newline separated UIDs"
              value={visitorStockInput}
              onChange={(e) => setVisitorStockInput(e.target.value)}
            />
            <Button variant="contained" onClick={saveVisitorStock}>
              Add Stock
            </Button>
          </Stack>

          <DataTable
            columns={[
              { key: 'sno', label: 'S.No' },
              { key: 'uid', label: 'RFID UID' },
              { key: 'status', label: 'Status', render: (v) => <Chip size="small" label={v || '-'} /> },
              { key: 'visitor_name', label: 'Assigned To' },
              { key: 'visitor_pass_no', label: 'Pass No' },
              { key: 'company_name', label: 'Company' },
              { key: 'removed_reason', label: 'Reason' },
            ]}
            data={withSerial(filterData(visitorCardStock))}
            actions={[
              {
                label: 'Mark Damaged',
                hidden: (row) => row.assigned || row.status !== 'AVAILABLE',
                onClick: (row) => {
                  if (row.status !== 'AVAILABLE') return alert('Only AVAILABLE RFID can be marked damaged.')
                  if (row.assigned) return alert('This RFID is assigned. Reassign/unassign first.')
                  markVisitorStockDamaged(row)
                },
              },
            ]}
          />
        </>
      )}

      {/* LABOUR RFID TOKEN STOCK */}
      {tab === 8 && (
        <>
          <Stack direction={{ xs: 'column', md: 'row' }} spacing={1} sx={{ mb: 2 }}>
            <TextField
              fullWidth
              label="Add labour token UIDs"
              placeholder="Comma/newline separated UIDs"
              value={labourStockInput}
              onChange={(e) => setLabourStockInput(e.target.value)}
            />
            <Button variant="contained" onClick={saveLabourStock}>
              Add Stock
            </Button>
          </Stack>

          <DataTable
            columns={[
              { key: 'sno', label: 'S.No' },
              { key: 'uid', label: 'Token UID' },
              { key: 'status', label: 'Status', render: (v) => <Chip size="small" label={v || '-'} /> },
              { key: 'labour_name', label: 'Assigned Labour' },
              { key: 'supervisor_name', label: 'Supervisor' },
              { key: 'supervisor_pass_no', label: 'Supervisor Pass' },
              { key: 'removed_reason', label: 'Reason' },
            ]}
            data={withSerial(filterData(labourTokenStock))}
            actions={[
              {
                label: 'Mark Damaged',
                hidden: (row) => row.assigned || row.status !== 'AVAILABLE',
                onClick: (row) => {
                  if (row.status !== 'AVAILABLE') return alert('Only AVAILABLE tokens can be marked damaged.')
                  if (row.assigned) return alert('This token is assigned. Return token first.')
                  markLabourStockDamaged(row)
                },
              },
            ]}
          />
        </>
      )}

      {/* ===== USER DIALOG ===== */}
      {/* USER DIALOG */}
      <Dialog open={openUser} onClose={() => setOpenUser(false)} maxWidth="sm" fullWidth>
        <DialogTitle>{editingUser ? 'Edit User' : 'New User'}</DialogTitle>
        <DialogContent>
          <Stack spacing={2} mt={1}>
            {!editingUser && (
              <>
                <TextField
                  label="Username"
                  value={userForm.username}
                  onChange={(e) => setUserForm({ ...userForm, username: e.target.value })}
                  fullWidth
                />
                <TextField
                  label="Password"
                  type="password"
                  value={userForm.password}
                  onChange={(e) => setUserForm({ ...userForm, password: e.target.value })}
                  fullWidth
                />
              </>
            )}

            <TextField
              label="Full Name"
              value={userForm.full_name}
              onChange={(e) => setUserForm({ ...userForm, full_name: e.target.value })}
              fullWidth
            />

            <TextField
              label="Phone"
              value={userForm.phone}
              onChange={(e) => setUserForm({ ...userForm, phone: e.target.value })}
              fullWidth
            />

            <TextField
              select
              label="Role"
              value={userForm.role_id}
              onChange={(e) => setUserForm({ ...userForm, role_id: Number(e.target.value) })}
              fullWidth
            >
              {roles.map((r) => (
                <MenuItem key={r.id} value={r.id}>
                  {r.role_name}
                </MenuItem>
              ))}
            </TextField>

            {editingUser && (
              <FormControlLabel
                control={
                  <Switch
                    checked={userForm.is_active}
                    onChange={(e) =>
                      setUserForm({ ...userForm, is_active: e.target.checked })
                    }
                  />
                }
                label="Active"
              />
            )}
          </Stack>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setOpenUser(false)}>Cancel</Button>
          <Button variant="contained" onClick={saveUser}>Save</Button>
        </DialogActions>
      </Dialog>

      {/* PROJECT DIALOG */}
      <Dialog open={openProject} onClose={()=>setOpenProject(false)} maxWidth="sm" fullWidth>
        <DialogTitle>{editingProject?'Edit Project':'New Project'}</DialogTitle>
        <DialogContent>
          <Stack spacing={2} mt={1}>
            <TextField
              label="Project Name"
              value={projectForm.project_name}
              onChange={e => setProjectForm({ ...projectForm, project_name: e.target.value })}
              fullWidth
            />

            <TextField
              select
              label="Department"
              value={projectForm.department_id}
              onChange={e => setProjectForm({ ...projectForm, department_id: Number(e.target.value) })}
              fullWidth
            >
              {departments.map(d => (
                <MenuItem key={d.id} value={d.id}>
                  {d.department_name}
                </MenuItem>
              ))}
            </TextField>
          </Stack>
        </DialogContent>
        <DialogActions>
          <Button onClick={()=>setOpenProject(false)}>Cancel</Button>
          <Button variant="contained" onClick={saveProject}>Save</Button>
        </DialogActions>
      </Dialog>

      <Dialog open={openDept} onClose={()=>setOpenDept(false)} maxWidth="sm" fullWidth>
        <DialogTitle>{editingDept?'Edit Department':'New Department'}</DialogTitle>
        <DialogContent>
          <Stack spacing={2} mt={1}>
            <TextField label="Department Name"
              value={deptForm.department_name}
              onChange={e=>setDeptForm({...deptForm,department_name:e.target.value})}/>
            <FormControlLabel
              control={<Switch checked={deptForm.is_active}
                onChange={e=>setDeptForm({...deptForm,is_active:e.target.checked})}/>}
              label="Active"/>
          </Stack>
        </DialogContent>
        <DialogActions>
          <Button onClick={()=>setOpenDept(false)}>Cancel</Button>
          <Button variant="contained" onClick={saveDepartment}>Save</Button>
        </DialogActions>
      </Dialog>

      <Dialog open={openEntrance} onClose={()=>setOpenEntrance(false)} maxWidth="sm" fullWidth>
        <DialogTitle>{editingEntrance?'Edit Entrance':'New Entrance'}</DialogTitle>
        <DialogContent>
          <Stack spacing={2} mt={1}>
            <TextField label="Entrance Code"
              value={entranceForm.entrance_code}
              onChange={e=>setEntranceForm({...entranceForm,entrance_code:e.target.value})}/>
            <TextField label="Entrance Name"
              value={entranceForm.entrance_name}
              onChange={e=>setEntranceForm({...entranceForm,entrance_name:e.target.value})}/>
            <FormControlLabel
              control={<Switch checked={entranceForm.is_main_gate}
                onChange={e=>setEntranceForm({...entranceForm,is_main_gate:e.target.checked})}/>}
              label="Main Gate"/>
          </Stack>
        </DialogContent>
        <DialogActions>
          <Button onClick={()=>setOpenEntrance(false)}>Cancel</Button>
          <Button variant="contained" onClick={saveEntrance}>Save</Button>
        </DialogActions>
      </Dialog>


      {/* HOST DIALOG */}
      <Dialog open={openHost} onClose={()=>setOpenHost(false)} maxWidth="sm" fullWidth>
        <DialogTitle>{editingHost?'Edit Host':'New Host'}</DialogTitle>
        <DialogContent>
          <Stack spacing={2} mt={1}>
            <TextField
              label="Host Name"
              value={hostForm.host_name}
              onChange={e=>setHostForm({...hostForm,host_name:e.target.value})}
            />

            <TextField
              label="Phone"
              value={hostForm.phone}
              onChange={e=>setHostForm({...hostForm,phone:e.target.value})}
            />

            <TextField
              label="Email"
              value={hostForm.email}
              onChange={e=>setHostForm({...hostForm,email:e.target.value})}
            />

            <TextField
              select
              label="Department"
              value={hostForm.department_id}
              onChange={e=>setHostForm({...hostForm,department_id:Number(e.target.value)})}
            >
              {departments.map(d => (
                <MenuItem key={d.id} value={d.id}>
                  {d.department_name}
                </MenuItem>
              ))}
            
            </TextField>  

            <TextField
              select
              label="Assign Projects"
              SelectProps={{ multiple: true }}
              value={selectedProjects.map(p => p.id)}
              onChange={(e) => {
                const ids = e.target.value
                const selected = filteredProjects.filter(p => ids.includes(p.id))
                setSelectedProjects(selected)
              }}
            >
              {filteredProjects.map(p => (
                <MenuItem key={p.id} value={p.id}>
                  {p.project_name}
                </MenuItem>
              ))}
            </TextField>        
          </Stack>
        </DialogContent>
        <DialogActions>
          <Button onClick={()=>setOpenHost(false)}>Cancel</Button>
          <Button variant="contained" onClick={saveHost}>Save</Button>
        </DialogActions>
      </Dialog>

      {/* GATE DIALOG */}
      <Dialog open={openGate} onClose={()=>setOpenGate(false)} maxWidth="sm" fullWidth>
        <DialogTitle>{editingGate?'Edit Gate':'New Gate'}</DialogTitle>
        <DialogContent>
          <Stack spacing={2} mt={1}>

            <TextField
              label="Gate Name"
              value={gateForm.gate_name}
              onChange={e=>setGateForm({...gateForm,gate_name:e.target.value})}
            />

            <TextField
              select
              label="Entrance"
              value={gateForm.entrance_id}
              onChange={e=>setGateForm({...gateForm,entrance_id:Number(e.target.value)})}
            >
              {entrances.map(en => (
                <MenuItem key={en.id} value={en.id}>
                  {en.entrance_name || en.entrance_code}
                </MenuItem>
              ))}
            </TextField>

            <TextField
              label="IP Address"
              value={gateForm.ip_address}
              onChange={e=>setGateForm({...gateForm,ip_address:e.target.value})}
            />

            <TextField
              label="Device Serial"
              value={gateForm.device_serial}
              onChange={e=>setGateForm({...gateForm,device_serial:e.target.value})}
            />
          </Stack>
        </DialogContent>
        <DialogActions>
          <Button onClick={()=>setOpenGate(false)}>Cancel</Button>
          <Button variant="contained" onClick={saveGate}>Save</Button>
        </DialogActions>
      </Dialog>

      {/* ROLE DIALOG */}
      <Dialog open={openRole} onClose={()=>setOpenRole(false)} maxWidth="sm" fullWidth>
        <DialogTitle>{editingRole?'Edit Role':'New Role'}</DialogTitle>
        <DialogContent>
          <Stack spacing={2} mt={1}>
            <TextField label="Role Name" value={roleForm.role_name} onChange={e=>setRoleForm({...roleForm,role_name:e.target.value})}/>
            <FormControlLabel control={<Switch checked={roleForm.can_export_pdf} onChange={e=>setRoleForm({...roleForm,can_export_pdf:e.target.checked})}/>} label="Can Export PDF"/>
            <FormControlLabel control={<Switch checked={roleForm.can_export_excel} onChange={e=>setRoleForm({...roleForm,can_export_excel:e.target.checked})}/>} label="Can Export Excel"/>
          </Stack>
        </DialogContent>
        <DialogActions>
          <Button onClick={()=>setOpenRole(false)}>Cancel</Button>
          <Button variant="contained" onClick={saveRole}>Save</Button>
        </DialogActions>
      </Dialog>
    </Box>
  )
}



