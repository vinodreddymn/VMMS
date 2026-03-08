import React from 'react'
import Stack from '@mui/material/Stack'
import Button from '@mui/material/Button'

export default function Pagination({ page, totalPages, onChange }) {
  return (
    <Stack direction="row" spacing={1} alignItems="center">
      <Button size="small" disabled={page <= 1} onClick={() => onChange(page - 1)}>
        Prev
      </Button>
      <div>
        Page {page} / {totalPages}
      </div>
      <Button size="small" disabled={page >= totalPages} onClick={() => onChange(page + 1)}>
        Next
      </Button>
    </Stack>
  )
}
