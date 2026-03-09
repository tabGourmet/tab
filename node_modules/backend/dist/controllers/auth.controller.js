"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AuthController = void 0;
const bcrypt_1 = __importDefault(require("bcrypt"));
const jsonwebtoken_1 = __importDefault(require("jsonwebtoken"));
const database_1 = __importDefault(require("../config/database"));
const error_handler_1 = require("../middleware/error-handler");
const env_1 = require("../config/env");
class AuthController {
    async register(req, res, next) {
        try {
            console.log('📝 register called');
            console.log('  Request body:', req.body);
            const { email, password, firstName, lastName, businessName, phone } = req.body;
            console.log('  Checking if email exists:', email);
            const existing = await database_1.default.user.findUnique({ where: { email } });
            if (existing) {
                console.log('  ❌ Email already registered');
                throw new error_handler_1.AppError('Email already registered', 400);
            }
            console.log('  ✅ Email available, hashing password...');
            const passwordHash = await bcrypt_1.default.hash(password, 12);
            const trialEndsAt = new Date();
            trialEndsAt.setDate(trialEndsAt.getDate() + (parseInt(process.env.TRIAL_PERIOD_DAYS || '15')));
            console.log('  Creating user...');
            const user = await database_1.default.user.create({
                data: {
                    email,
                    passwordHash,
                    firstName,
                    lastName,
                    businessName,
                    phone,
                    status: 'TRIAL',
                    trialEndsAt
                }
            });
            console.log('  ✅ User created:', user.id);
            console.log('  Generating JWT token...');
            const token = jsonwebtoken_1.default.sign({ id: user.id, email: user.email, role: user.role }, env_1.config.jwtSecret || 'your-secret-key', { expiresIn: '7d' });
            console.log('  🎉 Registration successful!');
            res.status(201).json({
                success: true,
                data: {
                    token,
                    user: {
                        id: user.id,
                        email: user.email,
                        businessName: user.businessName,
                        status: user.status,
                        restaurantSlug: null
                    }
                }
            });
        }
        catch (error) {
            console.error('  ❌ Registration error:', error);
            next(error);
        }
    }
    async login(req, res, next) {
        try {
            const { email, password } = req.body;
            const user = await database_1.default.user.findUnique({
                where: { email },
                include: { restaurants: { take: 1 } }
            });
            if (!user) {
                throw new error_handler_1.AppError('Invalid credentials', 401);
            }
            const validPassword = await bcrypt_1.default.compare(password, user.passwordHash);
            if (!validPassword) {
                throw new error_handler_1.AppError('Invalid credentials', 401);
            }
            // Update last login
            await database_1.default.user.update({
                where: { id: user.id },
                data: { lastLoginAt: new Date() }
            });
            const token = jsonwebtoken_1.default.sign({ id: user.id, email: user.email, role: user.role }, env_1.config.jwtSecret || 'your-secret-key', { expiresIn: '7d' });
            res.json({
                success: true,
                data: {
                    token,
                    user: {
                        id: user.id,
                        email: user.email,
                        businessName: user.businessName,
                        status: user.status,
                        restaurantSlug: user.restaurants[0]?.slug
                    }
                }
            });
        }
        catch (error) {
            next(error);
        }
    }
    async me(req, res, next) {
        try {
            const user = await database_1.default.user.findUnique({
                where: { id: req.user.id },
                include: { restaurants: { take: 1 } }
            });
            if (!user) {
                throw new error_handler_1.AppError('User not found', 404);
            }
            res.json({
                success: true,
                data: {
                    id: user.id,
                    email: user.email,
                    firstName: user.firstName,
                    lastName: user.lastName,
                    businessName: user.businessName,
                    status: user.status,
                    role: user.role,
                    trialEndsAt: user.trialEndsAt,
                    restaurantSlug: user.restaurants[0]?.slug
                }
            });
        }
        catch (error) {
            next(error);
        }
    }
    async createRestaurant(req, res, next) {
        try {
            console.log('🔍 createRestaurant called');
            console.log('  Request body:', req.body);
            console.log('  User from token:', req.user);
            const { name, slug } = req.body;
            const userId = req.user.id;
            console.log('  Checking if slug exists:', slug);
            const existing = await database_1.default.restaurant.findUnique({ where: { slug } });
            if (existing) {
                console.log('  ❌ Slug already taken');
                throw new error_handler_1.AppError('Slug is already taken', 400);
            }
            console.log('  Creating restaurant...');
            const restaurant = await database_1.default.restaurant.create({
                data: {
                    name,
                    slug,
                    ownerId: userId
                }
            });
            console.log('  ✅ Restaurant created:', restaurant.id);
            console.log('  Creating categories...');
            // Create default categories for the new restaurant
            const defaultCategories = [
                { name: 'Entradas', displayOrder: 1, imageUrl: 'https://images.unsplash.com/photo-1541014741259-de529411b96a?auto=format&fit=crop&w=800&q=80' },
                { name: 'Comida', displayOrder: 2, imageUrl: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?auto=format&fit=crop&w=800&q=80' },
                { name: 'Bebidas', displayOrder: 3, imageUrl: 'https://images.unsplash.com/photo-1544145945-f90425340c7e?auto=format&fit=crop&w=800&q=80' },
                { name: 'Postres', displayOrder: 4, imageUrl: 'https://images.unsplash.com/photo-1551024601-bec78aea704b?auto=format&fit=crop&w=800&q=80' },
            ];
            await Promise.all(defaultCategories.map(cat => database_1.default.category.create({
                data: {
                    restaurantId: restaurant.id,
                    name: cat.name,
                    displayOrder: cat.displayOrder,
                    imageUrl: cat.imageUrl,
                },
            })));
            console.log('  ✅ Categories created');
            console.log('  Creating tables...');
            // Create default tables (1-10)
            await Promise.all(Array.from({ length: 10 }, (_, i) => i + 1).map(num => database_1.default.table.create({
                data: {
                    restaurantId: restaurant.id,
                    number: String(num),
                    isEnabled: true,
                },
            })));
            console.log('  ✅ Tables created');
            console.log('  🎉 Restaurant setup complete!');
            res.status(201).json({ success: true, data: restaurant });
        }
        catch (error) {
            console.error('  ❌ Error in createRestaurant:', error);
            next(error);
        }
    }
    // Funcion para el cambio de contraseña
    async changePassword(req, res, next) {
        try {
            const { currentPassword, newPassword } = req.body;
            const userId = req.user.id;
            const user = await database_1.default.user.findUnique({ where: { id: userId } });
            if (!user)
                throw new error_handler_1.AppError('Usuario no encontrado', 404);
            const isMatch = await bcrypt_1.default.compare(currentPassword, user.passwordHash);
            if (!isMatch)
                throw new error_handler_1.AppError('La contraseña actual es incorrecta', 401);
            const newPasswordHash = await bcrypt_1.default.hash(newPassword, 12);
            await database_1.default.user.update({
                where: { id: userId },
                data: { passwordHash: newPasswordHash }
            });
            res.json({ success: true, message: 'Contraseña actualizada correctamente' });
        }
        catch (error) {
            next(error);
        }
    }
}
exports.AuthController = AuthController;
//# sourceMappingURL=auth.controller.js.map