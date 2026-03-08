import { fetchMasters } from '../services/master.service.js';

export const getMasters = async (req, res) => {
  try {
    const data = await fetchMasters();
    res.json({ success: true, data });
  } catch (err) {
    console.error('Error fetching masters:', err);
    res.status(500).json({ success: false, message: 'Failed to fetch master data' });
  }
};