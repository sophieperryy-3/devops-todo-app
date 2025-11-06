import { Task, CreateTaskRequest, UpdateTaskRequest } from '../types'
import { taskRepository } from '../repositories/taskRepository'
import { logger } from '../utils/logger'

export const taskService = {
  async getAllTasks(): Promise<Task[]> {
    const tasks = await taskRepository.findAll()
    logger.info(`Retrieved ${tasks.length} tasks from database`)
    return tasks
  },

  async getTaskById(id: string): Promise<Task | null> {
    const task = await taskRepository.findById(id)
    logger.info(`Retrieved task by ID ${id}: ${task ? 'found' : 'not found'}`)
    return task
  },

  async createTask(taskData: CreateTaskRequest): Promise<Task> {
    const task = await taskRepository.create(taskData)
    logger.info(`Created new task: ${task.id} - ${task.title}`)
    return task
  },

  async updateTask(id: string, updates: UpdateTaskRequest): Promise<Task | null> {
    const task = await taskRepository.update(id, updates)
    if (task) {
      logger.info(`Updated task: ${id} - ${task.title}`)
    } else {
      logger.warn(`Task not found for update: ${id}`)
    }
    return task
  },

  async deleteTask(id: string): Promise<boolean> {
    const deleted = await taskRepository.delete(id)
    logger.info(`Delete task ${id}: ${deleted ? 'success' : 'not found'}`)
    return deleted
  },

  async getTaskStats(): Promise<{ total: number; completed: number; pending: number }> {
    const stats = await taskRepository.getStats()
    logger.info('Retrieved task statistics', stats)
    return stats
  },
}