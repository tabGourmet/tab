import { Request, Response, NextFunction } from 'express';

export class AppError extends Error {
    statusCode: number;
    isOperational: boolean;

    constructor(message: string, statusCode: number = 500) {
        super(message);
        this.statusCode = statusCode;
        this.isOperational = true;
        Error.captureStackTrace(this, this.constructor);
    }
}

export const errorHandler = (
    err: Error | AppError,
    _req: Request,
    res: Response,
    _next: NextFunction
) => {
    if (err instanceof AppError) {
        return res.status(err.statusCode).json({
            success: false,
            error: err.message,
        });
    }

    // Handle Prisma Unique Constraint Violation
    if ((err as any).code === 'P2002') {
        const target = (err as any).meta?.target;
        return res.status(400).json({
            success: false,
            error: `Duplicate value for unique field: ${target ? target.join(', ') : 'unknown'}`,
        });
    }

    // Log unexpected errors server-side only
    console.error('Unexpected error:', err);

    // Never leak error details or stack traces to the client
    return res.status(500).json({
        success: false,
        error: 'Internal server error',
    });
};
