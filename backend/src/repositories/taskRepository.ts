import { query } from '../database/connection'
import { Task, CreateTaskRequest, UpdateTaskRequest } from '../types'
import { logger } from '../utils/logger'

export class TaskRepository {
  async findAll(): Promise<Task[]> {
    const result = await query(`
      SELECT 
        id,
        title,
        description,
        completed,
        priority,
        due_date as "dueDate",
        created_at as "createdAt",
        updated_at as "updatedAt"
      FROM tasks 
      ORDER BY completed ASC, priority DESC, created_at DESC
    `)

    return result.rows.map(row => ({
      ...row,
      createdAt: row.createdAt.toISOString(),
      updatedAt: row.updatedAt.toISOString(),
      dueDate: row.dueDate ? row.dueDate.toISOString() : undefined,
    }))
  }

  async findById(id: string): Promise<Task | null> {
    const result = await query(`
      SELECT 
        id,
        title,
        description,
        completed,
        priority,
        due_date as "dueDate",
        created_at as "createdAt",
        updated_at as "updatedAt"
      FROM tasks 
      WHERE id = $1
    `, [id])

    if (result.rows.length === 0) {
      return null
    }

    const row = result.rows[0]
    return {
      ...row,
      createdAt: row.createdAt.toISOString(),
      updatedAt: row.updatedAt.toISOString(),
      dueDate: row.dueDate ? row.dueDate.toISOString() : undefined,
    }
  }

  async create(taskData: CreateTaskRequest): Promise<Task> {
    const result = await query(`
      INSERT INTO tasks (title, description, priority, due_date)
      VALUES ($1, $2, $3, $4)
      RETURNING 
        id,
        title,
        description,
        completed,
        priority,
        due_date as "dueDate",
        created_at as "createdAt",
        updated_at as "updatedAt"
    `, [
      taskData.title,
      taskData.description || null,
      taskData.priority || 'medium',
      taskData.dueDate ? new Date(taskData.dueDate) : null
    ])

    const row = result.rows[0]
    logger.info(`Created task: ${row.id} - ${row.title}`)

    return {
      ...row,
      createdAt: row.createdAt.toISOString(),
      updatedAt: row.updatedAt.toISOString(),
      dueDate: row.dueDate ? row.dueDate.toISOString() : undefined,
    }
  }

  async update(id: string, updates: UpdateTaskRequest): Promise<Task | null> {
    // Build dynamic update query
    const updateFields: string[] = []
    const values: any[] = []
    let paramCount = 1

    if (updates.title !== undefined) {
      updateFields.push(`title = $${paramCount}`)
      values.push(updates.title)
      paramCount++
    }

    if (updates.description !== undefined) {
      updateFields.push(`description = $${paramCount}`)
      values.push(updates.description || null)
      paramCount++
    }

    if (updates.completed !== undefined) {
      updateFields.push(`completed = $${paramCount}`)
      values.push(updates.completed)
      paramCount++
    }

    if (updates.priority !== undefined) {
      updateFields.push(`priority = $${paramCount}`)
      values.push(updates.priority)
      paramCount++
    }

    if (updates.dueDate !== undefined) {
      updateFields.push(`due_date = $${paramCount}`)
      values.push(updates.dueDate ? new Date(updates.dueDate) : null)
      paramCount++
    }

    if (updateFields.length === 0) {
      // No fields to update, return existing task
      return this.findById(id)
    }

    values.push(id) // Add ID as the last parameter

    const result = await query(`
      UPDATE tasks 
      SET ${updateFields.join(', ')}
      WHERE id = $${paramCount}
      RETURNING 
        id,
        title,
        description,
        completed,
        priority,
        due_date as "dueDate",
        created_at as "createdAt",
        updated_at as "updatedAt"
    `, values)

    if (result.rows.length === 0) {
      return null
    }

    const row = result.rows[0]
    logger.info(`Updated task: ${row.id} - ${row.title}`)

    return {
      ...row,
      createdAt: row.createdAt.toISOString(),
      updatedAt: row.updatedAt.toISOString(),
      dueDate: row.dueDate ? row.dueDate.toISOString() : undefined,
    }
  }

  async delete(id: string): Promise<boolean> {
    const result = await query('DELETE FROM tasks WHERE id = $1', [id])
    const deleted = (result.rowCount || 0) > 0
    
    if (deleted) {
      logger.info(`Deleted task: ${id}`)
    }
    
    return deleted
  }

  async getStats(): Promise<{ total: number; completed: number; pending: number }> {
    const result = await query(`
      SELECT 
        COUNT(*) as total,
        COUNT(*) FILTER (WHERE completed = true) as completed,
        COUNT(*) FILTER (WHERE completed = false) as pending
      FROM tasks
    `)

    const row = result.rows[0]
    return {
      total: parseInt(row.total),
      completed: parseInt(row.completed),
      pending: parseInt(row.pending),
    }
  }
}

export const taskRepository = new TaskRepository()