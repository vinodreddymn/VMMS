import React from 'react'
import {
  Box,
  Chip,
  CircularProgress,
  Paper,
  Stack,
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableRow,
  TextField,
  Typography,
} from '@mui/material'

export default function VisitorHistoryTab({
  historyFrom,
  historyTo,
  setHistoryFrom,
  setHistoryTo,
  visitorStatus,
  visitorHistory,
  loading,
  formatDateTime,
}) {
  const byDay = groupByDate(visitorHistory)

  return (
    <Box>
      <Stack direction="row" spacing={2} alignItems="center" flexWrap="wrap" mb={2}>
        <TextField
          label="From"
          type="date"
          size="small"
          value={historyFrom}
          onChange={(e)=>setHistoryFrom(e.target.value)}
          InputLabelProps={{ shrink: true }}
        />
        <TextField
          label="To"
          type="date"
          size="small"
          value={historyTo}
          onChange={(e)=>setHistoryTo(e.target.value)}
          InputLabelProps={{ shrink: true }}
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
          {byDay.map(({ dateLabel, entries }, idx) => (
            <Paper key={idx} variant="outlined" sx={{ p:1.5, borderRadius:2 }}>
              <Typography variant="subtitle2" sx={{ mb:1, fontWeight:700 }}>{dateLabel}</Typography>
              <Table size="small">
                <TableHead>
                  <TableRow>
                    {["Scan Time","Direction","Status","Gate","Project","Department"].map((c,i)=><TableCell key={i}><b>{c}</b></TableCell>)}
                  </TableRow>
                </TableHead>
                <TableBody>
                  {entries.map((log,j)=>(
                    <TableRow key={j}>
                      <TableCell>{formatDateTime(log.scan_time)}</TableCell>
                      <TableCell>{log.direction || '-'}</TableCell>
                      <TableCell>
                        <Chip size="small" label={log.status || '-'} color={log.status === 'FAILED' ? 'error' : 'primary'} />
                      </TableCell>
                      <TableCell>{log.gate_name || '-'}</TableCell>
                      <TableCell>{log.project_name || '-'}</TableCell>
                      <TableCell>{log.department_name || '-'}</TableCell>
                    </TableRow>
                  ))}
                  {entries.length === 0 && (
                    <TableRow><TableCell colSpan={6} align="center">No data</TableCell></TableRow>
                  )}
                </TableBody>
              </Table>
            </Paper>
          ))}
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
      dateLabel: new Date(key).toLocaleDateString(),
      entries
    }))
}

function aggregateInOut(entries = []) {
  const res = { in: null, out: null, inGate: '-', outGate: '-' }
  entries.forEach((r)=>{
    if (r.direction === 'IN' && r.status !== 'FAILED' && !res.in) {
      res.in = r.scan_time
      res.inGate = r.gate_name || '-'
    }
    if (r.direction === 'OUT' && r.status !== 'FAILED' && !res.out) {
      res.out = r.scan_time
      res.outGate = r.gate_name || '-'
    }
  })
  return res
}
