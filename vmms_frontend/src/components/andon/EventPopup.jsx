import React, { useMemo } from "react";
import { Box, Typography, Card, Fade } from "@mui/material";
import { formatDateTime } from "../../utils/timeUtils";

/* ---------------- CONFIG ---------------- */
const REQUIRED_FIELDS = ["full_name", "pass_no", "scan_time", "person_type", "direction"];

/* ---------------- HELPERS ---------------- */
function isEventReady(event) {
  return REQUIRED_FIELDS.every((k) => event?.[k]);
}

function formatDateSafe(d) {
  if (!d) return "—";
  const date = new Date(d);
  return isNaN(date) ? "—" : date.toLocaleDateString("en-GB");
}

/* ---------------- MAIN ---------------- */
export default function EventPopupV2({ event, resolvePhoto }) {
  const ready = useMemo(() => isEventReady(event), [event]);

  // Do not render until mandatory data is present to avoid blank fields
  if (!event || !ready) return null;

  const isEntry = event.direction === "IN";
  const isLabour = event.person_type === "LABOUR";

  const entryColor = isEntry ? "#16a34a" : "#dc2626";
  const typeColor = isLabour ? "#f97316" : "#2563eb";

  const registeredPhoto = resolvePhoto?.(
    isLabour
      ? event.supervisor_enrollment_photo_path || event.enrollment_photo_path
      : event.enrollment_photo_path
  );

  const livePhoto = resolvePhoto?.(event.live_photo_path);

  const permissions = event.permissions
    ? String(event.permissions).split(/[,;]/).map((p) => p.trim())
    : [];

  return (
    <Fade in timeout={300} unmountOnExit>
      <Box
        sx={{
          position: "fixed",
          inset: 0,
          background: "rgba(0,0,0,0.88)",
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          zIndex: 9999,
        }}
      >
        <Card
          sx={{
            width: 1200,
            minHeight: 520,
            borderRadius: 4,
            overflow: "hidden",
            display: "flex",
            flexDirection: "column",
            boxShadow: "0 30px 90px rgba(0,0,0,0.7)",
          }}
        >
          {/* ================= HEADER ================= */}
          <Box
            sx={{
              background: entryColor,
              color: "#fff",
              px: 3,
              py: 1.5,
              display: "flex",
              justifyContent: "space-between",
            }}
          >
            <Typography fontWeight={900} fontSize={20}>
              {isEntry ? "ENTRY" : "EXIT"}
            </Typography>

            <Typography fontWeight={700}>
              {event.scan_time ? formatDateTime(event.scan_time) : "Loading..."}
            </Typography>
          </Box>

          {/* ================= BODY ================= */}
          <Box
            sx={{
              flex: 1,
              display: "flex",
              gap: 3,
              p: 3,
              background: "#fff",
            }}
          >
            {/* LEFT PHOTO */}
            <PhotoBlock title="REGISTERED" src={registeredPhoto} loading={!registeredPhoto} />

            {/* DETAILS */}
            <Box sx={{ flex: 1 }}>
              {!ready ? (
                <LoadingBlock />
              ) : (
                <>
                  <Typography fontSize={28} fontWeight={900}>
                    {event.full_name}
                  </Typography>

                  <Typography fontSize={12} color="text.secondary" mb={2}>
                    {event.designation || "—"}
                  </Typography>

                  <InfoRow label="PASS ID" value={event.pass_no} />
                  <InfoRow label="COMPANY" value={event.company_name} />
                  <InfoRow label="PHONE" value={event.phone} />
                  <InfoRow label="PROJECT" value={event.project_name} />
                  <InfoRow label="DEPARTMENT" value={event.department_name} />

                  <InfoRow
                    label="VALIDITY"
                    value={`${formatDateSafe(event.pass_valid_from)} → ${formatDateSafe(
                      event.pass_valid_to
                    )}`}
                  />

                  <InfoRow
                    label="ACCESS"
                    value={permissions.length ? permissions.join(", ") : "—"}
                  />
                </>
              )}
            </Box>

            {/* RIGHT PHOTO */}
            <PhotoBlock title="LIVE" src={livePhoto} highlight loading={!livePhoto} />
          </Box>

          {/* ================= FOOTER ================= */}
          <Box
            sx={{
              background: typeColor,
              color: "#fff",
              px: 3,
              py: 1.2,
              display: "flex",
              justifyContent: "space-between",
            }}
          >
            <Typography fontSize={12}>PASS TYPE</Typography>

            <Typography fontSize={18} fontWeight={900}>
              {isLabour ? "👷 LABOUR" : "👤 VISITOR"}
            </Typography>

            <Typography fontSize={12}>
              {ready ? "AUTHORIZED" : "VERIFYING..."}
            </Typography>
          </Box>
        </Card>
      </Box>
    </Fade>
  );
}

/* ---------------- COMPONENTS ---------------- */

function LoadingBlock() {
  return (
    <Box>
      <Typography fontSize={20} fontWeight={700}>
        Fetching Details...
      </Typography>
      <Typography fontSize={12} color="text.secondary">
        Please wait while we load complete data
      </Typography>
    </Box>
  );
}

function PhotoBlock({ title, src, highlight, loading }) {
  return (
    <Box
      sx={{
        width: 240,
        height: 270,
        borderRadius: 3,
        overflow: "hidden",
        border: highlight ? "2px solid #22c55e" : "1px solid #ddd",
      }}
    >
      <Box sx={{ p: 0.5, background: "#f5f5f5" }}>
        <Typography fontSize={10} fontWeight={700}>
          {title}
        </Typography>
      </Box>

      <Box
        sx={{
          height: "100%",
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          background: "#fafafa",
        }}
      >
        {loading ? (
          <Typography fontSize={12} color="text.secondary">
            Loading...
          </Typography>
        ) : src ? (
          <img src={src} alt={title} style={{ width: "100%", height: "100%", objectFit: "cover" }} />
        ) : (
          <Typography fontSize={12}>No Photo</Typography>
        )}
      </Box>
    </Box>
  );
}

function InfoRow({ label, value }) {
  return (
    <Box display="flex" gap={1} mb={0.6}>
      <Typography fontSize={11} color="text.secondary" minWidth={110}>
        {label}
      </Typography>
      <Typography fontSize={14} fontWeight={700} noWrap>
        {value || "—"}
      </Typography>
    </Box>
  );
}
