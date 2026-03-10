import React from 'react'
import {
  Box,
  Chip,
  CircularProgress,
  Paper,
  Stack,
  Table,
  TableHead,
  TableRow,
  TableCell,
  TableBody,
  TextField,
  Typography,
} from '@mui/material'

export default function LabourHistoryTab({
  labourHistoryFrom,
  labourHistoryTo,
  setLabourHistoryFrom,
  setLabourHistoryTo,
  labourHistory,
  loading,
  formatDateTime,
  manifests = [],
  fileBase = '',
}) {
  const byDay = groupByDate(labourHistory)

  const uniqueLaboursInRange = React.useMemo(() => {
    const ids = new Set()
    labourHistory?.forEach((r) => {
      const id = r.labour_id || r.person_id || r.id
      if (id) ids.add(id)
    })
    return ids.size
  }, [labourHistory])

  return (
    <Box>
      <Stack direction="row" spacing={2} alignItems="center" flexWrap="wrap" mb={2}>
        <TextField
          label="From"
          type="date"
          size="small"
          value={labourHistoryFrom}
          onChange={(e)=>setLabourHistoryFrom(e.target.value)}
          InputLabelProps={{ shrink: true }}
        />
        <TextField
          label="To"
          type="date"
          size="small"
          value={labourHistoryTo}
          onChange={(e)=>setLabourHistoryTo(e.target.value)}
          InputLabelProps={{ shrink: true }}
        />
        <Chip
          label={`Labours Registered: ${uniqueLaboursInRange}`}
          color="primary"
          variant="outlined"
        />
      </Stack>


      {loading ? (
        <Box display="flex" justifyContent="center" mt={3}>
          <CircularProgress size={24}/>
        </Box>
      ) : (
        <Stack spacing={2}>
          {byDay.length === 0 && (
            <Paper variant="outlined" sx={{ p:2, borderRadius:2 }}>
              <Typography align="center" color="text.secondary">No data</Typography>
            </Paper>
          )}
          {byDay.map(({ dateLabel, entries, key }, idx) => {
            const perLabour = summariseByLabour(entries)
            const manifestsForDate = manifests.filter(m => (m.manifest_date || '').startsWith(key))
            return (
              <Paper key={idx} variant="outlined" sx={{ p:1.5, borderRadius:2 }}>
                <Stack direction="row" alignItems="center" justifyContent="space-between" sx={{ mb:1 }}>
                  <Typography variant="subtitle2" sx={{ fontWeight:700 }}>{dateLabel}</Typography>
                  <Stack direction="row" spacing={1} flexWrap="wrap">
                    {manifestsForDate.map((mf)=>(
                      <Chip
                        key={mf.id}
                        label={`Manifest ${mf.manifest_number || mf.id}`}
                        onClick={()=> mf.pdf_path && window.open(`${fileBase}/${mf.pdf_path}`)}
                        variant="outlined"
                        color="primary"
                        clickable={!!mf.pdf_path}
                        sx={{ mb:0.5 }}
                      />
                    ))}
                  </Stack>
                </Stack>
                <Table size="small">
                  <TableHead>
                    <TableRow>
                      {["Labour","Aadhaar","Phone","IN Time","IN Gate","OUT Time","OUT Gate","Token"].map((c,i)=><TableCell key={i}><b>{c}</b></TableCell>)}
                    </TableRow>
                  </TableHead>
                  <TableBody>
                    {perLabour.length === 0 ? (
                      <TableRow><TableCell colSpan={8} align="center">No data</TableCell></TableRow>
                    ) : perLabour.map((row, j)=>(
                      <TableRow key={j}>
                        <TableCell>{row.labour}</TableCell>
                        <TableCell>{row.aadhaar}</TableCell>
                        <TableCell>{row.phone}</TableCell>
                        <TableCell>{row.in ? formatDateTime(row.in) : '-'}</TableCell>
                        <TableCell>{row.inGate}</TableCell>
                        <TableCell>{row.out ? formatDateTime(row.out) : '-'}</TableCell>
                        <TableCell>{row.outGate}</TableCell>
                        <TableCell>{row.token}</TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              </Paper>
            )
          })}
        </Stack>
      )}
    </Box>
  )
}

function groupByDate(rows = []) {
  const map = new Map()
  rows.forEach((r)=>{
    const dayKey = (r.scan_time ? new Date(r.scan_time) : new Date()).toISOString().split('T')[0]
    if (!map.has(dayKey)) map.set(dayKey, [])
    map.get(dayKey).push(r)
  })
  return Array.from(map.entries())
    .sort((a,b)=> (a[0] < b[0] ? 1 : -1))
    .map(([key, entries])=>({
      key,
      dateLabel: new Date(key).toLocaleDateString(),
      entries
    }))
}

function summariseByLabour(entries = []) {
  const perLabour = {}
  entries.forEach((r)=>{
    const id = r.labour_id || r.person_id || r.id || 'unknown'
    if (!perLabour[id]) {
      perLabour[id] = {
        labour: r.full_name || 'Unknown',
        aadhaar: r.aadhaar_last4 || r.aadhaar || '-',
        phone: r.phone || '-',
        in: null,
        out: null,
        inGate: '-',
        outGate: '-',
        token: r.token_uid || '-',
      }
    }
    if (r.direction === 'IN' && r.status !== 'FAILED' && !perLabour[id].in) {
      perLabour[id].in = r.scan_time
      perLabour[id].inGate = r.gate_name || '-'
    }
    if (r.direction === 'OUT' && r.status !== 'FAILED' && !perLabour[id].out) {
      perLabour[id].out = r.scan_time
      perLabour[id].outGate = r.gate_name || '-'
    }
    if (r.token_uid) perLabour[id].token = r.token_uid
  })

  return Object.values(perLabour).sort((a,b)=>a.labour.localeCompare(b.labour))
}
