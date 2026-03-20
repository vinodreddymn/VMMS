import express from 'express';
import { getWhitelist, acceptOfflineLogs } from '../controllers/sync.controller.js';

const router = express.Router();

router.get('/whitelist', getWhitelist);
router.post('/offline', acceptOfflineLogs);

export default router;
