import { v4 as uuidv4 } from 'uuid'
import { Task, CreateTaskRequest, UpdateTaskRequest } from '../types'
import { logger } from '../utils/logger'

// In-memory storage for demo (fallback when database not available)
let tasks: Task[] = [
  {
    id: uuidv4(),
    title: 'Welcome to DevOps Todo App!',
    description: 'This is a demo task showing the application works',
    completed: false,
    priority: 'high',
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  },
  {
    id: uuidv4(),
    title: 'CI/CD Pipeline Working',
    description: 'All stages passed with green checkmarks',
    completed: true,
    priority: 'high',
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  },
  {
    id: uuidv4(),
    title: 'Infrastructure as Code Ready',
    description: 'Terraform configuration validated successfully',
    completed: true,
    priority: 'medium',
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  },
]

export const taskService = {
  async getAllTasks(): Promise<Task[]> {
    logger.info(`Retrieved ${tasks.length} tasks`)
    return [...tasks]
  },

  async getTaskById(id: string): Promise<Task | null> {
    const task = tasks.find(t => t.id === id)
    logger.info(`Retrieved task by ID ${id}: ${task ? 'found' : 'not found'}`)
    return task || null
  },

  async createTask(taskData: CreateTaskRequest): Promise<Task> {
    const now = new Date().toISOString()
    const newTask: Task = {
      id: uuidv4(),
      title: taskData.title,
      description: taskData.description,
      completed: false,
      priority: taskData.priority || 'medium',
      dueDate: taskData.dueDate,
      createdAt: now,
      updatedAt: now,
    }
    tasks.unshift(newTask)
    logger.info(`Created new task: ${newTask.id} - ${newTask.title}`)
    return newTask
  },

  async updateTask(id: string, updates: UpdateTaskRequest): Promise<Task | null> {
    const taskIndex = tasks.findIndex(t => t.id === id)
    if (taskIndex === -1) {
      logger.warn(`Task not found for update: ${id}`)
      return null
    }
    
    const updatedTask: Task = {
      ...tasks[taskIndex],
      ...updates,
      updatedAt: new Date().toISOString(),
    }
    tasks[taskIndex] = updatedTask
    logger.info(`Updated task: ${id} - ${updatedTask.title}`)
    return updatedTask
  },

  async deleteTask(id: string): Promise<boolean> {
    const initialLength = tasks.length
    tasks = tasks.filter(t => t.id !== id)
    const deleted = tasks.length < initialLength
    logger.info(`Delete task ${id}: ${deleted ? 'success' : 'not found'}`)
    return deleted
  },

  async getTaskStats(): Promise<{ total: number; completed: number; pending: number }> {
    const stats = {
      total: tasks.length,
      completed: tasks.filter(t => t.completed).length,
      pending: tasks.filter(t => !t.completed).length,
    }
    logger.info('Retrieved task statistics', stats)
    return stats
  },
}