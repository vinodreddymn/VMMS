import React from "react"
import { Link, useLocation } from "react-router-dom"
import useAuthStore from "../../store/auth.store"

import {
  List,
  ListItem,
  ListItemButton,
  ListItemIcon,
  ListItemText,
  Divider,
  Typography,
  Box,
  Tooltip,
} from "@mui/material"

/* ICONS */

import DashboardIcon from "@mui/icons-material/Dashboard"
import PeopleIcon from "@mui/icons-material/People"
import EngineeringIcon from "@mui/icons-material/Engineering"
import ListAltIcon from "@mui/icons-material/ListAlt"
import LoginIcon from "@mui/icons-material/Login"
import TvIcon from "@mui/icons-material/Tv"
import InventoryIcon from "@mui/icons-material/Inventory"
import AssessmentIcon from "@mui/icons-material/Assessment"
import SecurityIcon from "@mui/icons-material/Security"
import SyncIcon from "@mui/icons-material/Sync"
import GroupIcon from "@mui/icons-material/Group"
import AccountCircleIcon from "@mui/icons-material/AccountCircle"

/* MENU STRUCTURE */

const menuStructure = [
  {
    label: "COMMAND",
    items: [
      { title: "Dashboard", path: "/", icon: DashboardIcon, exact: true },
      { title: "My Profile", path: "/profile", icon: AccountCircleIcon },
      { title: "Andon Display", path: "/andon", icon: TvIcon },
    ],
  },
  {
    label: "ENROLLMENT",
    items: [
      { title: "Visitors", path: "/visitors", icon: PeopleIcon },
      { title: "Labourers", path: "/labour", icon: EngineeringIcon },
      { title: "Manifest", path: "/labour/manifest", icon: ListAltIcon },
    ],
  },
  {
    label: "GATE OPERATIONS",
    items: [
      { title: "Gate Control", path: "/gate", icon: LoginIcon },
      { title: "Manual Gate Entry", path: "/gate/manual", icon: LoginIcon },
      { title: "Gate Display", path: "/gate/display", icon: TvIcon },
    ],
  },
  {
    label: "REPORTING",
    items: [
      { title: "Visitor Transactions", path: "/transactions/visitors", icon: AssessmentIcon },
      { title: "Labour Transactions", path: "/transactions/labours", icon: AssessmentIcon },
      { title: "Reports", path: "/reports", icon: AssessmentIcon },
    ],
  },
  {
    label: "SECURITY",
    adminOnlySection: true,
    items: [{ title: "Blacklist", path: "/blacklist", icon: SecurityIcon }],
  },
  {
    label: "SYSTEM CONTROL",
    adminOnlySection: true,
    items: [
      { title: "Sync", path: "/sync", icon: SyncIcon },
      { title: "Admin Users", path: "/admin/users", icon: GroupIcon },
    ],
  },
]

