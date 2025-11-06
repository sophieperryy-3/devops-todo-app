import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom'
import App from '../App'

// Mock the TodoApp component
jest.mock('../components/TodoApp', () => {
  return function MockTodoApp() {
    return <div data-testid="todo-app">Todo App Component</div>
  }
})

describe('App Component', () => {
  it('renders without crashing', () => {
    render(<App />)
    expect(screen.getByTestId('todo-app')).toBeInTheDocument()
  })

  it('renders the TodoApp component', () => {
    render(<App />)
    expect(screen.getByText('Todo App Component')).toBeInTheDocument()
  })
})