import React, { useState, useRef, useEffect } from "react"
import { Outlet } from "react-router-dom"
import Header from "./Header"
import Sidebar from "./Sidebar"
import Box from "@mui/material/Box"
import api from "../../api/axios"
import useAuthStore from "../../store/auth.store"

export default function Layout() {

const [sidebarOpen, setSidebarOpen] = useState(true)
const [hideHeader, setHideHeader] = useState(false)
const [elevateHeader, setElevateHeader] = useState(false)

const token = useAuthStore((s) => s.token)
const setUser = useAuthStore((s) => s.setUser)

const scrollRef = useRef(null)
const lastScrollTop = useRef(0)

const toggleSidebar = () => setSidebarOpen(prev => !prev)

/* ================= SCROLL DETECTION ================= */

useEffect(() => {

const el = scrollRef.current
if (!el) return

const handleScroll = () => {

  const currentScroll = el.scrollTop

  if (currentScroll > lastScrollTop.current && currentScroll > 70)
    setHideHeader(true)
  else
    setHideHeader(false)

  setElevateHeader(currentScroll > 8)

  lastScrollTop.current = currentScroll <= 0 ? 0 : currentScroll
}

el.addEventListener("scroll", handleScroll)

return () => el.removeEventListener("scroll", handleScroll)


}, [])

/* ================= LOAD PROFILE ================= */

useEffect(() => {


let mounted = true

const loadProfile = async () => {

  if (!token) return

  try {

    const res = await api.get("/auth/me")

    if (mounted && res?.data?.user)
      setUser(res.data.user)

  } catch {}

}

loadProfile()

return () => { mounted = false }


}, [token, setUser])

/* ================= LAYOUT ================= */

return (
  <Box
    sx={{
      height: "100vh",
      width: "100%",
      overflow: "clip",
      display: "flex",
      flexDirection: "column",
      background:
        "linear-gradient(180deg,#081a33 0%,#0f2a5a 18%,#eef2f7 60%,#ffffff 100%)",
    }}
  >
    {/* ================= HEADER ================= */}

    <Box
      sx={{
        position: "sticky",
        top: 0,
        zIndex: 1300,
        flexShrink: 0,
        transform: hideHeader ? "translateY(-100%)" : "translateY(0)",
        transition: "transform .35s ease, box-shadow .25s ease",
        boxShadow: elevateHeader
          ? "0 8px 26px rgba(0,0,0,0.28)"
          : "none",
      }}
    >
      <Header onMenuClick={toggleSidebar} />
    </Box>

    {/* ================= MAIN BODY ================= */}

    <Box
      sx={{
        flex: 1,
        display: "flex",
        overflow: "hidden",
        minHeight: 0,
        minWidth: 0,
      }}
    >
      {/* ================= SIDEBAR ================= */}

      <Box
        component="nav"
        sx={{
          width: sidebarOpen ? 270 : 84,
          transition: "width .28s cubic-bezier(.4,0,.2,1)",
          flexShrink: 0,
          overflow: "hidden",
          background:
            "linear-gradient(180deg,#0f2a5a 0%,#081a33 100%)",
          borderRight: "1px solid rgba(15,42,90,.35)",
          boxShadow: "4px 0 24px rgba(0,0,0,0.25)",
          display: "flex",
          flexDirection: "column",
        }}
      >
        <Sidebar collapsed={!sidebarOpen} />
      </Box>

      {/* ================= WORKSPACE ================= */}

      <Box
        sx={{
          flex: 1,
          display: "flex",
          overflow: "hidden",
          minHeight: 0,
          minWidth: 0,
        }}
      >
        {/* ================= SCROLL AREA ================= */}

        <Box
          ref={scrollRef}
          sx={{
            flex: 1,
            minHeight: 0,
            minWidth: 0,
            overflowY: "auto",
            overflowX: "hidden",
            scrollbarGutter: "stable",
          }}
        >
          {/* ================= PAGE CONTAINER ================= */}

          <Box
            sx={{
              width: "100%",
              my: 2,
              borderRadius: 3,
              background: "#ffffff",
              border: "1px solid rgba(15,42,90,.18)",
              boxShadow: "0 25px 70px rgba(8,26,51,.18)",
              p: { xs: 2, md: 3, lg: 4 },
              position: "relative",
              overflow: "clip",
            }}
          >
            {/* subtle grid overlay */}

            <Box
              sx={{
                position: "absolute",
                inset: 0,
                opacity: 0.03,
                pointerEvents: "none",
                backgroundImage:
                  "linear-gradient(rgba(15,42,90,.3) 1px, transparent 1px), linear-gradient(90deg, rgba(15,42,90,.3) 1px, transparent 1px)",
                backgroundSize: "60px 60px",
              }}
            />

            {/* actual page */}

            <Box sx={{ position: "relative", zIndex: 1 }}>
              <Outlet />
            </Box>
          </Box>
        </Box>
      </Box>
    </Box>
  </Box>
)
}