export default function Sidebar({ collapsed = false }) {
  const location = useLocation()
  const user = useAuthStore((s) => s.user)

  const role = (user?.role || user?.role_name || "USER").toUpperCase().trim()
  const isAdmin = role === "SUPER_ADMIN"

  const isActive = (path, exact) =>
    exact ? location.pathname === path : location.pathname.startsWith(path)

  return (
    <Box
      sx={{
        height: "100%",
        display: "flex",
        flexDirection: "column",
        background: "#0b1d2e",
      }}
    >
      {/* TOP COMMAND LABEL */}

      <Box
        sx={{
          px: collapsed ? 1 : 2,
          py: 2.3,
          borderBottom: "1px solid rgba(255,255,255,0.08)",
          display: "flex",
          justifyContent: collapsed ? "center" : "flex-start",
        }}
      >
        <Typography
          sx={{
            fontWeight: 800,
            letterSpacing: "0.14em",
            color: "#ffffff",
            fontSize: collapsed ? "0.85rem" : "1.05rem",
          }}
        >
          {collapsed ? "VMS" : "NAVAL COMMAND"}
        </Typography>
      </Box>

      {/* MENU */}

      <List
        sx={{
          pt: 2,
          pb: 2,
          px: collapsed ? 1 : 2,
          overflowY: "auto",
        }}
      >
        {menuStructure.map((group, idx) => {
          if (group.adminOnlySection && !isAdmin) return null

          return (
            <React.Fragment key={group.label}>
              {!collapsed && (
                <Typography
                  variant="caption"
                  sx={{
                    px: 1.5,
                    mt: idx > 0 ? 3 : 1,
                    mb: 0.8,
                    color: "rgba(230,236,255,0.55)",
                    fontWeight: 700,
                    letterSpacing: "0.16em",
                  }}
                >
                  {group.label}
                </Typography>
              )}

              {group.items.map((item) => {
                if (item.adminOnly && !isAdmin) return null

                const active = isActive(item.path, item.exact)
                const Icon = item.icon

                const button = (
                  <ListItemButton
                    component={Link}
                    to={item.path}
                    sx={{
                      borderRadius: 2,
                      minHeight: 46,
                      px: collapsed ? 1.5 : 2,
                      justifyContent: collapsed ? "center" : "flex-start",
                      position: "relative",
                      color: active ? "#ffffff" : "rgba(230,236,255,0.85)",

                      background: active
                        ? "linear-gradient(90deg,#1e3a8a,#1d4ed8)"
                        : "transparent",

                      transition: "all 0.2s ease",

                      "&:hover": {
                        background: active
                          ? "linear-gradient(90deg,#1e40af,#2563eb)"
                          : "rgba(255,255,255,0.06)",
                      },

                      ...(active && {
                        boxShadow: "0 6px 18px rgba(30,64,175,0.45)",
                      }),
                    }}
                  >
                    {/* GOLD ACCENT BAR */}

                    {active && (
                      <Box
                        sx={{
                          position: "absolute",
                          left: 0,
                          top: 6,
                          bottom: 6,
                          width: 3,
                          borderRadius: 4,
                          bgcolor: "#d4af37",
                        }}
                      />
                    )}

                    <ListItemIcon
                      sx={{
                        minWidth: collapsed ? 0 : 36,
                        color: "inherit",
                        justifyContent: "center",
                      }}
                    >
                      <Icon fontSize="small" />
                    </ListItemIcon>

                    {!collapsed && (
                      <ListItemText
                        primary={item.title}
                        primaryTypographyProps={{
                          fontSize: "0.92rem",
                          fontWeight: active ? 700 : 500,
                        }}
                      />
                    )}
                  </ListItemButton>
                )

                return (
                  <ListItem key={item.title} disablePadding sx={{ mb: 0.6 }}>
                    {collapsed ? (
                      <Tooltip title={item.title} placement="right">
                        {button}
                      </Tooltip>
                    ) : (
                      button
                    )}
                  </ListItem>
                )
              })}
            </React.Fragment>
          )
        })}
      </List>

      <Divider sx={{ opacity: 0.15, borderColor: "#d4af37" }} />

      {/* FOOTER STATUS PANEL */}

      {!collapsed && (
        <Box
          sx={{
            px: 2,
            py: 1.5,
            borderTop: "1px solid rgba(255,255,255,0.06)",
            background: "rgba(255,255,255,0.02)",
          }}
        >
          <Typography
            variant="caption"
            sx={{
              color: "rgba(230,236,255,0.55)",
              letterSpacing: "0.08em",
            }}
          >
            SYSTEM STATUS
          </Typography>

          <Typography
            variant="body2"
            sx={{
              fontWeight: 700,
              color: "#4ade80",
              mt: 0.2,
            }}
          >
            ALL MODULES OPERATIONAL
          </Typography>

          <Typography
            variant="caption"
            sx={{ color: "rgba(230,236,255,0.5)" }}
          >
            VMS v1.0 • INS RAJALI
          </Typography>
        </Box>
      )}
    </Box>
  )
}
