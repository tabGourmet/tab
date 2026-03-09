import { Request, Response, NextFunction } from 'express';
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import prisma from '../config/database';
import { AppError } from '../middleware/error-handler';
import { config } from '../config/env';

export class AuthController {
  async register(req: Request, res: Response, next: NextFunction) {
    try {
      const { email, password, firstName, lastName, businessName, phone } = req.body;

      const existing = await prisma.user.findUnique({ where: { email } });
      if (existing) {
        throw new AppError('Email already registered', 400);
      }

      const passwordHash = await bcrypt.hash(password, 12);

      const trialEndsAt = new Date();
      trialEndsAt.setDate(trialEndsAt.getDate() + (parseInt(process.env.TRIAL_PERIOD_DAYS || '15')));

      const user = await prisma.user.create({
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

      const token = jwt.sign(
        { id: user.id, email: user.email, role: user.role },
        config.jwtSecret,
        { expiresIn: '7d' }
      );

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
    } catch (error) {
      next(error);
    }
  }

  async login(req: Request, res: Response, next: NextFunction) {
    try {
      const { email, password } = req.body;

      const user = await prisma.user.findUnique({
        where: { email },
        include: { restaurants: { take: 1 } }
      });

      if (!user) {
        throw new AppError('Invalid credentials', 401);
      }

      const validPassword = await bcrypt.compare(password, user.passwordHash);
      if (!validPassword) {
        throw new AppError('Invalid credentials', 401);
      }

      // Update last login
      await prisma.user.update({
        where: { id: user.id },
        data: { lastLoginAt: new Date() }
      });

      const token = jwt.sign(
        { id: user.id, email: user.email, role: user.role },
        config.jwtSecret,
        { expiresIn: '7d' }
      );

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
    } catch (error) {
      next(error);
    }
  }

  async me(req: any, res: Response, next: NextFunction) {
    try {
      const user = await prisma.user.findUnique({
        where: { id: req.user.id },
        include: { restaurants: { take: 1 } }
      });

      if (!user) {
        throw new AppError('User not found', 404);
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
    } catch (error) {
      next(error);
    }
  }

  async createRestaurant(req: any, res: Response, next: NextFunction) {
    try {
      const { name, slug } = req.body;
      const userId = req.user.id;

      const existing = await prisma.restaurant.findUnique({ where: { slug } });
      if (existing) {
        throw new AppError('Slug is already taken', 400);
      }

      const restaurant = await prisma.restaurant.create({
        data: {
          name,
          slug,
          ownerId: userId
        }
      });

      // Create default categories for the new restaurant
      const defaultCategories = [
        { name: 'Entradas', displayOrder: 1, imageUrl: 'https://images.unsplash.com/photo-1541014741259-de529411b96a?auto=format&fit=crop&w=800&q=80' },
        { name: 'Comida', displayOrder: 2, imageUrl: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?auto=format&fit=crop&w=800&q=80' },
        { name: 'Bebidas', displayOrder: 3, imageUrl: 'https://images.unsplash.com/photo-1544145945-f90425340c7e?auto=format&fit=crop&w=800&q=80' },
        { name: 'Postres', displayOrder: 4, imageUrl: 'https://images.unsplash.com/photo-1551024601-bec78aea704b?auto=format&fit=crop&w=800&q=80' },
      ];

      await Promise.all(
        defaultCategories.map(cat =>
          prisma.category.create({
            data: {
              restaurantId: restaurant.id,
              name: cat.name,
              displayOrder: cat.displayOrder,
              imageUrl: cat.imageUrl,
            },
          })
        )
      );

      // Create default tables (1-10)
      await Promise.all(
        Array.from({ length: 10 }, (_, i) => i + 1).map(num =>
          prisma.table.create({
            data: {
              restaurantId: restaurant.id,
              number: String(num),
              isEnabled: true,
            },
          })
        )
      );

      res.status(201).json({ success: true, data: restaurant });
    } catch (error) {
      next(error);
    }
  }

  // Funcion para el cambio de contraseña

  async changePassword(req: any, res: Response, next: NextFunction) {
    try {
      const { currentPassword, newPassword } = req.body;
      const userId = req.user.id;

      const user = await prisma.user.findUnique({ where: { id: userId } });
      if (!user) throw new AppError('Usuario no encontrado', 404);

      const isMatch = await bcrypt.compare(currentPassword, user.passwordHash);
      if (!isMatch) throw new AppError('La contraseña actual es incorrecta', 401);

      const newPasswordHash = await bcrypt.hash(newPassword, 12);

      await prisma.user.update({
        where: { id: userId },
        data: { passwordHash: newPasswordHash }
      });

      res.json({ success: true, message: 'Contraseña actualizada correctamente' });
    } catch (error) {
      next(error);
    }
  }

}
