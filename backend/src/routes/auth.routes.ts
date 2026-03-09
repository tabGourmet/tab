import { Router } from 'express';
import rateLimit from 'express-rate-limit';
import { AuthController } from '../controllers/auth.controller';
import { authenticateToken } from '../middleware/auth.middleware';

const router = Router();
const controller = new AuthController();

// Rate limiting for auth routes (prevent brute force)
const authLimiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 10, // max 10 attempts per window
    message: { success: false, error: 'Demasiados intentos. Intente de nuevo en 15 minutos.' },
    standardHeaders: true,
    legacyHeaders: false,
});

// Public routes (with rate limiting)
router.post('/register', authLimiter, controller.register);
router.post('/login', authLimiter, controller.login);

// Protected routes
router.get('/me', authenticateToken, controller.me);
router.post('/create-restaurant', authenticateToken, controller.createRestaurant);
router.post('/change-password', authenticateToken, (req, res, next) => controller.changePassword(req, res, next));

export default router;
