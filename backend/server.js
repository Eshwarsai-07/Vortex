import express from 'express';
import mongoose from 'mongoose';
import dotenv from 'dotenv';
import cors from 'cors';
import helmet from 'helmet';
import rateLimit from 'express-rate-limit';

import authRoutes from './routes/auth.routes.js';
import gitRoutes from './routes/git.routes.js';
import logRoutes from './routes/log.routes.js';
import deployRoutes from './routes/deploy.route.js';
import userRoutes from './routes/user.routes.js';

dotenv.config();

const app = express();
app.set('trust proxy', 1);

// Security Middlewares
app.use(helmet());
app.use(express.json());
app.use(cors({
    origin: process.env.CORS_ORIGIN || '*',
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization']
}));

// Rate Limiting
const limiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 5000, // High limit to accommodate live log polling
    message: { error: 'Too many requests from this IP, please try again later.' }
});
app.use('/api/', limiter);

// Health Check Endpoint
app.get('/health', (req, res) => {
    const mongoStatus = mongoose.connection.readyState === 1 ? 'UP' : 'DOWN';
    res.status(200).json({
        status: 'UP',
        timestamp: new Date().toISOString(),
        services: {
            database: mongoStatus
        }
    });
});

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/github', gitRoutes);
app.use('/api/logs', logRoutes);
app.use('/api/deploy', deployRoutes);
app.use('/api/user', userRoutes);

// Centralized Error Handler
app.use((err, req, res, next) => {
    console.error('Unhandled Server Error:', err.stack);
    res.status(500).json({ error: 'Internal Server Error' });
});

const PORT = process.env.PORT || 5000;
const MONGO_URI = process.env.MONGO_URI || 'mongodb://localhost:27017/vortex';

let server;

mongoose.connect(MONGO_URI)
    .then(() => {
        console.log('MongoDB connected successfully');
        server = app.listen(PORT, () => {
            console.log(`Server running on port ${PORT}`);
        });
    })
    .catch(err => {
        console.error('MongoDB connection error:', err);
        process.exit(1);
    });

// Graceful Shutdown
const gracefulShutdown = async (signal) => {
    console.log(`Received ${signal}. Shutting down gracefully...`);
    if (server) {
        server.close(async () => {
            console.log('HTTP server closed.');
            await mongoose.connection.close();
            console.log('MongoDB connection closed.');
            process.exit(0);
        });
    } else {
        process.exit(0);
    }
};

process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));
process.on('SIGINT', () => gracefulShutdown('SIGINT'));

