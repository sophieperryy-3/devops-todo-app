import { query } from './connection'
import { logger } from '../utils/logger'

export const runMigrations = async () => {
  try {
    logger.info('Running database migrations...')

    // Create tasks table if it doesn't exist
    await query(`
      CREATE TABLE IF NOT EXISTS tasks (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        title VARCHAR(255) NOT NULL,
        description TEXT,
        completed BOOLEAN DEFAULT FALSE,
        priority VARCHAR(10) DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high')),
        due_date TIMESTAMP,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `)

    // Create indexes for better query performance
    await query('CREATE INDEX IF NOT EXISTS idx_tasks_completed ON tasks(completed)')
    await query('CREATE INDEX IF NOT EXISTS idx_tasks_created_at ON tasks(created_at)')
    await query('CREATE INDEX IF NOT EXISTS idx_tasks_priority ON tasks(priority)')
    await query('CREATE INDEX IF NOT EXISTS idx_tasks_due_date ON tasks(due_date)')

    // Create function to update updated_at timestamp
    await query(`
      CREATE OR REPLACE FUNCTION update_updated_at_column()
      RETURNS TRIGGER AS $$
      BEGIN
          NEW.updated_at = CURRENT_TIMESTAMP;
          RETURN NEW;
      END;
      $$ language 'plpgsql'
    `)

    // Create trigger to automatically update updated_at
    await query(`
      DROP TRIGGER IF EXISTS update_tasks_updated_at ON tasks;
      CREATE TRIGGER update_tasks_updated_at 
          BEFORE UPDATE ON tasks 
          FOR EACH ROW 
          EXECUTE FUNCTION update_updated_at_column()
    `)

    logger.info('Database migrations completed successfully')
  } catch (error) {
    logger.error('Database migration failed:', error)
    throw error
  }
}

export const seedDatabase = async () => {
  try {
    logger.info('Seeding database with sample data...')

    // Check if we already have data
    const result = await query('SELECT COUNT(*) FROM tasks')
    const count = parseInt(result.rows[0].count)

    if (count > 0) {
      logger.info(`Database already has ${count} tasks, skipping seed`)
      return
    }

    // Insert sample data
    await query(`
      INSERT INTO tasks (title, description, completed, priority, due_date) VALUES
        ('Set up development environment', 'Configure Docker, Node.js, and database', true, 'high', NULL),
        ('Implement user authentication', 'Add JWT-based authentication system', false, 'high', $1),
        ('Create task management API', 'Build CRUD endpoints for tasks', false, 'medium', $2),
        ('Add unit tests', 'Write comprehensive test suite', false, 'medium', NULL),
        ('Deploy to AWS', 'Set up production infrastructure', false, 'low', $3)
    `, [
      new Date('2024-12-01T10:00:00Z'),
      new Date('2024-11-25T15:30:00Z'),
      new Date('2024-12-15T09:00:00Z')
    ])

    logger.info('Database seeded successfully')
  } catch (error) {
    logger.error('Database seeding failed:', error)
    throw error
  }
}