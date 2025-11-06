import { Router } from 'express'
import { taskController } from '../controllers/taskController'
import { validateTask, validateTaskUpdate, validateUUID } from '../middleware/validation'

const router = Router()

// GET /api/tasks - Get all tasks
router.get('/', taskController.getAllTasks)

// GET /api/tasks/:id - Get task by ID
router.get('/:id', validateUUID, taskController.getTaskById)

// POST /api/tasks - Create new task
router.post('/', validateTask, taskController.createTask)

// PUT /api/tasks/:id - Update task
router.put('/:id', validateUUID, validateTaskUpdate, taskController.updateTask)

// DELETE /api/tasks/:id - Delete task
router.delete('/:id', validateUUID, taskController.deleteTask)

export default router