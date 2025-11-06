import { Request, Response, NextFunction } from 'express'
import Joi from 'joi'
import { createError } from './errorHandler'

const taskSchema = Joi.object({
  title: Joi.string().min(1).max(255).required().messages({
    'string.empty': 'Title is required',
    'string.max': 'Title must be less than 255 characters',
  }),
  description: Joi.string().max(1000).optional().allow('').messages({
    'string.max': 'Description must be less than 1000 characters',
  }),
  priority: Joi.string().valid('low', 'medium', 'high').default('medium'),
  dueDate: Joi.date().iso().optional().allow(null),
})

const taskUpdateSchema = Joi.object({
  title: Joi.string().min(1).max(255).optional().messages({
    'string.empty': 'Title cannot be empty',
    'string.max': 'Title must be less than 255 characters',
  }),
  description: Joi.string().max(1000).optional().allow('').messages({
    'string.max': 'Description must be less than 1000 characters',
  }),
  completed: Joi.boolean().optional(),
  priority: Joi.string().valid('low', 'medium', 'high').optional(),
  dueDate: Joi.date().iso().optional().allow(null),
}).min(1) // At least one field must be provided

export const validateTask = (req: Request, res: Response, next: NextFunction) => {
  const { error, value } = taskSchema.validate(req.body, { 
    abortEarly: false,
    stripUnknown: true,
  })

  if (error) {
    const errorMessage = error.details.map(detail => detail.message).join(', ')
    return next(createError(errorMessage, 400, 'VALIDATION_ERROR'))
  }

  req.body = value
  next()
}

export const validateTaskUpdate = (req: Request, res: Response, next: NextFunction) => {
  const { error, value } = taskUpdateSchema.validate(req.body, { 
    abortEarly: false,
    stripUnknown: true,
  })

  if (error) {
    const errorMessage = error.details.map(detail => detail.message).join(', ')
    return next(createError(errorMessage, 400, 'VALIDATION_ERROR'))
  }

  req.body = value
  next()
}

export const validateUUID = (req: Request, res: Response, next: NextFunction) => {
  const uuidSchema = Joi.string().uuid().required()
  const { error } = uuidSchema.validate(req.params.id)

  if (error) {
    return next(createError('Invalid task ID format', 400, 'INVALID_ID'))
  }

  next()
}