import React from "react"
import { Routes, Route, Navigate } from "react-router-dom"

import Layout from "./components/layout/Layout"
import ProtectedRoute from "./routes/ProtectedRoute"
import useAuthStore from "./store/auth.store"

/* ================= CORE PAGES ================= */

import Login from "./pages/Login"
import Dashboard from "./pages/Dashboard"
import Analytics from "./pages/Analytics"
import Profile from "./pages/Profile"
import VisitorTransactions from "./pages/VisitorTransactions"
import LabourTransactions from "./pages/LabourTransactions"

/* ================= VISITORS MODULE ================= */

import VisitorsList from "./pages/VisitorsList"
import VisitorDetail from "./pages/VisitorsDetail"
import VisitorForm from "./pages/VisitorForm"
import VisitorWizard from "./pages/VisitorWizard"
import VisitorDocumentUpload from "./pages/VisitorDocumentUpload"
import VisitorPhotoUpload from "./pages/VisitorPhotoUpload"
import VisitorRFIDPage from "./pages/VisitorRFIDPage"
import VisitorBiometricPage from "./pages/VisitorBiometricPage"

/* ================= LABOUR MODULE ================= */

import Labour from "./pages/Labour"
import LabourDetail from "./pages/LabourDetail"
import LabourForm from "./pages/LabourForm"
import LabourManifest from "./pages/LabourManifest"
import ManifestView from "./pages/ManifestView"
import LabourTokenReturn from "./pages/LabourTokenReturn"

/* ================= MATERIALS ================= */

import Materials from "./pages/Materials"
import MaterialForm from "./pages/MaterialForm"

/* ================= GATE / DISPLAY MODULE ================= */

import Gate from "./pages/Gate"
import GateDisplay from "./pages/GateDisplay"
import AndonDisplay from "./pages/AndonDisplay/AndonDisplay"

import ManualGateEntry from "./pages/ManualGateEntry"
import TouchGate from "./pages/TouchGate"

/* ================= REPORTS ================= */

import Reports from "./pages/Reports"

/* ================= ADMIN / UTILITIES ================= */

import Blacklist from "./pages/Blacklist"
import Sync from "./pages/Sync"
import AdminUsers from "./pages/AdminUsers"

export default function App() {

  const user = useAuthStore((s) => s.user)

  const role = user?.role || user?.role_name || "USER"

  const isAdmin = role === "ADMIN" || role === "SUPER_ADMIN"
  const isSuperAdmin = role === "SUPER_ADMIN"

  return (
    <Routes>

      {/* ================================================= */}
      {/* PUBLIC ROUTES */}
      {/* ================================================= */}

      <Route path="/login" element={<Login />} />

      {/* Public Andon Display (TV / Monitoring Screen) */}
      <Route path="/andon" element={<AndonDisplay />} />

      {/* ================================================= */}
      {/* FULLSCREEN DISPLAY ROUTES (NO LAYOUT) */}
      {/* ================================================= */}

      <Route
        path="/gate/display"
        element={
          <ProtectedRoute>
            <GateDisplay />
          </ProtectedRoute>
        }
      />
      <Route path="/gate/touch" element={<TouchGate />} />

      {/* ================================================= */}
      {/* PROTECTED APP LAYOUT */}
      {/* ================================================= */}

      <Route
        path="/"
        element={
          <ProtectedRoute>
            <Layout />
          </ProtectedRoute>
        }
      >

        {/* ================= DASHBOARD ================= */}

        <Route index element={<Dashboard />} />
        <Route path="profile" element={<Profile />} />

        {/* ================= ANALYTICS ================= */}

        <Route path="analytics" element={<Analytics />} />
        <Route path="transactions/visitors" element={<VisitorTransactions />} />
        <Route path="transactions/labours" element={<LabourTransactions />} />

        {/* ================================================= */}
        {/* VISITORS MODULE */}
        {/* ================================================= */}

        <Route path="visitors">

          <Route index element={<VisitorsList />} />

          <Route path="register" element={<VisitorWizard />} />

          <Route path="new" element={<VisitorForm />} />

          <Route path=":id/edit" element={<VisitorForm />} />

          <Route path=":id" element={<VisitorDetail />} />

          <Route path=":id/upload-document" element={<VisitorDocumentUpload />} />

          <Route path=":id/photo" element={<VisitorPhotoUpload />} />

          <Route path=":id/rfid" element={<VisitorRFIDPage />} />

          <Route path=":id/biometric" element={<VisitorBiometricPage />} />

        </Route>

        {/* ================================================= */}
        {/* LABOUR MODULE */}
        {/* ================================================= */}

        <Route path="labour">

          <Route index element={<Labour />} />

          <Route path="new" element={<LabourForm />} />

          <Route path="manifest" element={<LabourManifest />} />

          <Route path="tokens/return" element={<LabourTokenReturn />} />

          <Route path=":id" element={<LabourDetail />} />

          <Route path=":id/edit" element={<LabourForm />} />

          <Route path="manifest/:id" element={<ManifestView />} />

        </Route>

        {/* ================================================= */}
        {/* MATERIALS MODULE */}
        {/* ================================================= */}

        <Route path="materials">

          <Route index element={<Materials />} />

          {isAdmin && (
            <>
              <Route path="new" element={<MaterialForm />} />
              <Route path=":id/edit" element={<MaterialForm />} />
            </>
          )}

        </Route>

        {/* ================================================= */}
        {/* GATE MANAGEMENT */}
        {/* ================================================= */}

        <Route path="gate" element={<Gate />} />
        <Route path="gate/manual" element={<ManualGateEntry />} />
        {/* ================================================= */}
        {/* REPORTS */}
        {/* ================================================= */}

        <Route path="reports" element={<Reports />} />


        {/* ================================================= */}
        {/* SUPER ADMIN MODULE */}
        {/* ================================================= */}

        {isSuperAdmin && (
          <>
            <Route path="blacklist" element={<Blacklist />} />

            <Route path="sync" element={<Sync />} />

            <Route path="admin/users" element={<AdminUsers />} />
          </>
        )}

      </Route>

      {/* ================================================= */}
      {/* FALLBACK ROUTE */}
      {/* ================================================= */}

      <Route path="*" element={<Navigate to="/" replace />} />

    </Routes>
  )
}
