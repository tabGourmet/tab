"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.ProductController = void 0;
const database_1 = __importDefault(require("../config/database"));
const error_handler_1 = require("../middleware/error-handler");
const event_service_1 = require("../services/event.service");
const uuid_1 = require("uuid");
const supabase_1 = require("../config/supabase");
class ProductController {
    async getById(req, res, next) {
        try {
            const { id } = req.params;
            const product = await database_1.default.product.findUnique({
                where: { id: String(id) },
                include: { category: true },
            });
            if (!product) {
                throw new error_handler_1.AppError('Product not found', 404);
            }
            res.json({ success: true, data: product });
        }
        catch (error) {
            next(error);
        }
    }
    // PRUEBA PARA SUBIR IMAGEN
    async uploadImage(req, res, next) {
        try {
            const { id } = req.params;
            const file = req.file;
            if (!file) {
                throw new error_handler_1.AppError('No image file provided', 400);
            }
            // 1. Validar que el producto existe
            const productExists = await database_1.default.product.findUnique({ where: { id: String(id) } });
            if (!productExists) {
                throw new error_handler_1.AppError('Product not found', 404);
            }
            // 2. Subir a Supabase Storage
            const fileExtension = file.originalname.split('.').pop();
            const fileName = `${(0, uuid_1.v4)()}.${fileExtension}`;
            const bucketName = 'imagenes de productos tab';
            const { data, error } = await supabase_1.supabase.storage
                .from(bucketName)
                .upload(fileName, file.buffer, {
                contentType: file.mimetype,
                upsert: true
            });
            if (error)
                throw error;
            // 3. Obtener URL pública
            const { data: { publicUrl } } = supabase_1.supabase.storage
                .from(bucketName)
                .getPublicUrl(fileName);
            // 4. Actualizar la base de datos con la nueva URL
            const updatedProduct = await database_1.default.product.update({
                where: { id: String(id) },
                data: { imageUrl: publicUrl },
            });
            res.json({
                success: true,
                data: updatedProduct
            });
        }
        catch (error) {
            next(error);
        }
    }
    // FIN DE PRUEBA
    async update(req, res, next) {
        try {
            const { id } = req.params;
            const { categoryId, name, description, price, imageUrl, isAvailable } = req.body;
            const product = await database_1.default.product.update({
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
            await event_service_1.EventService.publish(product.restaurantId, 'PRODUCT_UPDATED', {
                productId: product.id,
                name: product.name,
                price: Number(product.price),
                isAvailable: product.isAvailable,
            });
            res.json({ success: true, data: product });
        }
        catch (error) {
            next(error);
        }
    }
    async delete(req, res, next) {
        try {
            const { id } = req.params;
            await database_1.default.product.delete({ where: { id: String(id) } });
            res.json({ success: true, message: 'Product deleted' });
        }
        catch (error) {
            next(error);
        }
    }
    async toggleAvailability(req, res, next) {
        try {
            const { id } = req.params;
            const product = await database_1.default.product.findUnique({ where: { id: String(id) } });
            if (!product) {
                throw new error_handler_1.AppError('Product not found', 404);
            }
            const updated = await database_1.default.product.update({
                where: { id: String(id) },
                data: { isAvailable: !product.isAvailable },
                include: { category: true },
            });
            await event_service_1.EventService.publish(product.restaurantId, 'PRODUCT_UPDATED', {
                productId: updated.id,
                name: updated.name,
                isAvailable: updated.isAvailable,
                action: 'availability_toggle',
            });
            res.json({ success: true, data: updated });
        }
        catch (error) {
            next(error);
        }
    }
}
exports.ProductController = ProductController;
//# sourceMappingURL=product.controller.js.map