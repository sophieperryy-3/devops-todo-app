import axios from 'axios'
import { Task, CreateTaskRequest, UpdateTaskRequest, ApiResponse } from '../types'

const API_BASE_URL = (import.meta as any).env?.VITE_API_URL || 'http://localhost:3001'

const api = axios.create({
  baseURL: `${API_BASE_URL}/api`,
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
  },
})

// Request interceptor for logging
api.interceptors.request.use(
  (config) => {
    console.log(`API Request: ${config.method?.toUpperCase()} ${config.url}`)
    return config
  },
  (error) => {
    console.error('API Request Error:', error)
    return Promise.reject(error)
  }
)

// Response interceptor for error handling
api.interceptors.response.use(
  (response) => {
    console.log(`API Response: ${response.status} ${response.config.url}`)
    return response
  },
  (error) => {
    console.error('API Response Error:', error)
    
    if (error.response) {
      // Server responded with error status
      const message = error.response.data?.error?.message || error.response.data?.message || 'Server error'
      throw new Error(message)
    } else if (error.request) {
      // Request was made but no response received
      throw new Error('Network error - please check your connection')
    } else {
      // Something else happened
      throw new Error(error.message || 'An unexpected error occurred')
    }
  }
)

export const taskService = {
  async getTasks(): Promise<ApiResponse<Task[]>> {
    const response = await api.get<ApiResponse<Task[]>>('/tasks')
    return response.data
  },

  async getTask(id: string): Promise<ApiResponse<Task>> {
    const response = await api.get<ApiResponse<Task>>(`/tasks/${id}`)
    return response.data
  },

  async createTask(task: CreateTaskRequest): Promise<ApiResponse<Task>> {
    const response = await api.post<ApiResponse<Task>>('/tasks', task)
    return response.data
  },

  async updateTask(id: string, updates: UpdateTaskRequest): Promise<ApiResponse<Task>> {
    const response = await api.put<ApiResponse<Task>>(`/tasks/${id}`, updates)
    return response.data
  },

  async deleteTask(id: string): Promise<ApiResponse<void>> {
    const response = await api.delete<ApiResponse<void>>(`/tasks/${id}`)
    return response.data
  },

  async getHealth(): Promise<{ status: string; timestamp: string }> {
    const response = await api.get('/health')
    return response.data
  },
}