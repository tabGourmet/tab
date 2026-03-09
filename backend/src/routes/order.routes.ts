import { Router } from 'express';
import { OrderController } from '../controllers/order.controller';
import { authenticateToken, requireActiveSubscription } from '../middleware/auth.middleware';

const router = Router();
const controller = new OrderController();

// GET /api/v1/orders/:id (public — consumers need to see their order)
router.get('/:id', controller.getById);

// Protected admin routes
router.use(authenticateToken);
router.use(requireActiveSubscription);

// PATCH /api/v1/orders/:id/status - Close order (admin only)
router.patch('/:id/status', controller.updateStatus);

// PATCH /api/v1/orders/items/:id/status - Update order item status (admin)
router.patch('/items/:id/status', controller.updateItemStatus);

export default router;
