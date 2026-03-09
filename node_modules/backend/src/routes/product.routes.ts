import { Router } from 'express';
import { ProductController } from '../controllers/product.controller';
import { validate } from '../middleware/validate';
import { authenticateToken } from '../middleware/auth.middleware';
import { createProductSchema, updateProductSchema } from '../schemas';
import multer from 'multer';

const router = Router();
const controller = new ProductController();



const upload = multer({
    storage: multer.memoryStorage(),
    limits: { fileSize: 5 * 1024 * 1024 }, // 5MB max
    fileFilter: (_req, file, cb) => {
        const allowedTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'];
        if (allowedTypes.includes(file.mimetype)) {
            cb(null, true);
        } else {
            cb(new Error('Solo se permiten imágenes (JPEG, PNG, GIF, WebP)'));
        }
    },
});

// NUEVA RUTA: Recibe el ID del producto y el archivo bajo el campo 'image'
router.patch('/:id/image', authenticateToken, upload.single('image'), controller.uploadImage);
// Note: Create product is nested under restaurant
// POST /api/v1/restaurants/:restaurantId/products - handled in restaurant routes

// GET /api/v1/products/:id
router.get('/:id', controller.getById);

// PUT /api/v1/products/:id
router.put('/:id', authenticateToken, validate(updateProductSchema), controller.update);

// DELETE /api/v1/products/:id
router.delete('/:id', authenticateToken, controller.delete);

// PATCH /api/v1/products/:id/availability
router.patch('/:id/availability', authenticateToken, controller.toggleAvailability);

export default router;
