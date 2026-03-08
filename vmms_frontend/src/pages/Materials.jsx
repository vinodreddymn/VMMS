import React, { useEffect, useState } from 'react'
import DataTable from '../components/common/DataTable'
import { listMaterials, createMaterial } from '../api/material.api'
import Button from '@mui/material/Button'
import MaterialForm from './MaterialForm'

export default function Materials() {
  const [materials, setMaterials] = useState([])
  const [loading, setLoading] = useState(true)
  const [formOpen, setFormOpen] = useState(false)

  function fetch() {
    setLoading(true)
    listMaterials()
      .then((res) => setMaterials(res.data.data || []))
      .catch((err) => console.error(err))
      .finally(() => setLoading(false))
  }

  useEffect(() => { fetch() }, [])

  const columns = [
    { key: 'material_id', label: 'ID' },
    { key: 'category', label: 'Category' },
    { key: 'make', label: 'Make' },
    { key: 'model', label: 'Model' },
    { key: 'description', label: 'Description' },
  ]

  return (
    <div style={{ padding: 20 }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <h2>Materials</h2>
          <Button variant="contained" onClick={() => setFormOpen(true)}>New Material</Button>
        </div>

        {loading ? <p>Loading...</p> : <DataTable columns={columns} data={materials} />}

        <MaterialForm open={formOpen} onClose={() => setFormOpen(false)} onSaved={() => { setFormOpen(false); fetch() }} />
    </div>
  )
}
