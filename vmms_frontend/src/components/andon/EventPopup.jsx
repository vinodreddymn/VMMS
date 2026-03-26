import React from "react";
import { Box, Typography, Card } from "@mui/material";
import { formatDateTime } from "../../utils/timeUtils";

export default function EventPopup({ event, resolvePhoto }) {
  if (!event) return null;

  const isEntry = event.direction === "IN";
  const isLabour = event.person_type === "LABOUR";

  const entryExitColor = isEntry ? "#2e7d32" : "#c62828";
  const typeColor = isLabour ? "#ef6c00" : "#1565c0";

  const getGateColor = (gate = "") => {
    const g = gate.toLowerCase();
    if (g.includes("mgr")) return "#1565c0";
    if (g.includes("sgr")) return "#ef6c00";
    if (g.includes("nora")) return "#6a1b9a";
    return "#424242";
  };

  const gateColor = getGateColor(event.gate_name);

  const registeredPhoto = resolvePhoto?.(
    isLabour
      ? event.supervisor_enrollment_photo_path || event.enrollment_photo_path
      : event.enrollment_photo_path
  );

  const livePhoto = resolvePhoto?.(event.live_photo_path);

  const formatDate = (d) => {
    if (!d) return "-";
    const date = new Date(d);
    return isNaN(date) ? "-" : date.toLocaleDateString("en-GB");
  };

  const permissions = event.permissions
    ? String(event.permissions)
        .split(/[,;]/)
        .map((p) => p.trim())
    : [];

  return (
    <Box
      sx={{
        position: "fixed",
        inset: 0,
        background: "rgba(0,0,0,0.85)",
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        zIndex: 9999,
      }}
    >
      <Card
        sx={{
          display: "flex",
          width: 1200,
          minHeight: 520,
          borderRadius: 4,
          overflow: "hidden",
          boxShadow: "0 25px 80px rgba(0,0,0,0.6)",
        }}
      >
        {/* LEFT STRIP */}
        <GateStrip gate={event.gate_name} color={gateColor} />

        {/* MAIN CARD */}
        <Box sx={{ flex: 1, display: "flex", flexDirection: "column" }}>
          
          {/* ===== TOP BANNER ===== */}
          <Box
            sx={{
              background: entryExitColor,
              color: "#fff",
              px: 3,
              py: 1.2,
              display: "flex",
              justifyContent: "space-between",
              alignItems: "center",
            }}
          >
            <Typography fontWeight={900} fontSize={18} letterSpacing={1.5}>
              {isEntry ? "ENTRY" : "EXIT"}
            </Typography>

            <Typography fontWeight={800}>
              {formatDateTime(event.scan_time)}
            </Typography>
          </Box>

          {/* ===== BODY ===== */}
          <Box
            sx={{
              flex: 1,
              display: "flex",
              background: "#fff",
              p: 3,
              gap: 3,
            }}
          >
            {/* LEFT PHOTO */}
            <CenterBox>
              <PhotoBlock title="REGISTERED" src={registeredPhoto} />
            </CenterBox>

            {/* DETAILS */}
            <Box sx={{ flex: 1 }}>
              
              {/* NAME */}
              <Typography
                sx={{
                  fontSize: 28,
                  fontWeight: 900,
                  display: "flex",
                  gap: 1,
                  whiteSpace: "nowrap",
                  overflow: "hidden",
                  textOverflow: "ellipsis",
                }}
              >
                <span>{event.full_name || "-"}</span>
                <span style={{ fontSize: 14, color: "#666" }}>
                  — {event.designation || "—"}
                </span>
              </Typography>

              {/* PASS ID */}
              <Typography fontSize={11} color="text.secondary" mt={1} mb={2}>
                PASS ID:{" "}
                <strong>{event.pass_no || event.token_uid || "-"}</strong>
              </Typography>

              {/* SIMPLE LIST */}
              <InfoRow label="COMPANY" value={event.company_name} />
              <InfoRow label="PHONE" value={event.phone} />
              <InfoRow label="PROJECT" value={event.project_name} />
              <InfoRow label="DEPARTMENT" value={event.department_name} />

              <InfoRow
                label="VALIDITY"
                value={`${formatDate(event.pass_valid_from)} → ${formatDate(
                  event.pass_valid_to
                )}`}
              />

              <InfoRow
                label="ACCESS"
                value={permissions.length ? permissions.join(", ") : "-"}
              />
            </Box>

            {/* RIGHT PHOTO */}
            <CenterBox>
              <PhotoBlock title="LIVE" src={livePhoto} highlight />
            </CenterBox>
          </Box>

          {/* ===== BOTTOM BANNER ===== */}
          <Box
            sx={{
              background: typeColor,
              color: "#fff",
              px: 3,
              py: 1.2,
              display: "flex",
              justifyContent: "space-between",
              alignItems: "center",
              borderTop: "1px dashed rgba(255,255,255,0.4)",
            }}
          >
            <Typography fontSize={11} letterSpacing={1.5}>
              PASS TYPE
            </Typography>

            <Typography fontSize={18} fontWeight={900}>
              {isLabour ? "👷 LABOUR" : "👤 VISITOR"}
            </Typography>

            <Typography fontSize={11}>AUTHORIZED</Typography>
          </Box>
        </Box>

        {/* RIGHT STRIP */}
        <GateStrip gate={event.gate_name} color={gateColor} right />
      </Card>
    </Box>
  );
}

/* CENTER WRAPPER */
function CenterBox({ children }) {
  return (
    <Box
      sx={{
        flex: 1,
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
      }}
    >
      {children}
    </Box>
  );
}

/* GATE STRIP */
function GateStrip({ gate, color, right }) {
  return (
    <Box
      sx={{
        width: 70,
        background: color,
        color: "#fff",
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        position: "relative",
      }}
    >
      <Box
        sx={{
          position: "absolute",
          top: 0,
          bottom: 0,
          [right ? "left" : "right"]: 0,
          width: 6,
          background:
            "repeating-linear-gradient(to bottom,#fff,#fff 6px,transparent 6px,transparent 12px)",
        }}
      />

      <Typography
        sx={{
          writingMode: "vertical-rl",
          fontWeight: 900,
          fontSize: 18,
        }}
      >
        {gate || "GATE"}
      </Typography>
    </Box>
  );
}

/* PHOTO */
function PhotoBlock({ title, src, highlight }) {
  return (
    <Box
      sx={{
        width: 240,
        height: 270,
        borderRadius: 3,
        overflow: "hidden",
        border: highlight ? "2px solid #4caf50" : "1px solid #ddd",
      }}
    >
      <Box sx={{ p: 0.5, background: "#f5f5f5" }}>
        <Typography fontSize={10} fontWeight={700}>
          {title}
        </Typography>
      </Box>

      <Box sx={{ flex: 1, height: "100%" }}>
        {src ? (
          <img
            src={src}
            alt={title}
            style={{ width: "100%", height: "100%", objectFit: "cover" }}
          />
        ) : (
          <Box
            height="100%"
            display="flex"
            alignItems="center"
            justifyContent="center"
          >
            No Photo
          </Box>
        )}
      </Box>
    </Box>
  );
}

/* INFO ROW */
function InfoRow({ label, value }) {
  return (
    <Box display="flex" gap={1} mb={0.5}>
      <Typography fontSize={10} color="text.secondary" minWidth={90}>
        {label}
      </Typography>
      <Typography fontSize={13} fontWeight={800} noWrap>
        {value || "-"}
      </Typography>
    </Box>
  );
}