import React from "react"
import {
  Paper,
  Typography,
  Box,
  Table,
  TableHead,
  TableBody,
  TableRow,
  TableCell,
  Chip
} from "@mui/material"

import { formatTime } from "../../utils/timeUtils"

export default function VisitorTransactions({ rows = [], scrollRef }) {

  return (
    <Paper
      sx={{
        p: 1.4,
        borderRadius: 2,

        background: "rgba(8,23,42,0.75)",
        backdropFilter: "blur(6px)",

        border: "1px solid rgba(59,130,246,0.25)",

        height: "calc(100vh - 290px)",
        display: "flex",
        flexDirection: "column",

        boxShadow: "0 0 10px rgba(0,0,0,0.35)"
      }}
    >

      {/* HEADER */}

      <Box
        sx={{
          display: "flex",
          alignItems: "center",
          justifyContent: "space-between",
          mb: 1
        }}
      >

        <Typography
          sx={{
            fontWeight: 800,
            fontSize: 14,
            letterSpacing: 1.2,
            color: "#e6ecff"
          }}
        >
          VISITOR TRANSACTIONS
        </Typography>

        <Typography
          sx={{
            fontSize: 11,
            color: "#9fb3d9"
          }}
        >
          TODAY
        </Typography>

      </Box>

      {/* TABLE CONTAINER */}

      <Box
        ref={scrollRef}
        sx={{
          flex: 1,
          overflow: "auto",

          scrollbarWidth: "none",
          "&::-webkit-scrollbar": { display: "none" }
        }}
      >

        <Table stickyHeader size="small">

          {/* TABLE HEADER */}

          <TableHead>

            <TableRow>

              <TableCell
                sx={headerCellStyle}
              >
                TIME
              </TableCell>

              <TableCell sx={headerCellStyle}>
                NAME
              </TableCell>

              <TableCell sx={headerCellStyle}>
                PROJECT
              </TableCell>

              <TableCell sx={headerCellStyle}>
                GATE
              </TableCell>

              <TableCell sx={headerCellStyle}>
                DIR
              </TableCell>

            </TableRow>

          </TableHead>

          {/* TABLE BODY */}

          <TableBody>

            {rows.length === 0 && (
              <TableRow>
                <TableCell colSpan={5} align="center" sx={{ py: 3 }}>
                  <Typography sx={{ color: "#9fb3d9", fontSize: 12 }}>
                    No visitor transactions available
                  </Typography>
                </TableCell>
              </TableRow>
            )}

            {rows.map((row) => (

              <TableRow
                key={row.access_log_id}
                sx={{
                  "&:hover": {
                    background: "rgba(59,130,246,0.08)"
                  }
                }}
              >

                <TableCell sx={bodyCellStyle}>
                  {formatTime(row.scan_time)}
                </TableCell>

                <TableCell sx={bodyCellStyle}>
                  {row.full_name}
                </TableCell>

                <TableCell sx={bodyCellStyle}>
                  {row.project_name}
                </TableCell>

                <TableCell sx={bodyCellStyle}>
                  {row.gate_name}
                </TableCell>

                <TableCell sx={bodyCellStyle}>

                  <Chip
                    label={row.direction}
                    size="small"
                    sx={{
                      height: 20,
                      fontSize: 10,
                      fontWeight: 700,

                      color: row.direction === "IN"
                        ? "#16a34a"
                        : "#f97316",

                      background:
                        row.direction === "IN"
                          ? "rgba(34,197,94,0.12)"
                          : "rgba(249,115,22,0.12)",

                      border:
                        row.direction === "IN"
                          ? "1px solid rgba(34,197,94,0.35)"
                          : "1px solid rgba(249,115,22,0.35)"
                    }}
                  />

                </TableCell>

              </TableRow>

            ))}

          </TableBody>

        </Table>

      </Box>

    </Paper>
  )
}

/* ---------- STYLES ---------- */

const headerCellStyle = {
  fontSize: 11,
  fontWeight: 700,
  letterSpacing: 0.8,
  color: "#9fb3d9",

  background: "rgba(15,42,90,0.65)",
  borderBottom: "1px solid rgba(148,163,184,0.2)"
}

const bodyCellStyle = {
  fontSize: 12,
  color: "#e6ecff",
  borderBottom: "1px solid rgba(148,163,184,0.08)"
}