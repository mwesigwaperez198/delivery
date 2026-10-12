import express from 'express';
import http from 'http';
import { Server } from 'socket.io';
import cors from 'cors';
import dotenv from 'dotenv';
import mongoose from 'mongoose';
import morgan from 'morgan';

// Routes
import authRoutes from './routes/authRoutes';
import storefrontRoutes from './routes/storefrontRoutes';
import orderRoutes from './routes/orderRoutes';
import courierRoutes from './routes/courierRoutes';
import merchantRoutes from './routes/merchantRoutes';

dotenv.config();

const app = express();
const server = http.createServer(app);
export const io = new Server(server, { cors: { origin: '*' } });

// Middleware
app.use(cors());
app.use(express.json());
app.use(morgan('dev'));

// API Routes
app.use('/api/auth', authRoutes);
app.use('/api/storefront', storefrontRoutes);
app.use('/api/orders', orderRoutes);
app.use('/api/couriers', courierRoutes);
app.use('/api/merchants', merchantRoutes);

// Database Connection
const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/dynamics';
mongoose.connect(MONGODB_URI)
  .then(() => console.log('✅ Connected to MongoDB'))
  .catch(err => console.error('❌ MongoDB error:', err));

// Socket.io basic setup
io.on('connection', (socket) => {
  console.log('User connected:', socket.id);

  socket.on('join', (room) => {
    socket.join(room);
    console.log(`User ${socket.id} joined room: ${room}`);
  });

  socket.on('disconnect', () => console.log('User disconnected'));
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
});
