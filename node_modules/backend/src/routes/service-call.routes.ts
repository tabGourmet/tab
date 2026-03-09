import { Router } from 'express';
import { ServiceCallController } from '../controllers/service-call.controller';
import { authenticateToken, requireActiveSubscription } from '../middleware/auth.middleware';

const router = Router();
const controller = new ServiceCallController();

// PATCH /api/v1/service-calls/:id/resolve (admin only)
router.patch('/:id/resolve', authenticateToken, requireActiveSubscription, controller.resolve);

export default router;
