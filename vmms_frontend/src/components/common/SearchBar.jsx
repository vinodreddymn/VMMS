import React from 'react'
import TextField from '@mui/material/TextField'

export default function SearchBar({ value, onChange, placeholder = 'Search' }) {
  return (
    <div style={{ marginBottom: 12 }}>
      <TextField
        size="small"
        variant="outlined"
        placeholder={placeholder}
        value={value}
        onChange={(e) => onChange(e.target.value)}
        style={{ width: 500 }}
      />
    </div>
  )
}
