// Layout.jsx
import React, { useState, useRef, useEffect } from 'react';
import { Outlet } from 'react-router-dom';
import Header from './Header';
import Sidebar from './Sidebar';
import Box from '@mui/material/Box';
import api from '../../api/axios';
import useAuthStore from '../../store/auth.store';

export default function Layout() {
  const [sidebarOpen, setSidebarOpen] = useState(true);
  const [hideHeader, setHideHeader] = useState(false);
  const [elevateHeader, setElevateHeader] = useState(false);
  const token = useAuthStore((s) => s.token);
  const setUser = useAuthStore((s) => s.setUser);

  const lastScrollTop = useRef(0);
  const contentRef = useRef(null);

  const toggleSidebar = () => setSidebarOpen((prev) => !prev);

  // Scroll detection
  useEffect(() => {
    const el = contentRef.current;
    if (!el) return;

    const handleScroll = () => {
      const currentScroll = el.scrollTop;

      if (currentScroll > lastScrollTop.current && currentScroll > 80) {
        setHideHeader(true);
      } else {
        setHideHeader(false);
      }

      setElevateHeader(currentScroll > 10);
      lastScrollTop.current = currentScroll <= 0 ? 0 : currentScroll;
    };

    el.addEventListener('scroll', handleScroll);
    return () => el.removeEventListener('scroll', handleScroll);
  }, []);

  useEffect(() => {
    let mounted = true;
    const loadProfile = async () => {
      if (!token) return;
      try {
        const res = await api.get('/auth/me');
        if (mounted && res?.data?.user) {
          setUser(res.data.user);
        }
      } catch (err) {
        // Interceptor handles auth failures; keep layout silent.
      }
    };
    loadProfile();
    return () => {
      mounted = false;
    };
  }, [token, setUser]);

  return (
    <Box
      sx={{
        height: '100vh',
        display: 'flex',
        flexDirection: 'column',
        background:
          'linear-gradient(180deg, #081a33 0%, #0f2a5a 18%, #eef2f7 60%, #ffffff 100%)',
      }}
    >


      {/* --- HEADER --- */}
      <Box
        sx={{
          position: 'sticky',
          top: 0,
          zIndex: 1300,
          transform: hideHeader ? 'translateY(-100%)' : 'translateY(0)',
          transition: 'transform 0.35s ease, box-shadow 0.3s ease',
          boxShadow: elevateHeader
            ? '0 6px 22px rgba(0,0,0,0.28)'
            : '0 0 0 rgba(0,0,0,0)',
        }}
      >
        <Header onMenuClick={toggleSidebar} />
      </Box>

      {/* --- MAIN BODY --- */}
      <Box sx={{ flex: 1, display: 'flex', overflow: 'hidden' }}>
        {/* --- SIDEBAR --- */}
        <Box
          component="nav"
          sx={{
            width: sidebarOpen ? 280 : 88,
            transition: 'all 0.28s ease',
            flexShrink: 0,
            borderRight: '1px solid rgba(15,42,90,0.35)',
            background:
              'linear-gradient(180deg, #0f2a5a 0%, #081a33 100%)',
            color: '#e6ecff',
            boxShadow: '4px 0 22px rgba(0,0,0,0.25)',
            overflowX: 'hidden',
            display: 'flex',
            flexDirection: 'column',
            position: 'relative',
          }}
        >
          {/* subtle vertical divider glow */}
          <Box
            sx={{
              position: 'absolute',
              top: 0,
              right: 0,
              width: 2,
              height: '100%',
              background:
                'linear-gradient(180deg, rgba(59,130,246,0.0), rgba(59,130,246,0.4), rgba(59,130,246,0.0))',
              opacity: 0.5,
            }}
          />
          <Sidebar collapsed={!sidebarOpen} />
        </Box>

        {/* --- CONTENT AREA --- */}
        <Box
          ref={contentRef}
          component="main"
          sx={{
            flex: 1,
            overflowY: 'auto',
            px: { xs: 1, md: 2, lg: 3 },
            py: 4,
            background:
              'radial-gradient(circle at top, rgba(15,42,90,0.06), transparent 45%)',
          }}
        >
          {/* --- COMMAND SURFACE --- */}
          <Box
            sx={{
              minHeight: '100%',
              maxWidth: 1650,
              mx: 'auto',
              borderRadius: 3,
              background: '#ffffff',
              boxShadow: '0 22px 60px rgba(8,26,51,0.18)',
              border: '1px solid rgba(15,42,90,0.18)',
              position: 'relative',
              overflow: 'hidden',
              p: { xs: 2.5, md: 3.5, lg: 4 },
            }}
          >
            {/* Subtle command grid overlay */}
            <Box
              sx={{
                position: 'absolute',
                inset: 0,
                pointerEvents: 'none',
                opacity: 0.035,
                backgroundImage:
                  'linear-gradient(rgba(15,42,90,0.3) 1px, transparent 1px), linear-gradient(90deg, rgba(15,42,90,0.3) 1px, transparent 1px)',
                backgroundSize: '60px 60px',
              }}
            />

            {/* Page Content */}
            <Box sx={{ position: 'relative', zIndex: 1 }}>
              <Outlet />
            </Box>
          </Box>
        </Box>
      </Box>
    </Box>
  );
}
