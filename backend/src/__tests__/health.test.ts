import request from 'supertest'
import express from 'express'
import healthRoutes from '../routes/healthRoutes'

const app = express()
app.use('/health', healthRoutes)

describe('Health Endpoints', () => {
  describe('GET /health', () => {
    it('should return health status', async () => {
      const response = await request(app)
        .get('/health')
        .expect(200)

      expect(response.body).toHaveProperty('status', 'healthy')
      expect(response.body).toHaveProperty('timestamp')
      expect(response.body).toHaveProperty('uptime')
      expect(response.body).toHaveProperty('environment')
      expect(response.body).toHaveProperty('version')
      expect(response.body).toHaveProperty('memory')
    })
  })

  describe('GET /health/ready', () => {
    it('should return readiness status', async () => {
      const response = await request(app)
        .get('/health/ready')
        .expect(200)

      expect(response.body).toHaveProperty('status', 'ready')
      expect(response.body).toHaveProperty('timestamp')
      expect(response.body).toHaveProperty('checks')
    })
  })

  describe('GET /health/live', () => {
    it('should return liveness status', async () => {
      const response = await request(app)
        .get('/health/live')
        .expect(200)

      expect(response.body).toHaveProperty('status', 'alive')
      expect(response.body).toHaveProperty('timestamp')
    })
  })
})