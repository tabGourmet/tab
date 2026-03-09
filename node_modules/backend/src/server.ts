import app from './app';
import { config } from './config/env';
import prisma from './config/database';

const start = async () => {
    try {
        // Test database connection
        await prisma.$connect();
        console.log('✅ Database connected');
       
        app.listen(config.port, () => {
            
              console.log(`🚀 Server running on http://localhost:${config.port}`);
            console.log(`📋 Environment: ${config.nodeEnv}`);
        });
    } catch (error) {
        console.error('❌ Failed to start server:', error);
        process.exit(1);
    }
};

// Graceful shutdown
process.on('SIGINT', async () => {
    await prisma.$disconnect();
    console.log('👋 Server shutdown gracefully');
    process.exit(0);
});

start();
