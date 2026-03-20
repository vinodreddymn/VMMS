import express from 'express';
import http from 'http';
import { WebSocketServer } from 'ws';
import syncRoutes from './routes/sync.routes.js';
import scanRoutesFactory from './routes/scan.routes.js';
import { log } from './utils/logger.js';
import path from 'path';
import { fileURLToPath } from 'url';

const app = express();
app.use(express.json());

// Basic CORS for local simulation
app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept');
  next();
});

app.use('/api/sync', syncRoutes);

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
app.use('/photos', express.static(path.join(__dirname, 'static/photos')));
app.use('/captures', express.static(path.join(__dirname, 'static/captures')));

const server = http.createServer(app);

const wss = new WebSocketServer({ server, path: '/display' });
const displayClients = new Set();

wss.on('connection', (ws) => {
  displayClients.add(ws);
  ws.on('close', () => displayClients.delete(ws));
});

const broadcastToDisplays = (payload) => {
  const data = JSON.stringify(payload);
  for (const client of displayClients) {
    if (client.readyState === 1) {
      client.send(data);
    }
  }
};

app.use('/api/gate', scanRoutesFactory(broadcastToDisplays));

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => log(`Backend listening on http://127.0.0.1:${PORT}`));
