import { Request, Response, NextFunction } from 'express';
import logger from '../utils/logger.js';

// Interface for performance metrics
interface PerformanceMetrics {
  requestId: string;
  method: string;
  url: string;
  startTime: number;
  endTime?: number;
  duration?: number;
  statusCode?: number;
  contentLength?: number;
  userAgent?: string;
  ip?: string;
  userId?: string;
  memoryUsage?: {
    rss: number;
    heapTotal: number;
    heapUsed: number;
    external: number;
    arrayBuffers: number;
  };
}

// Store for tracking active requests
const activeRequests = new Map<string, PerformanceMetrics>();

// Performance thresholds (in milliseconds)
const PERFORMANCE_THRESHOLDS = {
  SLOW_REQUEST: 1000, // 1 second
  VERY_SLOW_REQUEST: 5000, // 5 seconds
};

// Generate unique request ID
function generateRequestId(): string {
  return `req_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
}

// Performance monitoring middleware
export const performanceMonitor = (
  req: Request,
  res: Response,
  next: NextFunction
): void => {
  const requestId = generateRequestId();
  const startTime = performance.now();

  // Store initial metrics
  const metrics: PerformanceMetrics = {
    requestId,
    method: req.method,
    url: req.url,
    startTime,
    userAgent: req.get('User-Agent'),
    ip: req.ip || req.connection.remoteAddress,
    userId: (req as any).user?.id,
    memoryUsage: process.memoryUsage(),
  };

  // Add request ID to request object for other middleware to use
  (req as any).requestId = requestId;
  res.setHeader('X-Request-ID', requestId);

  // Store metrics for this request
  activeRequests.set(requestId, metrics);

  // Override res.end to capture response metrics
  const originalEnd = res.end.bind(res);
  res.end = function (chunk?: any, encoding?: any, cb?: any): Response {
    const endTime = performance.now();
    const duration = endTime - startTime;

    // Update metrics
    metrics.endTime = endTime;
    metrics.duration = duration;
    metrics.statusCode = res.statusCode;
    metrics.contentLength = parseInt(res.get('Content-Length') || '0', 10);

    // Log performance metrics
    logPerformanceMetrics(metrics);

    // Remove from active requests
    activeRequests.delete(requestId);

    // Call original end method
    return originalEnd(chunk, encoding, cb);
  } as any;

  // Set response time header
  res.on('finish', () => {
    const responseTime = performance.now() - startTime;
    res.setHeader('X-Response-Time', responseTime.toFixed(2));
  });

  next();
};

// Log performance metrics based on thresholds
function logPerformanceMetrics(metrics: PerformanceMetrics): void {
  const { duration = 0, method, url, statusCode, requestId, userId } = metrics;

  const logData = {
    requestId,
    method,
    url,
    statusCode,
    duration: `${duration.toFixed(2)}ms`,
    userId: userId || 'anonymous',
    memoryUsage: metrics.memoryUsage,
  };

  // Log based on performance thresholds
  if (duration > PERFORMANCE_THRESHOLDS.VERY_SLOW_REQUEST) {
    logger.warn('Very slow request detected', logData);
  } else if (duration > PERFORMANCE_THRESHOLDS.SLOW_REQUEST) {
    logger.warn('Slow request detected', logData);
  } else if (statusCode && statusCode >= 400) {
    logger.warn('Request completed with error status', logData);
  } else {
    logger.debug('Request completed', logData);
  }
}

// Middleware to get current active requests (for health monitoring)
export const getActiveRequestsCount = (): number => {
  return activeRequests.size;
};

// Middleware to get performance statistics
export const getPerformanceStats = () => {
  const memUsage = process.memoryUsage();
  const uptime = process.uptime();

  return {
    activeRequests: activeRequests.size,
    uptime: `${uptime.toFixed(2)}s`,
    memory: {
      rss: `${(memUsage.rss / 1024 / 1024).toFixed(2)}MB`,
      heapTotal: `${(memUsage.heapTotal / 1024 / 1024).toFixed(2)}MB`,
      heapUsed: `${(memUsage.heapUsed / 1024 / 1024).toFixed(2)}MB`,
      external: `${(memUsage.external / 1024 / 1024).toFixed(2)}MB`,
    },
    thresholds: PERFORMANCE_THRESHOLDS,
  };
};

// Clean up orphaned requests (in case res.end is never called)
setInterval(() => {
  const now = performance.now();
  const timeout = 30000; // 30 seconds

  for (const [requestId, metrics] of activeRequests.entries()) {
    if (now - metrics.startTime > timeout) {
      logger.warn('Orphaned request detected and cleaned up', {
        requestId,
        method: metrics.method,
        url: metrics.url,
        timeoutDuration: `${timeout}ms`,
      });
      activeRequests.delete(requestId);
    }
  }
}, 60000); // Run cleanup every minute
