import path from 'path';

export const capturePhoto = async (gateId) => {
  const filename = `live_${gateId}_${Date.now()}.jpg`;
  return path.join('/captures', `gate${gateId}`, filename);
};
