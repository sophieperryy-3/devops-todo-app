import { Router } from 'express'
import { logger } from '../utils/logger'
import { query } from '../database/connection'
import { taskService } from '../services/taskService'

const router = Router()

router.get('/', async (req, res) => {
  try {
    // Test database connectivity
    await query('SELECT 1')
    
    const healthCheck = {
      status: 'healthy',
      timestamp: new Date().toISOString(),
      uptime: process.uptime(),
      environment: process.env.NODE_ENV || 'development',
      version: '1.0.0',
      memory: {
        used: Math.round(process.memoryUsage().heapUsed / 1024 / 1024 * 100) / 100,
        total: Math.round(process.memoryUsage().heapTotal / 1024 / 1024 * 100) / 100,
      },
      database: 'connected',
    }

    logger.info('Health check requested', { status: 'healthy' })
    res.json(healthCheck)
  } catch (error) {
    logger.error('Health check failed:', error)
    res.status(503).json({
      status: 'unhealthy',
      timestamp: new Date().toISOString(),
      error: 'Database connection failed',
    })
  }
})

router.get('/ready', async (req, res) => {
  try {
    // Test database connectivity
    await query('SELECT 1')
    
    // Get basic stats to ensure everything is working
    const stats = await taskService.getTaskStats()
    
    res.json({
      status: 'ready',
      timestamp: new Date().toISOString(),
      checks: {
        database: 'connected',
        api: 'operational',
      },
      stats,
    })
  } catch (error) {
    logger.error('Readiness check failed:', error)
    res.status(503).json({
      status: 'not ready',
      timestamp: new Date().toISOString(),
      error: error instanceof Error ? error.message : 'Unknown error',
    })
  }
})

router.get('/live', (req, res) => {
  res.json({
    status: 'alive',
    timestamp: new Date().toISOString(),
  })
})

export default router