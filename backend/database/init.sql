-- Initialize database schema for Todo application

-- Create tasks table
CREATE TABLE IF NOT EXISTS tasks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    completed BOOLEAN DEFAULT FALSE,
    priority VARCHAR(10) DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high')),
    due_date TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_tasks_completed ON tasks(completed);
CREATE INDEX IF NOT EXISTS idx_tasks_created_at ON tasks(created_at);
CREATE INDEX IF NOT EXISTS idx_tasks_priority ON tasks(priority);
CREATE INDEX IF NOT EXISTS idx_tasks_due_date ON tasks(due_date);

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger to automatically update updated_at
CREATE TRIGGER update_tasks_updated_at 
    BEFORE UPDATE ON tasks 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Insert sample data for development
INSERT INTO tasks (title, description, completed, priority, due_date) VALUES
    ('Set up development environment', 'Configure Docker, Node.js, and database', true, 'high', NULL),
    ('Implement user authentication', 'Add JWT-based authentication system', false, 'high', '2024-12-01 10:00:00'),
    ('Create task management API', 'Build CRUD endpoints for tasks', false, 'medium', '2024-11-25 15:30:00'),
    ('Add unit tests', 'Write comprehensive test suite', false, 'medium', NULL),
    ('Deploy to AWS', 'Set up production infrastructure', false, 'low', '2024-12-15 09:00:00')
ON CONFLICT DO NOTHING;