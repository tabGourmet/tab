import { Router } from 'express';
import { SessionController } from '../controllers/session.controller';
import { authenticateToken, requireActiveSubscription } from '../middleware/auth.middleware';
import { validate } from '../middleware/validate';
import { startSessionSchema, addConsumerSchema, addOrderItemSchema, createServiceCallSchema } from '../schemas';

const router = Router();
const controller = new SessionController();

// PUBLIC routes (consumer-facing — require valid session token or are join actions)
// POST /api/v1/sessions/join - Join/Create session
router.post('/join', controller.join);

// GET /api/v1/sessions/current - Get current session (uses session JWT)
router.get('/current', controller.getCurrent);

// GET /api/v1/sessions/:id
router.get('/:id', controller.getById);

// POST /api/v1/sessions/:sessionId/consumers - Add consumer
router.post('/:sessionId/consumers', validate(addConsumerSchema), controller.addConsumer);

// POST /api/v1/sessions/:sessionId/orders - Add items to order
router.post('/:sessionId/orders', validate(addOrderItemSchema), controller.addOrderItems);

// POST /api/v1/sessions/:sessionId/service-calls - Create service call
router.post('/:sessionId/service-calls', validate(createServiceCallSchema), controller.createServiceCall);

// GET /api/v1/sessions/:sessionId/totals - Get individual totals
router.get('/:sessionId/totals', controller.getTotals);

// PROTECTED admin routes
// PATCH /api/v1/sessions/:id/status - Update session status (admin only)
router.patch('/:id/status', authenticateToken, requireActiveSubscription, controller.updateStatus);

export default router;
