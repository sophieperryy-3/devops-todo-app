import { Request, Response, NextFunction } from 'express'
import { logger } from '../utils/logger'

export interface ApiError extends Error {
  statusCode?: number
  code?: string
}

export const errorHandler = (
  err: ApiError,
  req: Request,
  res: Response,
  next: NextFunction
) => {
  // Log the error
  logger.error('API Error:', {
    error: err.message,
    stack: err.stack,
    url: req.url,
    method: req.method,
    ip: req.ip,
    userAgent: req.get('User-Agent'),
  })

  // Default error response
  const statusCode = err.statusCode || 500
  const errorCode = err.code || 'INTERNAL_SERVER_ERROR'
  const message = err.message || 'An unexpected error occurred'

  res.status(statusCode).json({
    error: {
      code: errorCode,
      message,
      timestamp: new Date().toISOString(),
      requestId: req.headers['x-request-id'] || 'unknown',
    },
  })
}

export const createError = (message: string, statusCode: number = 500, code?: string): ApiError => {
  const error = new Error(message) as ApiError
  error.statusCode = statusCode
  error.code = code
  return error
}