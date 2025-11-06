import React from 'react'
import { Task } from '../types'
import { Trash2 } from 'lucide-react'

interface TaskItemProps {
  task: Task
  onToggle: (taskId: string, completed: boolean) => void
  onDelete: (taskId: string) => void
}

const TaskItem: React.FC<TaskItemProps> = ({ task, onToggle, onDelete }) => {
  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('en-US', {
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
    })
  }

  const handleToggle = () => {
    onToggle(task.id, !task.completed)
  }

  const handleDelete = () => {
    if (window.confirm('Are you sure you want to delete this task?')) {
      onDelete(task.id)
    }
  }

  return (
    <li className="todo-item">
      <input
        type="checkbox"
        checked={task.completed}
        onChange={handleToggle}
        className="todo-checkbox"
      />
      
      <div className="todo-content">
        <h4 className={`todo-title ${task.completed ? 'completed' : ''}`}>
          {task.title}
        </h4>
        {task.description && (
          <p className="todo-description">{task.description}</p>
        )}
        <div className="todo-meta">
          <span className={`priority-badge priority-${task.priority}`}>
            {task.priority}
          </span>
          <span>Created {formatDate(task.createdAt)}</span>
          {task.dueDate && (
            <span>Due {formatDate(task.dueDate)}</span>
          )}
        </div>
      </div>
      
      <div className="todo-actions">
        <button
          onClick={handleDelete}
          className="btn-sm btn-danger"
          title="Delete task"
        >
          <Trash2 size={14} />
        </button>
      </div>
    </li>
  )
}

export default TaskItem