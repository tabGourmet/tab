import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { AppError } from './error-handler';
import { config } from '../config/env';
import prisma from '../config/database';

export interface AuthRequest extends Request {
  user?: {
    id: string;
    email: string;
    role: string;
    status: string;
  };
}

export const authenticateToken = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];

    if (!token) {
      throw new AppError('Authentication token required', 401);
    }

    const decoded = jwt.verify(token, config.jwtSecret) as any;

    // Check if user still exists and get latest status
    const user = await prisma.user.findUnique({
      where: { id: decoded.id }
    });

    if (!user) {
      throw new AppError('User not found or deactivated', 401);
    }

    req.user = {
      id: user.id,
      email: user.email,
      role: user.role,
      status: user.status
    };

    next();
  } catch (error) {
    if (error instanceof jwt.TokenExpiredError) {
      next(new AppError('Token expired', 401));
    } else if (error instanceof jwt.JsonWebTokenError) {
      next(new AppError('Invalid token', 401));
    } else {
      next(error);
    }
  }
};

export const requireActiveSubscription = (req: AuthRequest, res: Response, next: NextFunction) => {
  if (!req.user) {
    return next(new AppError('Auth required', 401));
  }

  if (req.user.status === 'INACTIVE') {
    return next(new AppError('Su cuenta está inactiva. Por favor, contacte a soporte para renovar su suscripción.', 403));
  }

  next();
};

export const requireFullAccess = (req: AuthRequest, res: Response, next: NextFunction) => {
  if (!req.user) {
    return next(new AppError('Auth required', 401));
  }

  if (req.user.status !== 'ACTIVE') {
    return next(new AppError('Esta función requiere una suscripción activa (Prueba terminada).', 403));
  }

  next();
};
