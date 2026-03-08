import React, { useState } from 'react'
import {
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Paper,
  Button,
  Box,
  Typography,
  Chip,
  IconButton,
  Tooltip,
  TablePagination,
  CircularProgress
} from '@mui/material'
import EditIcon from '@mui/icons-material/Edit'
import DeleteIcon from '@mui/icons-material/Delete'
import MoreVertIcon from '@mui/icons-material/MoreVert'

// columns: [{ key, label, render?: (value, row) => node, align?: 'left'|'center'|'right', width?: string }]
// actions: [{ label, icon?: Icon, onClick: (row) => {}, hidden?: (row) => boolean, disabled?: (row) => boolean, color?: string }]
export default function DataTable({
  columns = [],
  data = [],
  actions = [],
  pagination = false,
  rowsPerPageOptions = [5, 10, 25, 50],
  loading = false,
  emptyMessage = 'No data available',
  striped = true,
  maxHeight = null,
  stickyHeader = true
}) {
  const [page, setPage] = useState(0)
  const [rowsPerPage, setRowsPerPage] = useState(rowsPerPageOptions[0] || 10)

  const handleChangePage = (event, newPage) => setPage(newPage)
  const handleChangeRowsPerPage = (event) => {
    setRowsPerPage(parseInt(event.target.value, 10))
    setPage(0)
  }

  const displayData = pagination
    ? data.slice(page * rowsPerPage, page * rowsPerPage + rowsPerPage)
    : data

  if (loading) {
    return (
      <Box sx={{ display: 'flex', justifyContent: 'center', alignItems: 'center', minHeight: 300 }}>
        <CircularProgress />
      </Box>
    )
  }

  if (data.length === 0) {
    return (
      <Paper elevation={0} sx={{ border: '1px solid #eee', p: 4, textAlign: 'center' }}>
        <Typography color="text.secondary">{emptyMessage}</Typography>
      </Paper>
    )
  }

  return (
    <Box>
      <TableContainer
        component={Paper}
        elevation={0}
        sx={{
          border: '1px solid #eee',
          borderRadius: 1,
          maxHeight: maxHeight,
          '&::-webkit-scrollbar': {
            width: '8px',
            height: '8px'
          },
          '&::-webkit-scrollbar-track': {
            background: '#f1f1f1'
          },
          '&::-webkit-scrollbar-thumb': {
            background: '#888',
            borderRadius: '4px',
            '&:hover': {
              background: '#555'
            }
          }
        }}
      >
        <Table stickyHeader={stickyHeader} size="small">
          <TableHead>
            <TableRow sx={{ backgroundColor: '#f8f9fa' }}>
              {columns.map((col) => (
                <TableCell
                  key={col.key}
                  align={col.align || 'left'}
                  sx={{
                    width: col.width,
                    fontWeight: 700,
                    fontSize: '0.9rem',
                    color: '#333',
                    backgroundColor: '#f8f9fa',
                    borderBottom: '2px solid #e0e0e0',
                    textTransform: 'uppercase',
                    letterSpacing: '0.5px'
                  }}
                >
                  {col.label}
                </TableCell>
              ))}
              {actions.length > 0 && (
                <TableCell
                  align="center"
                  sx={{
                    fontWeight: 700,
                    fontSize: '0.9rem',
                    color: '#333',
                    backgroundColor: '#f8f9fa',
                    borderBottom: '2px solid #e0e0e0',
                    textTransform: 'uppercase',
                    letterSpacing: '0.5px'
                  }}
                >
                  Actions
                </TableCell>
              )}
            </TableRow>
          </TableHead>

          <TableBody>
            {displayData.map((row, idx) => (
              <TableRow
                key={row.id ?? row.visitor_id ?? row.labour_id ?? idx}
                hover
                sx={{
                  backgroundColor: striped && idx % 2 === 0 ? '#fafbfc' : '#fff',
                  '&:hover': {
                    backgroundColor: '#f0f4f8',
                    transition: 'background-color 0.2s ease'
                  },
                  borderBottom: '1px solid #f0f0f0'
                }}
              >
                {columns.map((col) => (
                  <TableCell
                    key={col.key}
                    align={col.align || 'left'}
                    sx={{
                      fontSize: '0.9rem',
                      color: '#555',
                      py: 1.5
                    }}
                  >
                    {col.render
                      ? col.render(row[col.key], row)
                      : row[col.key] !== undefined && row[col.key] !== null
                      ? String(row[col.key])
                      : '-'}
                  </TableCell>
                ))}
                {actions.length > 0 && (
                  <TableCell align="center" sx={{ py: 1.5 }}>
                    <Box sx={{ display: 'flex', gap: 0.5, justifyContent: 'center' }}>
                      {actions
                        .filter((a) => !(typeof a.hidden === 'function' && a.hidden(row)))
                        .map((a, i) => {
                          const isDisabled =
                            typeof a.disabled === 'function' ? a.disabled(row) : false

                          const buttonProps = {
                            onClick: () => a.onClick(row),
                            disabled: isDisabled,
                            size: 'small',
                            variant: 'text',
                            color: a.color || 'primary',
                            sx: {
                              textTransform: 'none',
                              fontSize: '0.8rem',
                              fontWeight: 500,
                              '&:hover': {
                                backgroundColor:
                                  a.color === 'error'
                                    ? 'rgba(211, 47, 47, 0.08)'
                                    : a.color === 'success'
                                    ? 'rgba(56, 142, 60, 0.08)'
                                    : a.color === 'warning'
                                    ? 'rgba(245, 127, 23, 0.08)'
                                    : 'rgba(25, 103, 210, 0.08)'
                              }
                            }
                          }

                          if (a.icon) {
                            return (
                              <Tooltip key={i} title={a.label}>
                                <IconButton
                                  {...buttonProps}
                                  sx={{
                                    ...buttonProps.sx,
                                    p: 0.5
                                  }}
                                >
                                  <a.icon sx={{ fontSize: '1.1rem' }} />
                                </IconButton>
                              </Tooltip>
                            )
                          }

                          return <Button {...buttonProps}>{a.label}</Button>
                        })}
                    </Box>
                  </TableCell>
                )}
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </TableContainer>

      {pagination && data.length > rowsPerPageOptions[0] && (
        <TablePagination
          rowsPerPageOptions={rowsPerPageOptions}
          component={Box}
          count={data.length}
          rowsPerPage={rowsPerPage}
          page={page}
          onPageChange={handleChangePage}
          onRowsPerPageChange={handleChangeRowsPerPage}
          sx={{
            borderTop: '1px solid #eee',
            backgroundColor: '#f8f9fa',
            '& .MuiTablePagination-toolbar': {
              minHeight: 'auto'
            }
          }}
        />
      )}
    </Box>
  )
}

