"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.requireFullAccess = exports.requireActiveSubscription = exports.authenticateToken = void 0;
const jsonwebtoken_1 = __importDefault(require("jsonwebtoken"));
const error_handler_1 = require("./error-handler");
const env_1 = require("../config/env");
const database_1 = __importDefault(require("../config/database"));
const authenticateToken = async (req, res, next) => {
    try {
        console.log('🔐 authenticateToken middleware called');
        console.log('  Path:', req.path);
        console.log('  Method:', req.method);
        const authHeader = req.headers['authorization'];
        console.log('  Auth header:', authHeader ? 'Present' : 'Missing');
        const token = authHeader && authHeader.split(' ')[1];
        if (!token) {
            console.log('  ❌ No token found');
            throw new error_handler_1.AppError('Authentication token required', 401);
        }
        console.log('  ✅ Token found, verifying...');
        const decoded = jsonwebtoken_1.default.verify(token, env_1.config.jwtSecret || 'your-secret-key');
        console.log('  ✅ Token verified, user ID:', decoded.id);
        // Check if user still exists and get latest status
        const user = await database_1.default.user.findUnique({
            where: { id: decoded.id }
        });
        if (!user) {
            console.log('  ❌ User not found in database');
            throw new error_handler_1.AppError('User not found or deactivated', 401);
        }
        console.log('  ✅ User found:', user.email);
        req.user = {
            id: user.id,
            email: user.email,
            role: user.role,
            status: user.status
        };
        console.log('  ✅ Auth successful, proceeding to next middleware');
        next();
    }
    catch (error) {
        console.error('  ❌ Auth error:', error);
        if (error instanceof jsonwebtoken_1.default.TokenExpiredError) {
            next(new error_handler_1.AppError('Token expired', 401));
        }
        else if (error instanceof jsonwebtoken_1.default.JsonWebTokenError) {
            next(new error_handler_1.AppError('Invalid token', 401));
        }
        else {
            next(error);
        }
    }
};
exports.authenticateToken = authenticateToken;
const requireActiveSubscription = (req, res, next) => {
    if (!req.user) {
        return next(new error_handler_1.AppError('Auth required', 401));
    }
    if (req.user.status === 'INACTIVE') {
        return next(new error_handler_1.AppError('Su cuenta está inactiva. Por favor, contacte a soporte para renovar su suscripción.', 403));
    }
    next();
};
exports.requireActiveSubscription = requireActiveSubscription;
const requireFullAccess = (req, res, next) => {
    if (!req.user) {
        return next(new error_handler_1.AppError('Auth required', 401));
    }
    if (req.user.status !== 'ACTIVE') {
        return next(new error_handler_1.AppError('Esta función requiere una suscripción activa (Prueba terminada).', 403));
    }
    next();
};
exports.requireFullAccess = requireFullAccess;
//# sourceMappingURL=auth.middleware.js.map