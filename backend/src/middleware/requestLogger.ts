import morgan from 'morgan';
import logger from '../utils/logger.js';

// Define custom token for user ID if authenticated
morgan.token('user-id', (req: any) => {
  return req.user?.id || 'anonymous';
});

// Create middleware - using any to bypass TypeScript issues with morgan versions
const requestLogger = (morgan as any)(
  process.env.NODE_ENV === 'production' ? 'combined' : 'dev',
  {
    stream: logger.stream,
    // Skip logging for health check endpoints
    skip: (req: any) => {
      return req.url === '/health' || req.url === '/metrics';
    },
  }
);

export default requestLogger;
