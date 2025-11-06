import React from 'react'
import { Task } from '../types'
import TaskItem from './TaskItem'

interface TaskListProps {
  tasks: Task[]
  onToggleTask: (taskId: string, completed: boolean) => void
  onDeleteTask: (taskId: string) => void
}

const TaskList: React.FC<TaskListProps> = ({ tasks, onToggleTask, onDeleteTask }) => {
  if (tasks.length === 0) {
    return (
      <div className="empty-state">
        <h3>No tasks yet</h3>
        <p>Add your first task above to get started!</p>
      </div>
    )
  }

  // Sort tasks: incomplete first, then by priority, then by creation date
  const sortedTasks = [...tasks].sort((a, b) => {
    // Incomplete tasks first
    if (a.completed !== b.completed) {
      return a.completed ? 1 : -1
    }
    
    // Then by priority (high > medium > low)
    const priorityOrder = { high: 3, medium: 2, low: 1 }
    if (a.priority !== b.priority) {
      return priorityOrder[b.priority] - priorityOrder[a.priority]
    }
    
    // Finally by creation date (newest first)
    return new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime()
  })

  return (
    <div>
      <h3 style={{ marginBottom: '1rem', color: '#2c3e50' }}>
        Tasks ({tasks.filter(t => !t.completed).length} active, {tasks.filter(t => t.completed).length} completed)
      </h3>
      <ul className="todo-list">
        {sortedTasks.map(task => (
          <TaskItem
            key={task.id}
            task={task}
            onToggle={onToggleTask}
            onDelete={onDeleteTask}
          />
        ))}
      </ul>
    </div>
  )
}

export default TaskList