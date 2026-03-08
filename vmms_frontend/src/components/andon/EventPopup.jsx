import React from "react";
import { Box, Chip, Divider, Paper, Typography } from "@mui/material";
import Grid from "@mui/material/Grid";

import PersonIcon from "@mui/icons-material/Person";
import BadgeIcon from "@mui/icons-material/Badge";
import PhoneAndroidIcon from "@mui/icons-material/PhoneAndroid";
import ShieldIcon from "@mui/icons-material/Shield";
import BusinessIcon from "@mui/icons-material/Business";
import SupervisorAccountIcon from "@mui/icons-material/SupervisorAccount";
import AccessTimeIcon from "@mui/icons-material/AccessTime";
import VerifiedUserIcon from "@mui/icons-material/VerifiedUser";
import BadgeOutlinedIcon from "@mui/icons-material/BadgeOutlined";

import { formatDateTime } from "../../utils/timeUtils";

const ENTRY_COLOR = "#0F7A4D";
const EXIT_COLOR = "#B7352E";
const DARK_BG = "#0b1d2e";
const LIGHT_BG = "#f8fafc";

export default function EventPopup({ event, resolvePhoto }) {
  if (!event) return null;

  const isEntry = event.direction === "IN";
  const themeColor = isEntry ? ENTRY_COLOR : EXIT_COLOR;
  const directionLabel = isEntry ? "ENTRY AUTHORIZED" : "EXIT AUTHORIZED";

  const dbPhotoUrl = resolvePhoto?.(event.enrollment_photo_path);
  const livePhotoUrl = resolvePhoto?.(event.live_photo_path);

  return (
    <Box sx={styles.overlay}>
      <Paper elevation={16} sx={{ ...styles.shell, borderColor: themeColor }}>
        <Box sx={{ ...styles.header, background: themeColor }}>
          <Box sx={styles.headerLeft}>
            <Box sx={styles.headerBadge}>
              <VerifiedUserIcon sx={{ fontSize: 20 }} />
            </Box>
            <Box>
              <Typography sx={styles.headerTitle}>{directionLabel}</Typography>
              <Typography sx={styles.headerSub}>
                {event.person_type || "PERSON"} ACCESS LOG
              </Typography>
            </Box>
          </Box>
          <Box sx={styles.headerRight}>
            <Chip
              icon={<AccessTimeIcon />}
              label={formatDateTime(event.scan_time)}
              sx={styles.timeChip}
            />
            <Chip
              icon={<BadgeOutlinedIcon />}
              label={event.pass_no || event.token_uid || "PASS/TOKEN"}
              sx={styles.idChip}
            />
          </Box>
        </Box>

        <Box sx={styles.body}>
          <Grid container spacing={2}>
            <Grid size={{ xs: 12, md: 4 }}>
              <Box sx={styles.photoColumn}>
                <PhotoCard title="REGISTERED PHOTO" src={dbPhotoUrl} />
                <PhotoCard title="LIVE CAPTURE" src={livePhotoUrl} live />
              </Box>
            </Grid>

            <Grid size={{ xs: 12, md: 8 }}>
              <Box sx={styles.detailsPanel}>
                <Typography sx={styles.personName}>
                  {event.full_name || "UNKNOWN PERSON"}
                </Typography>
                <Typography sx={styles.personMeta}>
                  {event.project_name || "PROJECT"} - {event.gate_name || "GATE"}
                </Typography>

                <Divider sx={{ my: 2 }} />

                <Grid container spacing={1.5}>
                  <InfoCard icon={<PersonIcon />} label="TYPE" value={event.person_type} />
                  <InfoCard icon={<ShieldIcon />} label="DIRECTION" value={event.direction} accent={themeColor} />
                  <InfoCard icon={<PhoneAndroidIcon />} label="PHONE" value={event.phone} />
                  <InfoCard icon={<BadgeIcon />} label="AADHAAR LAST4" value={event.aadhaar_last4} />
                  <InfoCard icon={<SupervisorAccountIcon />} label="SUPERVISOR" value={event.supervisor_name} />
                  <InfoCard icon={<BusinessIcon />} label="DEPARTMENT" value={event.department_name} />
                  <InfoCard icon={<BusinessIcon />} label="HOST" value={event.host_name} />
                  <InfoCard icon={<BadgeIcon />} label="TOKEN UID" value={event.token_uid} />
                </Grid>

                <Box sx={styles.footerTime}>
                  <AccessTimeIcon sx={{ fontSize: "inherit", verticalAlign: "middle", mr: 0.5 }} />
                  Scanned at {formatDateTime(event.scan_time)}
                </Box>
              </Box>
            </Grid>
          </Grid>
        </Box>
      </Paper>
    </Box>
  );
}

function PhotoCard({ title, src, live = false }) {
  const hasSrc = Boolean(src);
  return (
    <Box sx={styles.photoCard}>
      <Box sx={styles.photoHeader}>
        <Typography sx={styles.photoLabel}>{title}</Typography>
        {live && (
          <Chip
            label="LIVE"
            size="small"
            sx={styles.liveChip}
          />
        )}
      </Box>
      <Box sx={styles.photoFrame}>
        {hasSrc ? (
          <Box component="img" src={src} alt={title} sx={styles.photoImg} />
        ) : (
          <Box sx={styles.photoEmpty}>NO PHOTO</Box>
        )}
      </Box>
    </Box>
  );
}

