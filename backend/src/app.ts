import express, { Application } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import { config } from './config/env';
import { errorHandler } from './middleware/error-handler';
import routes from './routes';

const app: Application = express();

const isDev = config.nodeEnv === 'development';

// Security headers
app.use(helmet());

// Trust proxy (required for rate limiting behind reverse proxy in production)
if (!isDev) {
    app.set('trust proxy', 1);
}

// CORS
app.use(cors({
    origin: isDev ? '*' : config.frontendUrl,
    credentials: true,
}));

// Body parsing with size limit
app.use(express.json({ limit: '1mb' }));

// Health check
app.get('/health', (_, res) => {
    res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// API Routes
app.use('/api/v1', routes);

// Error handling
app.use(errorHandler);

export default app;
