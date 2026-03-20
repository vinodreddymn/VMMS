import { memory, insertAccessLog } from '../database/db.js';
import { log } from '../utils/logger.js';

const findVisitorByRfid = (rfid) => memory.whitelist.find((v) => v.rfid_uid === rfid);

export const handleScan = async (req, res, broadcaster) => {
  const scan = req.body;
  const visitor = findVisitorByRfid(scan.rfid_uid);
  const status = visitor ? 'ACCESS GRANTED' : 'ACCESS DENIED';
  const payload = {
    gate_id: scan.gate_id,
    gate_name: scan.gate_name,
    rfid_uid: scan.rfid_uid,
    scan_time: scan.scan_time || new Date().toISOString(),
    visitor_name: visitor?.visitor_name || 'Unknown',
    visitor_id: visitor?.visitor_id || 'N/A',
    company: visitor?.company || 'N/A',
    registered_photo: visitor?.registered_photo || null,
    live_photo: scan.live_photo,
    status,
  };
  await insertAccessLog(payload);
  broadcaster(payload);
  log('Scan processed', payload);
  res.json(payload);
};
