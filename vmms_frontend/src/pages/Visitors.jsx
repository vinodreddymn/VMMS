import React, { useEffect, useState, useCallback, useRef, useMemo } from "react"
import { useNavigate } from "react-router-dom"

import { listVisitors } from "../api/visitor.api"
import DataTable from "../components/common/DataTable"
import SearchBar from "../components/common/SearchBar"
import Pagination from "../components/common/Pagination"
import VisitorForm from "./VisitorForm"

import useAuthStore from "../store/auth.store"
import { normalizeRole, canCreateVisitor, canEditVisitor } from "../utils/visitorPermissions"

import {
  Box,
  Paper,
  Typography,
  Button,
  Chip,
  Tooltip,
  CircularProgress,
  Snackbar,
  Alert
} from "@mui/material"

import RefreshIcon from "@mui/icons-material/Refresh"
import AddIcon from "@mui/icons-material/Add"
import VisibilityIcon from "@mui/icons-material/Visibility"
import EditIcon from "@mui/icons-material/Edit"
import PersonIcon from "@mui/icons-material/Person"

export default function Visitors() {

  const navigate = useNavigate()

  const user = useAuthStore((s) => s.user)
  const role = normalizeRole(user)

  const allowCreate = canCreateVisitor(role)
  const allowEdit = canEditVisitor(role)

  const [visitors, setVisitors] = useState([])
  const [loading, setLoading] = useState(true)

  const [page, setPage] = useState(1)
  const [limit] = useState(20)
  const [totalPages, setTotalPages] = useState(1)

  const [query, setQuery] = useState("")
  const [searchInput, setSearchInput] = useState("")

  const [formOpen, setFormOpen] = useState(false)
  const [editingId, setEditingId] = useState(null)

  const debounceRef = useRef()

  const [snackbar, setSnackbar] = useState({
    open: false,
    severity: "success",
    message: ""
  })

  const formatDate = (val) => (val ? new Date(val).toLocaleDateString() : "-")

  /*
  -----------------------------------
  TABLE COLUMNS
  -----------------------------------
  */

  const columns = useMemo(() => [
    { key: "id", label: "ID" },
    { key: "pass_no", label: "Pass No" },
    { key: "full_name", label: "Visitor Name" },
    { key: "designation", label: "Designation" },
    { key: "company_name", label: "Company" },
    { key: "primary_phone", label: "Phone" },
    { key: "email", label: "Email" },
    { key: "status", label: "Status" },
    {
      key: "valid_from",
      label: "Valid From",
      render: (row) => formatDate(row.valid_from)
    },
    {
      key: "valid_to",
      label: "Valid To",
      render: (row) => formatDate(row.valid_to)
    }
  ], [])

  /*
  -----------------------------------
  FETCH VISITORS
  -----------------------------------
  */

  const fetchVisitors = useCallback(async () => {

    setLoading(true)

    try {

      const res = await listVisitors({
        page,
        limit,
        name: query
      })

      const data = res.data || {}

      setVisitors(data.visitors || [])
      setTotalPages(data.totalPages || 1)

    } catch (err) {

      setVisitors([])

      setSnackbar({
        open: true,
        severity: "error",
        message:
          err?.response?.data?.error || "Failed to load visitors"
      })

    } finally {

      setLoading(false)

    }

  }, [page, limit, query])

  useEffect(() => {
    fetchVisitors()
  }, [fetchVisitors])

  /*
  -----------------------------------
  SEARCH DEBOUNCE
  -----------------------------------
  */

  useEffect(() => {

    clearTimeout(debounceRef.current)

    debounceRef.current = setTimeout(() => {

      setQuery(searchInput)
      setPage(1)

    }, 400)

    return () => clearTimeout(debounceRef.current)

  }, [searchInput])

  /*
  -----------------------------------
  UI
  -----------------------------------
  */

  return (
    <>

      {/* HEADER */}

      <Paper
        elevation={0}
        sx={{
          p: 3,
          mb: 2,
          borderRadius: 3,
          background:
            "linear-gradient(135deg,#0f172a,#0f766e)",
          color: "#fff",
          boxShadow: "0 15px 40px rgba(0,0,0,0.25)"
        }}
      >

        <Box
          display="flex"
          justifyContent="space-between"
          alignItems="center"
          flexWrap="wrap"
          gap={2}
        >

          <Box>

            <Typography
              variant="h5"
              fontWeight={600}
            >
              Visitor Management
            </Typography>

            <Box
              mt={1}
              display="flex"
              gap={1}
              flexWrap="wrap"
            >

              <Chip
                icon={<PersonIcon />}
                label={`Visitors: ${visitors.length}`}
                sx={{ bgcolor: "rgba(255,255,255,0.15)", color: "#fff" }}
              />

              <Chip
                label={allowEdit ? "Edit Access" : "View Only"}
                sx={{
                  bgcolor: allowEdit
                    ? "rgba(34,197,94,0.25)"
                    : "rgba(248,113,113,0.25)",
                  color: "#fff"
                }}
              />

              <Chip
                label={allowCreate ? "Can Register Visitors" : "Registration Restricted"}
                sx={{
                  bgcolor: allowCreate
                    ? "rgba(56,189,248,0.25)"
                    : "rgba(148,163,184,0.25)",
                  color: "#fff"
                }}
              />

              <Chip
                label={`Role: ${role}`}
                sx={{
                  bgcolor: "rgba(0,0,0,0.3)",
                  color: "#fff"
                }}
              />

            </Box>

          </Box>


          {/* ACTION BUTTONS */}

          <Box display="flex" gap={1}>

            <Tooltip title="Reload visitor list">

              <Button
                variant="outlined"
                startIcon={<RefreshIcon />}
                onClick={fetchVisitors}
                sx={{
                  borderColor: "rgba(255,255,255,0.6)",
                  color: "#fff"
                }}
              >
                Refresh
              </Button>

            </Tooltip>

            <Tooltip
              title={
                allowCreate
                  ? "Register new visitor"
                  : "Only authorized staff can register visitors"
              }
            >

              <span>

                <Button
                  variant="contained"
                  startIcon={<AddIcon />}
                  disabled={!allowCreate}
                  onClick={() => {
                    setEditingId(null)
                    setFormOpen(true)
                  }}
                  sx={{
                    bgcolor: "#22d3ee",
                    color: "#0f172a",
                    "&:hover": { bgcolor: "#67e8f9" }
                  }}
                >
                  New Visitor
                </Button>

              </span>

            </Tooltip>

          </Box>

        </Box>

      </Paper>


      {/* SEARCH */}

      <Paper
        sx={{
          p: 2,
          mb: 2,
          borderRadius: 2,
          border: "1px solid #e2e8f0"
        }}
      >

        <SearchBar
          value={searchInput}
          onChange={setSearchInput}
          placeholder="Search visitor name, pass number, company..."
        />

      </Paper>


      {/* TABLE */}

      <Paper
        sx={{
          borderRadius: 2,
          overflow: "hidden",
          border: "1px solid #e2e8f0"
        }}
      >

        {loading ? (

          <Box py={6} display="flex" justifyContent="center">
            <CircularProgress />
          </Box>

        ) : visitors.length === 0 ? (

          <Box py={6} textAlign="center">
            <Typography color="text.secondary">
              No visitors found
            </Typography>
          </Box>

        ) : (

          <>

            <DataTable
              columns={columns}
              data={visitors}
              onRowClick={(row) =>
                navigate(`/visitors/${row.id}`)
              }
              actions={[
                {
                  label: <VisibilityIcon fontSize="small" />,
                  onClick: (row) =>
                    navigate(`/visitors/${row.id}`)
                },
                ...(allowEdit
                  ? [
                      {
                        label: <EditIcon fontSize="small" />,
                        onClick: (row) => {
                          setEditingId(row.id)
                          setFormOpen(true)
                        }
                      }
                    ]
                  : [])
              ]}
            />

            <Pagination
              page={page}
              totalPages={totalPages}
              onChange={setPage}
            />

          </>

        )}

      </Paper>


      {/* VISITOR FORM */}

      <VisitorForm
        open={formOpen}
        visitorId={editingId}
        onClose={() => setFormOpen(false)}
        onSaved={(result) => {

          if (result?.success) {

            setSnackbar({
              open: true,
              severity: "success",
              message: "Visitor saved successfully"
            })

            fetchVisitors()

          } else {

            setSnackbar({
              open: true,
              severity: "error",
              message: "Failed to save visitor"
            })

          }

        }}
      />


      {/* SNACKBAR */}

      <Snackbar
        open={snackbar.open}
        autoHideDuration={3000}
        onClose={() =>
          setSnackbar({ ...snackbar, open: false })
        }
      >

        <Alert
          severity={snackbar.severity}
          sx={{ width: "100%" }}
        >
          {snackbar.message}
        </Alert>

      </Snackbar>

    </>
  )
}