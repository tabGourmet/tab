import dotenv from 'dotenv';

dotenv.config();

const isDev = (process.env.NODE_ENV || 'development') === 'development';

// Fail fast: validate required env vars in production
if (!isDev) {
    const required = ['DATABASE_URL', 'JWT_SECRET', 'FRONTEND_URL'];
    const missing = required.filter(key => !process.env[key]);
    if (missing.length > 0) {
        throw new Error(`Missing required environment variables: ${missing.join(', ')}`);
    }
}

export const config = {
    nodeEnv: process.env.NODE_ENV || 'development',
    port: parseInt(process.env.PORT || '3001', 10),
    databaseUrl: process.env.DATABASE_URL || '',
    frontendUrl: process.env.FRONTEND_URL || 'http://localhost:5173',
    jwtSecret: process.env.JWT_SECRET || (isDev ? 'dev-only-secret-key' : ''),
};
