import React, { useState, useRef, useEffect } from "react"
import {
  Box,
  Paper,
  Typography,
  TextField,
  Button,
  Stack,
  Chip,
  CircularProgress,
  Divider,
  Alert
} from "@mui/material"

import Grid from "@mui/material/Grid"
import MenuItem from "@mui/material/MenuItem"

import CameraAltIcon from "@mui/icons-material/CameraAlt"
import BadgeIcon from "@mui/icons-material/Badge"
import BusinessIcon from "@mui/icons-material/Business"
import PersonIcon from "@mui/icons-material/Person"

import api from "../api/axios"

export default function ManualGateEntry() {

  /* ---------------- STATE ---------------- */

  const [searchValue,setSearchValue] = useState("")
  const [person,setPerson] = useState(null)

  const [loading,setLoading] = useState(false)
  const [cameraReady,setCameraReady] = useState(false)

  const [capturedPhoto,setCapturedPhoto] = useState(null)

  const [message,setMessage] = useState("")
  const [error,setError] = useState("")
  const [gateId,setGateId] = useState("")
  const [gates,setGates] = useState([])
  const [gatesLoading,setGatesLoading] = useState(false)

  const videoRef = useRef(null)
  const canvasRef = useRef(null)
  const inputRef = useRef(null)

  /* ---------------- CAMERA INIT ---------------- */

  useEffect(()=>{
    startCamera()
    inputRef.current?.focus()
  },[])

  const startCamera = async ()=>{
    try{

      const stream = await navigator.mediaDevices.getUserMedia({
        video:{ width:{ideal:1280}, height:{ideal:720} }
      })

      videoRef.current.srcObject = stream
      setCameraReady(true)

    }
    catch(err){
      console.error(err)
      setCameraReady(false)
      setError("Camera access denied")
    }
  }

  /* ---------------- GATES ---------------- */
  useEffect(() => {
    const fetchGates = async () => {
      setGatesLoading(true)
      try {
        const res = await api.get("/admin/gates")
        setGates(res.data?.gates || [])
        if (res.data?.gates?.length) setGateId(res.data.gates[0].id)
      } catch (err) {
        console.error("Failed to load gates", err)
      } finally {
        setGatesLoading(false)
      }
    }
    fetchGates()
  }, [])

  /* ---------------- PHOTO CAPTURE ---------------- */

  const capturePhoto = ()=>{

    if(!videoRef.current || !canvasRef.current) return

    const canvas = canvasRef.current
    const ctx = canvas.getContext("2d")

    canvas.width = 640
    canvas.height = 480

    ctx.drawImage(videoRef.current,0,0,640,480)

    const photo = canvas.toDataURL("image/jpeg",0.7)

    setCapturedPhoto(photo)
  }

  /* ---------------- SEARCH ---------------- */

  const searchPerson = async ()=>{

    if(!searchValue.trim()) return

    setLoading(true)
    setError("")
    setMessage("")
    setPerson(null)

    try{

      const res = await api.get(`/gate/search?query=${searchValue}`)

      setPerson(res.data)

    }
    catch(err){

      setError("Person not found")

    }
    finally{
      setLoading(false)
    }
  }

  /* ---------------- SUBMIT ---------------- */

  const submitManualEntry = async ()=>{

    if(!person){
      setError("Search person first")
      return
    }

    if(!capturedPhoto){
      setError("Capture photo required")
      return
    }

    if(!gateId){
      setError("Select a gate")
      return
    }

    setLoading(true)

    try{

      const res = await api.post("/gate/manual-entry",{
        person_id: person.id,
        person_type: person.person_type,
        gate_id: gateId,
        photo: capturedPhoto
      })

      setMessage(res.data.message || "Gate transaction recorded")

      resetUI()

    }
    catch(err){
      setError(err.response?.data?.error || "Gate transaction failed")
    }
    finally{
      setLoading(false)
    }
  }

  /* ---------------- RESET ---------------- */

  const resetUI = ()=>{
    setSearchValue("")
    setPerson(null)
    setCapturedPhoto(null)

    setTimeout(()=>{
      setMessage("")
      setError("")
      inputRef.current?.focus()
    },4000)
  }

  /* ---------------- UI ---------------- */

  return (

    <Box sx={{p:3}}>

      {/* HEADER */}

      <Typography
        variant="h4"
        fontWeight={800}
        sx={{mb:3}}
      >
        Manual Gate Control
      </Typography>


      <Grid container spacing={3}>

      {/* SEARCH PANEL */}

      <Grid size={{xs:12,md:4}}>

        <Paper sx={{p:3}}>

          <Typography variant="h6" gutterBottom>
            Search Person
          </Typography>

          <Stack spacing={2}>

            <TextField
              inputRef={inputRef}
              label="Pass / Phone / Aadhaar / Name"
              value={searchValue}
              onChange={(e)=>setSearchValue(e.target.value)}
              onKeyDown={(e)=>e.key==="Enter" && searchPerson()}
              fullWidth
            />

            <Button
              variant="contained"
              onClick={searchPerson}
              disabled={loading}
            >
              {loading ? <CircularProgress size={20}/> : "Search"}
            </Button>

          </Stack>

          {person && (

            <>
            <Divider sx={{my:2}}/>

            <Stack spacing={1}>

              <Stack direction="row" spacing={1} alignItems="center">
                <PersonIcon fontSize="small"/>
                <Typography fontWeight={700}>
                  {person.full_name}
                </Typography>
              </Stack>

              <Stack direction="row" spacing={1} alignItems="center">
                <BadgeIcon fontSize="small"/>
                <Typography>
                  Pass : {person.pass_no || "-"}
                </Typography>
              </Stack>

              <Stack direction="row" spacing={1} alignItems="center">
                <BusinessIcon fontSize="small"/>
                <Typography>
                  Company : {person.company_name || "-"}
                </Typography>
              </Stack>

              <Chip
                label={person.person_type}
                color="info"
                sx={{width:"fit-content", mt:1}}
              />

            </Stack>

            </>
          )}

        </Paper>

      </Grid>


      {/* CAMERA PANEL */}

      <Grid size={{xs:12,md:4}}>

        <Paper sx={{p:3}}>

          <Typography variant="h6">
            Camera Capture
          </Typography>

          <video
            ref={videoRef}
            autoPlay
            playsInline
            style={{
              width:"100%",
              borderRadius:10,
              marginTop:12
            }}
          />

          <Stack spacing={2} mt={2}>

            <Button
              startIcon={<CameraAltIcon/>}
              variant="contained"
              onClick={capturePhoto}
            >
              Capture Photo
            </Button>

            <Chip
              label={cameraReady ? "Camera Ready" : "Camera Offline"}
              color={cameraReady ? "success":"error"}
            />

          </Stack>

          {capturedPhoto && (

            <Box
              component="img"
              src={capturedPhoto}
              sx={{
                width:"100%",
                borderRadius:2,
                mt:2
              }}
            />

          )}

        </Paper>

      </Grid>


      {/* ACTION PANEL */}

      <Grid size={{xs:12,md:4}}>

        <Paper sx={{p:3}}>

          <Typography variant="h6">
            Gate Action
          </Typography>

          <Stack spacing={3} mt={2}>

            <TextField
              select
              label="Select Gate"
              value={gateId}
              onChange={(e)=>setGateId(e.target.value)}
              fullWidth
              disabled={gatesLoading}
            >
              {gates.map((g)=> (
                <MenuItem key={g.id} value={g.id}>
                  {g.gate_name || `Gate ${g.id}`}
                </MenuItem>
              ))}
            </TextField>

            <Button
              variant="contained"
              color="success"
              onClick={submitManualEntry}
              disabled={loading}
            >
              {loading ? <CircularProgress size={20}/> : "Submit Gate Transaction"}
            </Button>

          </Stack>

        </Paper>

      </Grid>

      </Grid>


      {/* ALERTS */}

      <Box sx={{mt:3}}>

        {error && (
          <Alert severity="error">{error}</Alert>
        )}

        {message && (
          <Alert severity="success">{message}</Alert>
        )}

      </Box>


      <canvas ref={canvasRef} style={{display:"none"}}/>

    </Box>
  )
}
