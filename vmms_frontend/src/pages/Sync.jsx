import React, { useEffect, useState } from 'react'
import { getWhitelist, getUnsyncedQueue, submitSyncQueue } from '../api/sync.api'
import Button from '@mui/material/Button'

export default function Sync() {
  const [whitelist, setWhitelist] = useState(null)
  const [queue, setQueue] = useState([])
  const [loading, setLoading] = useState(false)

  function fetchWhitelist() {
    setLoading(true)
    getWhitelist({ last_sync: new Date().toISOString() })
      .then((res) => setWhitelist(res.data.data))
      .catch(() => {})
      .finally(() => setLoading(false))
  }

  function fetchQueue() {
    setLoading(true)
    getUnsyncedQueue({ gate_id: 1 })
      .then((res) => setQueue(res.data.data || []))
      .catch(() => {})
      .finally(() => setLoading(false))
  }

  useEffect(() => { fetchWhitelist(); fetchQueue() }, [])

  return (
    <div style={{ padding: 20 }}>
        <h2>Sync</h2>
        <div style={{ display: 'flex', gap: 12 }}>
          <Button onClick={fetchWhitelist}>Refresh Whitelist</Button>
          <Button onClick={fetchQueue}>Refresh Queue</Button>
          <Button onClick={() => submitSyncQueue({ gate_id: 1, sync_timestamp: new Date().toISOString(), access_logs: [] }).then(() => alert('Submitted')).catch(() => alert('Failed'))}>Submit Empty Queue</Button>
        </div>

        <section style={{ marginTop: 12 }}>
          <h3>Whitelist</h3>
          {!whitelist ? <p>Loading...</p> : <pre>{JSON.stringify(whitelist, null, 2)}</pre>}
        </section>

        <section style={{ marginTop: 12 }}>
          <h3>Unsynced Queue</h3>
          {queue.length === 0 ? <p>No items</p> : <pre>{JSON.stringify(queue, null, 2)}</pre>}
        </section>
    </div>
  )
}
