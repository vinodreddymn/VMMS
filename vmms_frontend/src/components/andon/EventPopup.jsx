import React from "react";
import { Typography } from "@mui/material";
import { formatDateTime } from "../../utils/timeUtils";

export default function EventPopup({ event, resolvePhoto }) {
if (!event) return null;

const registeredPhoto = resolvePhoto?.(event.enrollment_photo_path);
const livePhoto = resolvePhoto?.(event.live_photo_path);
const isEntry = event.direction === "IN";

const labelStyle = { color: "#666" };
const valueStyle = { color: "#000", fontWeight: "500" };

return (
<div
style={{
position: "fixed",
top: 0,
left: 0,
width: "100%",
height: "100%",
background: "rgba(0,0,0,0.6)",
display: "flex",
justifyContent: "center",
alignItems: "center",
zIndex: 9999
}}
>
<div
style={{
background: "white",
width: 720,
borderRadius: 6,
boxShadow: "0 8px 30px rgba(0,0,0,0.25)",
overflow: "hidden"
}}
>


    {/* Header */}
    <div
      style={{
        background: isEntry ? "#1e8e3e" : "#c62828",
        color: "white",
        padding: "12px 20px",
        display: "flex",
        justifyContent: "space-between",
        alignItems: "center"
      }}
    >
      <Typography variant="h6" style={{ fontWeight: "bold" }}>
        {isEntry ? "ENTRY AUTHORIZED" : "EXIT AUTHORIZED"}
      </Typography>

      <Typography>
        {formatDateTime(event.scan_time)}
      </Typography>
    </div>

    <div style={{ padding: 20 }}>

      <Typography style={{ marginBottom: 12 }}>
        <span style={labelStyle}>Pass / Token:</span>{" "}
        <span style={{ ...valueStyle, color: "#0d47a1" }}>
          {event.pass_no || event.token_uid}
        </span>
      </Typography>

      {/* Photos */}
      <div
        style={{
          display: "flex",
          gap: 30,
          justifyContent: "center",
          marginBottom: 20
        }}
      >
        <div style={{ textAlign: "center" }}>
          <Typography style={{ color: "#555" }}>Registered Photo</Typography>
          {registeredPhoto ? (
            <img
              src={registeredPhoto}
              alt="registered"
              style={{
                width: 220,
                height: 220,
                objectFit: "cover",
                border: "1px solid #ccc"
              }}
            />
          ) : (
            <Typography>No Photo</Typography>
          )}
        </div>

        <div style={{ textAlign: "center" }}>
          <Typography style={{ color: "#555" }}>Live Capture</Typography>
          {livePhoto ? (
            <img
              src={livePhoto}
              alt="live"
              style={{
                width: 220,
                height: 220,
                objectFit: "cover",
                border: "1px solid #ccc"
              }}
            />
          ) : (
            <Typography>No Photo</Typography>
          )}
        </div>
      </div>

      {/* Name */}
      <Typography
        variant="h6"
        style={{
          color: "#0d47a1",
          fontWeight: "bold",
          marginBottom: 12
        }}
      >
        {event.full_name}
      </Typography>

      {/* Details */}
      <div
        style={{
          display: "grid",
          gridTemplateColumns: "1fr 1fr",
          rowGap: 8
        }}
      >
        <Typography>
          <span style={labelStyle}>Type:</span>{" "}
          <span style={valueStyle}>{event.person_type}</span>
        </Typography>

        <Typography>
          <span style={labelStyle}>Phone:</span>{" "}
          <span style={{ ...valueStyle, color: "#1565c0" }}>
            {event.phone}
          </span>
        </Typography>

        <Typography>
          <span style={labelStyle}>Department:</span>{" "}
          <span style={{ ...valueStyle, color: "#6a1b9a" }}>
            {event.department_name}
          </span>
        </Typography>

        <Typography>
          <span style={labelStyle}>Supervisor:</span>{" "}
          <span style={{ ...valueStyle, color: "#6a1b9a" }}>
            {event.supervisor_name}
          </span>
        </Typography>

        <Typography>
          <span style={labelStyle}>Host:</span>{" "}
          <span style={valueStyle}>{event.host_name}</span>
        </Typography>

        <Typography>
          <span style={labelStyle}>Gate:</span>{" "}
          <span style={{ ...valueStyle, color: "#2e7d32" }}>
            {event.gate_name}
          </span>
        </Typography>

        <Typography>
          <span style={labelStyle}>Project:</span>{" "}
          <span style={{ ...valueStyle, color: "#5d4037" }}>
            {event.project_name}
          </span>
        </Typography>
      </div>

    </div>
  </div>
</div>

);
}
