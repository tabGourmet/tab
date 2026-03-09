"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const product_controller_1 = require("../controllers/product.controller");
const validate_1 = require("../middleware/validate");
const auth_middleware_1 = require("../middleware/auth.middleware");
const schemas_1 = require("../schemas");
const multer_1 = __importDefault(require("multer"));
const router = (0, express_1.Router)();
const controller = new product_controller_1.ProductController();
const upload = (0, multer_1.default)({
    storage: multer_1.default.memoryStorage(),
    limits: { fileSize: 5 * 1024 * 1024 }, // 5MB max
});
// NUEVA RUTA: Recibe el ID del producto y el archivo bajo el campo 'image'
router.patch('/:id/image', auth_middleware_1.authenticateToken, upload.single('image'), controller.uploadImage);
// Note: Create product is nested under restaurant
// POST /api/v1/restaurants/:restaurantId/products - handled in restaurant routes
// GET /api/v1/products/:id
router.get('/:id', controller.getById);
// PUT /api/v1/products/:id
router.put('/:id', auth_middleware_1.authenticateToken, (0, validate_1.validate)(schemas_1.updateProductSchema), controller.update);
// DELETE /api/v1/products/:id
router.delete('/:id', auth_middleware_1.authenticateToken, controller.delete);
// PATCH /api/v1/products/:id/availability
router.patch('/:id/availability', auth_middleware_1.authenticateToken, controller.toggleAvailability);
exports.default = router;
//# sourceMappingURL=product.routes.js.map