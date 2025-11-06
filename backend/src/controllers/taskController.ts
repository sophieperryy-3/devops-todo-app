import { Request, Response, NextFunction } from 'express'
import { taskService } from '../services/taskService'
import { logger } from '../utils/logger'
import { createError } from '../middleware/errorHandler'

export const taskController = {
  async getAllTasks(req: Request, res: Response, next: NextFunction) {
    try {
      logger.info('Getting all tasks')
      const tasks = await taskService.getAllTasks()
      
      res.json({
        success: true,
        data: tasks,
        message: 'Tasks retrieved successfully',
      })
    } catch (error) {
      logger.error('Error getting all tasks:', error)
      next(error)
    }
  },

  async getTaskById(req: Request, res: Response, next: NextFunction) {
    try {
      const { id } = req.params
      logger.info(`Getting task by ID: ${id}`)
      
      const task = await taskService.getTaskById(id)
      
      if (!task) {
        return next(createError('Task not found', 404, 'TASK_NOT_FOUND'))
      }

      res.json({
        success: true,
        data: task,
        message: 'Task retrieved successfully',
      })
    } catch (error) {
      logger.error(`Error getting task by ID ${req.params.id}:`, error)
      next(error)
    }
  },

  async createTask(req: Request, res: Response, next: NextFunction) {
    try {
      const taskData = req.body
      logger.info('Creating new task:', { title: taskData.title })
      
      const task = await taskService.createTask(taskData)
      
      res.status(201).json({
        success: true,
        data: task,
        message: 'Task created successfully',
      })
    } catch (error) {
      logger.error('Error creating task:', error)
      next(error)
    }
  },

  async updateTask(req: Request, res: Response, next: NextFunction) {
    try {
      const { id } = req.params
      const updates = req.body
      logger.info(`Updating task ${id}:`, updates)
      
      const task = await taskService.updateTask(id, updates)
      
      if (!task) {
        return next(createError('Task not found', 404, 'TASK_NOT_FOUND'))
      }

      res.json({
        success: true,
        data: task,
        message: 'Task updated successfully',
      })
    } catch (error) {
      logger.error(`Error updating task ${req.params.id}:`, error)
      next(error)
    }
  },

  async deleteTask(req: Request, res: Response, next: NextFunction) {
    try {
      const { id } = req.params
      logger.info(`Deleting task: ${id}`)
      
      const deleted = await taskService.deleteTask(id)
      
      if (!deleted) {
        return next(createError('Task not found', 404, 'TASK_NOT_FOUND'))
      }

      res.json({
        success: true,
        data: null,
        message: 'Task deleted successfully',
      })
    } catch (error) {
      logger.error(`Error deleting task ${req.params.id}:`, error)
      next(error)
    }
  },
}