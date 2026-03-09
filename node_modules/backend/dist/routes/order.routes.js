"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const order_controller_1 = require("../controllers/order.controller");
const auth_middleware_1 = require("../middleware/auth.middleware");
const router = (0, express_1.Router)();
const controller = new order_controller_1.OrderController();
// GET /api/v1/orders/:id
router.get('/:id', controller.getById);
// PATCH /api/v1/orders/:id/status - Close order
router.patch('/:id/status', controller.updateStatus);
// Protected admin routes
router.use(auth_middleware_1.authenticateToken);
router.use(auth_middleware_1.requireActiveSubscription);
// PATCH /api/v1/orders/items/:id/status - Update order item status (admin)
router.patch('/items/:id/status', controller.updateItemStatus);
exports.default = router;
//# sourceMappingURL=order.routes.js.map