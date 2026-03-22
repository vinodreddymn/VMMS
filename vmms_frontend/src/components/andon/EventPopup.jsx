import React from "react";
import {
  Typography,
  Box,
  Card,
  CardContent,
  Chip,
  Divider,
  Paper,
  Avatar,
} from "@mui/material";

import { formatDateTime } from "../../utils/timeUtils";

export default function EventPopup({ event, resolvePhoto }) {
  if (!event) return null;

  const isEntry = event.direction === "IN";
  const isLabour = event.person_type === "LABOUR";

  const registeredPhotoPath = isLabour
    ? event.supervisor_enrollment_photo_path || event.enrollment_photo_path
    : event.enrollment_photo_path;

  const registeredPhoto = resolvePhoto?.(registeredPhotoPath);
  const livePhoto = resolvePhoto?.(event.live_photo_path);

  const visitorType =
    event.visitor_type ||
    event.type_name ||
    event.person_type ||
    "VISITOR";

  const companyName =
    event.company_name ||
    event.supervisor_company ||
    event.supervisor_company_name ||
    "-";

  const passValidityTo =
    event.pass_valid_to ||
    event.pass_valid_till ||
    event.pass_valid_until ||
    event.pass_expiry ||
    event.valid_upto ||
    event.pass_validity ||
    event.work_order_expiry ||
    null;

  const passValidityFrom =
    event.pass_valid_from ||
    event.valid_from ||
    null;

  const permissionsRaw =
    event.permissions ||
    event.permission_names ||
    event.allowed_gates ||
    event.gate_permissions ||
    null;

  const permissions = Array.isArray(permissionsRaw)
    ? permissionsRaw
    : permissionsRaw
    ? String(permissionsRaw)
        .split(/[,;]/)
        .map((s) => s.trim())
        .filter(Boolean)
    : [];

  const primaryColor = isLabour ? "#d84315" : "#1565c0";

  const getGateColor = (gateName = "") => {
    const name = gateName.toLowerCase();

    if (name.includes("mgr-001")) return "#1565c0";
    if (name.includes("mgr-002")) return "#2e7d32";
    if (name.includes("sgr-001")) return "#ef6c00";
    if (name.includes("nora-001")) return "#6a1b9a";
   

    return "#424242"; // default
  };

  const formatValidity = (value) => {
    if (!value) return "-";

    const d = new Date(value);
    if (Number.isNaN(d.getTime())) return "-";

    return d.toLocaleDateString("en-GB"); // DD/MM/YYYY
  };

  return (
    <Box
      sx={{
        position: "fixed",
        inset: 0,
        background: "rgba(0,0,0,0.65)",
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        zIndex: 9999,
        backdropFilter: "blur(4px)",
      }}
    >
      <Card
        sx={{
          width: 1060,
          borderRadius: 3,
          boxShadow: "0 20px 60px rgba(0,0,0,0.35)",
          overflow: "hidden",
          position: "relative", // 👈 IMPORTANT
        }}
      >
        {/* HEADER */}
        <Box
          sx={{
            background: primaryColor,
            color: "#fff",
            px: 3,
            py: 2,
            display: "flex",
            justifyContent: "space-between",
            alignItems: "center",
          }}
        >
          <Box>
            <Typography variant="h6" fontWeight={700}>
              {visitorType} {isEntry ? "ENTERED" : "EXITED"} FACILITY
            </Typography>
            <Typography variant="body2" sx={{ opacity: 0.9 }}>
              {isEntry ? "Checked in" : "Checked out"} at {formatDateTime(event.scan_time)}
            </Typography>
          </Box>

          <Chip
            label={isEntry ? "ENTRY AUTHORIZED" : "EXIT AUTHORIZED"}
            sx={{
              background: "#fff",
              color: primaryColor,
              fontWeight: 700,
            }}
          />
        </Box>


        {/* RIGHT SIDE GATE BANNER */}
          <Box
            sx={{
              position: "absolute",
              top: 84,
              right: 0,
              height: "calc(100% - 64px)",
              width: 70,
              background: getGateColor(event.gate_name),
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              writingMode: "vertical-rl",
              textOrientation: "mixed",
              color: "#fff",
              fontWeight: 700,
              letterSpacing: 3,
              fontSize: 26,
              px: 1,
              textAlign: "center",
              whiteSpace: "nowrap",
              overflow: "hidden",
              textOverflow: "ellipsis",
              boxShadow: isEntry
                ? "inset 0 0 10px rgba(0,255,0,0.6), -4px 0 12px rgba(0,0,0,0.2)"
                : "inset 0 0 10px rgba(255,0,0,0.6), -4px 0 12px rgba(0,0,0,0.2)",
            }}
          >
            {event.gate_name || "GATE"}
          </Box>

        <CardContent sx={{ p: 3 }}>
          <Box sx={{ display: "flex", gap: 3 }}>
            {/* LEFT - PHOTOS */}
            <Box
              sx={{
                width: 260,
                display: "flex",
                flexDirection: "column",
                gap: 2,
              }}
            >
              <Paper
                elevation={3}
                sx={{
                  p: 2,
                  borderRadius: 3,
                  background: "linear-gradient(145deg, #ffffff, #f5f7fa)",
                }}
              >
                {/* Section Header */}
                <Typography
                  variant="subtitle1"
                  sx={{
                    fontWeight: 600,
                    mb: 1.5,
                    color: "text.primary",
                    letterSpacing: 0.5,
                  }}
                >
                  Verification Photos
                </Typography>

                {/* Registered Photo */}
                <PhotoCard
                  title={
                    isLabour
                      ? "Supervisor Registered Photo"
                      : "Registered Photo"
                  }
                  src={registeredPhoto}
                />

                {/* Divider */}
                <Divider sx={{ my: 1.5 }} />

                {/* Live Capture with highlight */}
                <Box
                  sx={{
                    border: "2px solid",
                    borderColor: "success.main",
                    borderRadius: 2,
                    p: 1,
                    backgroundColor: "rgba(76, 175, 80, 0.05)",
                  }}
                >
                  <PhotoCard
                    title="Live Capture"
                    src={livePhoto}
                    highlight
                  />
                </Box>
              </Paper>
            </Box>

            {/* RIGHT - DETAILS */}
            <Box sx={{ flex: 1, pr: 8, display: "flex", flexDirection: "column", gap: 2 }}>
              
              {/* IDENTITY */}
              {/* IDENTITY */}
              <Box>
                <Typography variant="h5" fontWeight={700} color={primaryColor}>
                  {event.full_name}
                </Typography>

                {/* 👇 NEW: Designation moved here */}
                {event.designation && (
                  <Typography
                    variant="body2"
                    sx={{
                      fontWeight: 600,
                      color: "#616161",
                      mt: 0.3,
                    }}
                  >
                    {event.designation}
                  </Typography>
                )}

                <Typography variant="body2" color="text.secondary">
                  {event.pass_no || event.token_uid}
                </Typography>
              </Box>

              <Divider />

              {/* DETAILS LIST */}
              <Box sx={{ display: "flex", flexDirection: "column", gap: 1.5 }}>
                <InfoRow label="Type" value={visitorType} />
                <InfoRow label="Phone" value={event.phone} accent="#1565c0" />
                

                {isLabour && (
                  <InfoRow label="Supervisor" value={event.supervisor_name} />
                )}

                <InfoRow label="Company" value={companyName} />
                <InfoRow label="Project" value={event.project_name} accent="#6d4c41" />
                <InfoRow label="Department" value={event.department_name} />



                <InfoRow
                  label="Pass Validity"
                  value={
                    passValidityFrom || passValidityTo
                      ? passValidityFrom && passValidityTo
                        ? `${formatValidity(passValidityFrom)} → ${formatValidity(passValidityTo)}`
                        : formatValidity(passValidityFrom || passValidityTo)
                      : "-"
                  }
                />

                <InfoRow
                  label="Permissions"
                  value={permissions.length ? permissions : "-"}
                  isList
                />
              </Box>
            </Box>
          </Box>
        </CardContent>
      </Card>
    </Box>
  );
}

