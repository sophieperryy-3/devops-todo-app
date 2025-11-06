import React, { useState } from 'react'
import { CreateTaskRequest } from '../types'

interface AddTaskFormProps {
  onAddTask: (task: CreateTaskRequest) => Promise<void>
}

const AddTaskForm: React.FC<AddTaskFormProps> = ({ onAddTask }) => {
  const [title, setTitle] = useState('')
  const [description, setDescription] = useState('')
  const [priority, setPriority] = useState<'low' | 'medium' | 'high'>('medium')
  const [isSubmitting, setIsSubmitting] = useState(false)

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    
    if (!title.trim()) {
      return
    }

    setIsSubmitting(true)
    
    try {
      await onAddTask({
        title: title.trim(),
        description: description.trim() || undefined,
        priority,
      })
      
      // Reset form
      setTitle('')
      setDescription('')
      setPriority('medium')
    } catch (err) {
      // Error handling is done in parent component
    } finally {
      setIsSubmitting(false)
    }
  }

  return (
    <form onSubmit={handleSubmit} className="todo-form">
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: '0.5rem' }}>
        <input
          type="text"
          value={title}
          onChange={(e) => setTitle(e.target.value)}
          placeholder="Enter task title..."
          className="todo-input"
          disabled={isSubmitting}
          required
        />
        <div style={{ display: 'flex', gap: '0.5rem' }}>
          <input
            type="text"
            value={description}
            onChange={(e) => setDescription(e.target.value)}
            placeholder="Description (optional)..."
            className="todo-input"
            disabled={isSubmitting}
            style={{ flex: 1 }}
          />
          <select
            value={priority}
            onChange={(e) => setPriority(e.target.value as 'low' | 'medium' | 'high')}
            className="todo-input"
            disabled={isSubmitting}
            style={{ width: 'auto' }}
          >
            <option value="low">Low Priority</option>
            <option value="medium">Medium Priority</option>
            <option value="high">High Priority</option>
          </select>
        </div>
      </div>
      <button
        type="submit"
        className="btn-primary"
        disabled={!title.trim() || isSubmitting}
      >
        {isSubmitting ? 'Adding...' : 'Add Task'}
      </button>
    </form>
  )
}

export default AddTaskForm