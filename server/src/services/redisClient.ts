import Redis from 'ioredis';
import dotenv from 'dotenv';

dotenv.config();

const REDIS_HOST = process.env.REDIS_HOST || '127.0.0.1';
const REDIS_PORT = Number(process.env.REDIS_PORT) || 6379;

const redis = new Redis({
  host: REDIS_HOST,
  port: REDIS_PORT,
  maxRetriesPerRequest: null,
});

redis.on('connect', () => {
  console.log('[REDIS] Connected to Redis Server');
});

redis.on('error', (err) => {
  console.error('[REDIS] Connection Error:', err);
});

export default redis;