/* PHOTO CARD */
function PhotoCard({ title, src, highlight }) {
  return (
    <Box
      sx={{
        borderRadius: 2,
        overflow: "hidden",
        border: highlight ? "2px solid #1565c0" : "1px solid #ddd",
        background: "#fafafa",
      }}
    >
      <Box sx={{ px: 1.5, py: 0.5, background: "#f5f5f5" }}>
        <Typography variant="caption" fontWeight={600}>
          {title}
        </Typography>
      </Box>

      {src ? (
        <img
          src={src}
          alt={title}
          style={{
            width: "100%",
            height: 170,
            objectFit: "cover",
          }}
        />
      ) : (
        <Box
          sx={{
            height: 170,
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            color: "#999",
          }}
        >
          No Photo
        </Box>
      )}
    </Box>
  );
}

/* INFO ROW */
function InfoRow({ label, value, accent, chipColor, isList }) {
  return (
    <Box
      sx={{
        display: "flex",
        alignItems: "center",
        gap: 1,
        flexWrap: "wrap",
      }}
    >
      {/* LABEL */}
      <Typography
        variant="body2"
        sx={{
          color: "#616161",
          fontWeight: 500,
          minWidth: 130, // aligns all rows nicely
        }}
      >
        {label}:
      </Typography>

      {/* VALUE */}
      {chipColor ? (
        <Chip
          label={value || "-"}
          size="small"
          sx={{
            background: chipColor,
            color: "#fff",
            fontWeight: 700,
          }}
        />
      ) : isList && Array.isArray(value) ? (
        <Box sx={{ display: "flex", flexWrap: "wrap", gap: 0.5 }}>
          {value.length ? (
            value.map((v, i) => (
              <Chip key={i} label={v} size="small" sx={{ fontWeight: 600 }} />
            ))
          ) : (
            <Typography fontWeight={700}>-</Typography>
          )}
        </Box>
      ) : (
        <Typography
          variant="body1"
          sx={{
            fontWeight: 700,
            color: accent || "#212121",
            letterSpacing: 0.2,
          }}
        >
          {value || "-"}
        </Typography>
      )}
    </Box>
  );
}
