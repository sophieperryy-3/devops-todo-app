import React from 'react'
import { Toaster } from 'react-hot-toast'
import TodoApp from './components/TodoApp'
import './App.css'

function App() {
  return (
    <div className="App">
      <Toaster position="top-right" />
      <TodoApp />
    </div>
  )
}

export default App