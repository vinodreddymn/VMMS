import { capturePhoto } from './camera.js';

const validRfids = ['RFID12345', 'RFID67890', 'RFID55555'];
const invalidRfids = ['BAD11111', 'BAD22222', 'BAD33333'];

const randomChoice = (arr) => arr[Math.floor(Math.random() * arr.length)];

export const simulateScan = async (gateConfig) => {
  const isValid = Math.random() > 0.4;
  const rfid_uid = isValid ? randomChoice(validRfids) : randomChoice(invalidRfids);
  const live_photo = await capturePhoto(gateConfig.gate_id);
  return {
    rfid_uid,
    gate_id: gateConfig.gate_id,
    gate_name: gateConfig.gate_name,
    scan_time: new Date().toISOString(),
    live_photo,
  };
};

export const startScanLoop = (gateConfig, handler) => {
  const tick = async () => {
    const payload = await simulateScan(gateConfig);
    await handler(payload);
  };
  tick();
  return setInterval(tick, 10_000);
};