function InfoCard({ icon, label, value, accent }) {
  return (
    <Grid size={{ xs: 12, sm: 6, md: 4 }}>
      <Box sx={styles.infoCard}>
        <Box sx={{ ...styles.infoIcon, color: accent || "#334155" }}>{icon}</Box>
        <Box>
          <Typography sx={styles.infoLabel}>{label}</Typography>
          <Typography sx={{ ...styles.infoValue, color: accent || "#0f172a" }}>
            {value || "-"}
          </Typography>
        </Box>
      </Box>
    </Grid>
  );
}

const styles = {
  overlay: {
    position: "fixed",
    inset: 0,
    background:
      "radial-gradient(1200px 600px at 15% 0%, rgba(16,185,129,0.1), transparent 60%), radial-gradient(900px 500px at 90% 0%, rgba(239,68,68,0.1), transparent 55%), rgba(2,6,23,0.86)",
    backdropFilter: "blur(10px)",
    display: "flex",
    alignItems: "center",
    justifyContent: "center",
    zIndex: 2000,
    p: { xs: 2, sm: 3 },
  },
  shell: {
    width: "78%",
    maxWidth: 1180,
    maxHeight: "90vh",
    borderRadius: 3,
    overflow: "hidden",
    border: "2px solid",
    boxShadow: "0 30px 80px rgba(0,0,0,0.65)",
  },
  header: {
    display: "flex",
    alignItems: "center",
    justifyContent: "space-between",
    padding: "18px 28px",
    color: "#fff",
  },
  headerLeft: {
    display: "flex",
    alignItems: "center",
    gap: 2,
  },
  headerBadge: {
    width: 40,
    height: 40,
    borderRadius: "50%",
    background: "rgba(255,255,255,0.2)",
    display: "grid",
    placeItems: "center",
  },
  headerTitle: {
    fontSize: 24,
    fontWeight: 900,
    letterSpacing: 1.1,
  },
  headerSub: {
    fontSize: 11,
    letterSpacing: 1.4,
    color: "rgba(255,255,255,0.82)",
  },
  headerRight: {
    display: "flex",
    gap: 1.2,
    alignItems: "center",
  },
  timeChip: {
    background: "rgba(0,0,0,0.25)",
    color: "#fff",
    fontWeight: 700,
  },
  idChip: {
    background: "rgba(255,255,255,0.2)",
    color: "#fff",
    fontWeight: 700,
  },
  body: {
    padding: 22,
    background: "#eef2f7",
    maxHeight: "calc(90vh - 78px)",
    overflow: "auto",
  },
  photoColumn: {
    display: "grid",
    gap: 2,
  },
  photoCard: {
    background: DARK_BG,
    padding: 14,
    borderRadius: 12,
    border: "1px solid rgba(255,255,255,0.08)",
  },
  photoHeader: {
    display: "flex",
    alignItems: "center",
    justifyContent: "space-between",
    marginBottom: 8,
  },
  photoLabel: {
    color: "#e2e8f0",
    fontWeight: 700,
    letterSpacing: 0.8,
  },
  liveChip: {
    height: 20,
    fontSize: "0.68rem",
    fontWeight: 800,
    background: "#ef4444",
    color: "#fff",
  },
  photoFrame: {
    position: "relative",
    borderRadius: 10,
    overflow: "hidden",
    border: "2px solid rgba(255,255,255,0.18)",
    background: "linear-gradient(180deg, rgba(2,6,23,0.8), rgba(2,6,23,0.6))",
  },
  photoImg: {
    width: "100%",
    height: 200,
    objectFit: "cover",
    display: "block",
  },
  photoEmpty: {
    height: 200,
    display: "flex",
    alignItems: "center",
    justifyContent: "center",
    fontWeight: 800,
    letterSpacing: 2,
    color: "rgba(226,232,240,0.85)",
    background: "rgba(2,6,23,0.6)",
  },
  detailsPanel: {
    background: LIGHT_BG,
    padding: 20,
    borderRadius: 12,
    border: "1px solid rgba(15,23,42,0.08)",
  },
  personName: {
    fontSize: 26,
    fontWeight: 900,
    color: "#0f172a",
  },
  personMeta: {
    fontSize: 14,
    color: "#475569",
  },
  infoCard: {
    display: "flex",
    alignItems: "center",
    gap: 12,
    padding: 12,
    borderRadius: 10,
    background: "#f8fafc",
    border: "1px solid rgba(15,23,42,0.08)",
  },
  infoIcon: {
    fontSize: 26,
  },
  infoLabel: {
    fontSize: 10,
    color: "#64748b",
    letterSpacing: 0.6,
  },
  infoValue: {
    fontWeight: 800,
  },
  footerTime: {
    marginTop: 16,
    fontSize: "0.75rem",
    textAlign: "right",
    color: "#64748b",
  },
};
