import React, { useState, useEffect } from 'react'
import { toast } from 'react-hot-toast'
import { Task, CreateTaskRequest } from '../types'
import TaskList from './TaskList'
import AddTaskForm from './AddTaskForm'
import { taskService } from '../services/taskService'

const TodoApp: React.FC = () => {
  const [tasks, setTasks] = useState<Task[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    loadTasks()
  }, [])

  const loadTasks = async () => {
    try {
      setLoading(true)
      setError(null)
      const response = await taskService.getTasks()
      setTasks(response.data)
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Failed to load tasks'
      setError(errorMessage)
      toast.error(errorMessage)
    } finally {
      setLoading(false)
    }
  }

  const handleAddTask = async (taskData: CreateTaskRequest) => {
    try {
      const response = await taskService.createTask(taskData)
      setTasks(prev => [response.data, ...prev])
      toast.success('Task created successfully!')
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Failed to create task'
      toast.error(errorMessage)
      throw err
    }
  }

  const handleToggleTask = async (taskId: string, completed: boolean) => {
    try {
      const response = await taskService.updateTask(taskId, { completed })
      setTasks(prev => 
        prev.map(task => 
          task.id === taskId ? response.data : task
        )
      )
      toast.success(completed ? 'Task completed!' : 'Task reopened!')
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Failed to update task'
      toast.error(errorMessage)
    }
  }

  const handleDeleteTask = async (taskId: string) => {
    try {
      await taskService.deleteTask(taskId)
      setTasks(prev => prev.filter(task => task.id !== taskId))
      toast.success('Task deleted successfully!')
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Failed to delete task'
      toast.error(errorMessage)
    }
  }

  if (loading) {
    return (
      <div className="todo-container">
        <div className="loading">Loading tasks...</div>
      </div>
    )
  }

  return (
    <div className="todo-container">
      <div className="todo-header">
        <h1>Interactive To-Do List</h1>
        <p>DevOps Demonstration Project</p>
      </div>

      {error && (
        <div className="error">
          <strong>Error:</strong> {error}
          <button 
            onClick={loadTasks}
            style={{ marginLeft: '1rem', padding: '0.25rem 0.5rem' }}
          >
            Retry
          </button>
        </div>
      )}

      <AddTaskForm onAddTask={handleAddTask} />
      
      <TaskList 
        tasks={tasks}
        onToggleTask={handleToggleTask}
        onDeleteTask={handleDeleteTask}
      />
    </div>
  )
}

export default TodoApp