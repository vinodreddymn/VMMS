import express from 'express';
import { getMasters } from '../controllers/master.controller.js';

const router = express.Router();

router.get('/', getMasters);

export default router;