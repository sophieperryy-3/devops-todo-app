import { Pool, PoolConfig } from 'pg'
import { logger } from '../utils/logger'

const config: PoolConfig = {
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '5432'),
  database: process.env.DB_NAME || 'todoapp',
  user: process.env.DB_USER || 'todouser',
  password: process.env.DB_PASSWORD || 'todopass',
  max: 20, // Maximum number of clients in the pool
  idleTimeoutMillis: 30000, // Close idle clients after 30 seconds
  connectionTimeoutMillis: 2000, // Return an error after 2 seconds if connection could not be established
}

export const pool = new Pool(config)

// Test the connection
pool.on('connect', () => {
  logger.info('Connected to PostgreSQL database')
})

pool.on('error', (err) => {
  logger.error('PostgreSQL connection error:', err)
})

// Graceful shutdown
process.on('SIGINT', async () => {
  logger.info('Closing database connections...')
  await pool.end()
})

process.on('SIGTERM', async () => {
  logger.info('Closing database connections...')
  await pool.end()
})

export const query = async (text: string, params?: any[]) => {
  const start = Date.now()
  try {
    const result = await pool.query(text, params)
    const duration = Date.now() - start
    logger.debug('Executed query', { text, duration, rows: result.rowCount })
    return result
  } catch (error) {
    logger.error('Database query error:', { text, error })
    throw error
  }
}