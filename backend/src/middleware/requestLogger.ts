import { Request, Response, NextFunction } from 'express'
import { v4 as uuidv4 } from 'uuid'
import { logger } from '../utils/logger'

export const requestLogger = (req: Request, res: Response, next: NextFunction) => {
  const requestId = uuidv4()
  const startTime = Date.now()

  // Add request ID to headers for tracking
  req.headers['x-request-id'] = requestId
  res.setHeader('x-request-id', requestId)

  // Log incoming request
  logger.info('Incoming request', {
    requestId,
    method: req.method,
    url: req.url,
    ip: req.ip,
    userAgent: req.get('User-Agent'),
  })

  // Override res.end to log response
  const originalEnd = res.end
  res.end = function(chunk?: any, encoding?: any) {
    const duration = Date.now() - startTime
    
    logger.info('Request completed', {
      requestId,
      method: req.method,
      url: req.url,
      statusCode: res.statusCode,
      duration: `${duration}ms`,
    })

    return originalEnd.call(this, chunk, encoding)
  }

  next()
}