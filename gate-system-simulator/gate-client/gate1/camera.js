import path from 'path';

export const capturePhoto = async (gateId) => {
  const filename = `live_${gateId}_${Date.now()}.jpg`;
  // Return a pseudo path to mimic capture location
  return path.join('/captures', `gate${gateId}`, filename);
};
