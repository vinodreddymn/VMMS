import React, { useCallback, useEffect, useMemo, useState } from "react";
import {
  Alert,
  Box,
  Button,
  Chip,
  CircularProgress,
  IconButton,
  Paper,
  Snackbar,
  Stack,
  TextField,
  Tooltip,
  Typography,
} from "@mui/material";
import RefreshIcon from "@mui/icons-material/Refresh";
import DeleteIcon from "@mui/icons-material/Delete";

import DataTable from "../components/common/DataTable";
import { listBlacklist, removeBlacklist } from "../api/blacklist.api";
import BlacklistForm from "./BlacklistForm";

export default function Blacklist() {
  const [rows, setRows] = useState([]);
  const [loading, setLoading] = useState(false);
  const [search, setSearch] = useState("");
  const [formOpen, setFormOpen] = useState(false);
  const [snackbar, setSnackbar] = useState({
    open: false,
    message: "",
    severity: "success",
  });

  // =====================================================
  // FETCH DATA
  // =====================================================
  const fetchBlacklist = useCallback(async () => {
    try {
      setLoading(true);

      const res = await listBlacklist();
      const data = res?.data?.entries || [];

      const normalized = (data || [])
        .filter(Boolean)
        .map((row) => ({
          id: row.id,
          phone: row.phone || "",
          reason: row.reason || "",
          block_type: row.block_type || "",
          aadhaar_hash: row.aadhaar_hash || null,
          biometric_hash: row.biometric_hash || null,
          created_at: row.created_at || null,
        }));

      setRows(normalized);
    } catch (err) {
      console.error(err);
      setSnackbar({
        open: true,
        message: "Failed to load blacklist",
        severity: "error",
      });
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    fetchBlacklist();
  }, [fetchBlacklist]);

  // =====================================================
  // SEARCH FILTER
  // =====================================================
  const filteredRows = useMemo(() => {
    if (!search.trim()) return rows;

    const q = search.toLowerCase();

    return rows.filter((row) =>
      [
        row.phone,
        row.reason,
        row.block_type,
        row.aadhaar_hash,
        row.biometric_hash,
      ]
        .filter(Boolean)
        .some((val) => String(val).toLowerCase().includes(q))
    );
  }, [rows, search]);

  // =====================================================
  // REMOVE ENTRY
  // =====================================================
  const handleRemove = useCallback(
    async (row) => {
      if (!row?.id) return;

      const label = row.phone || "this entry";

      if (!window.confirm(`Remove ${label} from blacklist?`)) return;

      try {
        await removeBlacklist(row.id);

        setSnackbar({
          open: true,
          message: "Removed from blacklist",
          severity: "success",
        });

        fetchBlacklist();
      } catch (err) {
        console.error(err);
        setSnackbar({
          open: true,
          message: "Failed to remove entry",
          severity: "error",
        });
      }
    },
    [fetchBlacklist]
  );

  // =====================================================
  // TABLE COLUMNS (IMPORTANT: value, row pattern)
  // =====================================================
  const columns = useMemo(
    () => [
      { key: "id", label: "ID", width: "6%" },

      {
        key: "phone",
        label: "Phone",
        render: (value) => value || "—",
      },

      {
        key: "aadhaar_hash",
        label: "Aadhaar",
        render: (value) =>
          value ? (
            <Chip
              size="small"
              label={`Hashed (${String(value).slice(0, 6)}…)`}
            />
          ) : (
            "—"
          ),
      },

      {
        key: "biometric_hash",
        label: "Biometric",
        render: (value) =>
          value ? <Chip size="small" label="Stored" /> : "—",
      },

      {
        key: "reason",
        label: "Reason",
        render: (value) => value || "—",
      },

      {
        key: "block_type",
        label: "Type",
        render: (value) => (
          <Chip
            size="small"
            label={value || "—"}
            color={
              value === "PERMANENT"
                ? "error"
                : value === "TEMP"
                ? "warning"
                : "default"
            }
            variant="outlined"
          />
        ),
      },

      {
        key: "created_at",
        label: "Created At",
        width: "16%",
        render: (value) =>
          value ? new Date(value).toLocaleString() : "—",
      },
    ],
    []
  );

  // =====================================================
  // UI
  // =====================================================
  return (
    <Box sx={{ p: 3 }}>
      {/* HEADER */}
      <Stack
        direction={{ xs: "column", md: "row" }}
        spacing={2}
        justifyContent="space-between"
        mb={2}
      >
        <Box>
          <Typography variant="h5" fontWeight={700}>
            Blacklist
          </Typography>
          <Typography variant="body2" color="text.secondary">
            Manage blocked Aadhaar, phone, and biometric entries
          </Typography>
        </Box>

        <Stack direction="row" spacing={1}>
          <TextField
            size="small"
            placeholder="Search..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
          />

          <Tooltip title="Refresh">
            <IconButton onClick={fetchBlacklist} disabled={loading}>
              <RefreshIcon />
            </IconButton>
          </Tooltip>

          <Button variant="contained" onClick={() => setFormOpen(true)}>
            Add
          </Button>
        </Stack>
      </Stack>

      {/* TABLE */}
      <Paper sx={{ p: 2, borderRadius: 2 }}>
        {loading ? (
          <Stack alignItems="center" py={4}>
            <CircularProgress />
          </Stack>
        ) : filteredRows.length === 0 ? (
          <Typography align="center" py={4} color="text.secondary">
            No blacklist entries found
          </Typography>
        ) : (
          <DataTable
            columns={columns}
            data={filteredRows}
            actions={[
              {
                label: "Remove",
                icon: DeleteIcon,
                onClick: handleRemove,
                color: "error",
              },
            ]}
          />
        )}
      </Paper>

      {/* FORM */}
      <BlacklistForm
        open={formOpen}
        onClose={() => setFormOpen(false)}
        onSaved={(res) => {
          setSnackbar({
            open: true,
            message: res?.success
              ? "Added to blacklist"
              : res?.message || "Failed to add entry",
            severity: res?.success ? "success" : "error",
          });

          fetchBlacklist();
        }}
      />

      {/* SNACKBAR */}
      <Snackbar
        open={snackbar.open}
        autoHideDuration={3000}
        onClose={() =>
          setSnackbar((prev) => ({ ...prev, open: false }))
        }
      >
        <Alert severity={snackbar.severity} sx={{ width: "100%" }}>
          {snackbar.message}
        </Alert>
      </Snackbar>
    </Box>
  );
}