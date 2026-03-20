import express from 'express';
import { handleScan } from '../controllers/scan.controller.js';

const router = express.Router();

export default (broadcaster) => {
  router.post('/scan', (req, res) => handleScan(req, res, broadcaster));
  return router;
};
