import { Request, Response, NextFunction } from 'express';
import prisma from '../config/database';
import { AppError } from '../middleware/error-handler';
import { EventService } from '../services/event.service';
import { v4 as uuidv4 } from 'uuid';
import { supabase } from '../config/supabase';


export class ProductController {
    async getById(req: Request, res: Response, next: NextFunction) {
        try {
            const { id } = req.params;

            const product = await prisma.product.findUnique({
                where: { id: String(id) },
                include: { category: true },
            });

            if (!product) {
                throw new AppError('Product not found', 404);
            }

            res.json({ success: true, data: product });
        } catch (error) {
            next(error);
        }
    }

    // PRUEBA PARA SUBIR IMAGEN

    async uploadImage(req: Request, res: Response, next: NextFunction) {
  try {
    const { id } = req.params;
    const file = req.file;

    if (!file) {
      throw new AppError('No image file provided', 400);
    }

    // 1. Validar que el producto existe
    const productExists = await prisma.product.findUnique({ where: { id: String(id) } });
    if (!productExists) {
      throw new AppError('Product not found', 404);
    }

    // 2. Subir a Supabase Storage
    const fileExtension = file.originalname.split('.').pop();
    const fileName = `${uuidv4()}.${fileExtension}`;
    const bucketName = 'imagenes de productos tab';

    const { data, error } = await supabase.storage
      .from(bucketName)
      .upload(fileName, file.buffer, {
        contentType: file.mimetype,
        upsert: true
      });

    if (error) throw error;

    // 3. Obtener URL pública
    const { data: { publicUrl } } = supabase.storage
      .from(bucketName)
      .getPublicUrl(fileName);

    // 4. Actualizar la base de datos con la nueva URL
    const updatedProduct = await prisma.product.update({
      where: { id: String(id) },
      data: { imageUrl: publicUrl },
    });

    res.json({
      success: true,
      data: updatedProduct
    });

  } catch (error) {
    next(error);
  }
}

    // FIN DE PRUEBA

    async update(req: Request, res: Response, next: NextFunction) {
        try {
            const { id } = req.params;
            const { categoryId, name, description, price, imageUrl, isAvailable } = req.body;

            const product = await prisma.product.update({
                where: { id: String(id) },
                data: {
                    ...(categoryId && { categoryId }),
                    ...(name && { name }),
                    ...(description !== undefined && { description }),
                    ...(price && { price }),
                    ...(imageUrl !== undefined && { imageUrl }),
                    ...(isAvailable !== undefined && { isAvailable }),
                },
                include: { category: true },
            });

            await EventService.publish(product.restaurantId, 'PRODUCT_UPDATED', {
                productId: product.id,
                name: product.name,
                price: Number(product.price),
                isAvailable: product.isAvailable,
            });

            res.json({ success: true, data: product });
        } catch (error) {
            next(error);
        }
    }

    async delete(req: Request, res: Response, next: NextFunction) {
        try {
            const { id } = req.params;

            await prisma.product.delete({ where: { id: String(id) } });

            res.json({ success: true, message: 'Product deleted' });
        } catch (error) {
            next(error);
        }
    }

    async toggleAvailability(req: Request, res: Response, next: NextFunction) {
        try {
            const { id } = req.params;

            const product = await prisma.product.findUnique({ where: { id: String(id) } });
            if (!product) {
                throw new AppError('Product not found', 404);
            }

            const updated = await prisma.product.update({
                where: { id: String(id) },
                data: { isAvailable: !product.isAvailable },
                include: { category: true },
            });

            await EventService.publish(product.restaurantId, 'PRODUCT_UPDATED', {
                productId: updated.id,
                name: updated.name,
                isAvailable: updated.isAvailable,
                action: 'availability_toggle',
            });

            res.json({ success: true, data: updated });
        } catch (error) {
            next(error);
        }
    }
}
