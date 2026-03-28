import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom'
import { AuthProvider } from './context/AuthContext'
import ProtectedRoute from './components/ProtectedRoute'
import Layout from './components/Layout'

import Login from './pages/Login'
import Dashboard from './pages/Dashboard'
import Books from './pages/Books'
import BookNew from './pages/BookNew'
import BookDetail from './pages/BookDetail'
import Writers from './pages/Writers'
import WriterNew from './pages/WriterNew'
import WriterDetail from './pages/WriterDetail'
import Earnings from './pages/Earnings'
import MyBooks from './pages/MyBooks'
import MyBookNew from './pages/MyBookNew'
import MyEarnings from './pages/MyEarnings'

function AppRoutes() {
  return (
    <Routes>
      {/* Public */}
      <Route path="/login" element={<Login />} />

      {/* Protected – any authenticated user */}
      <Route
        path="/"
        element={
          <ProtectedRoute>
            <Layout>
              <Dashboard />
            </Layout>
          </ProtectedRoute>
        }
      />

      {/* Admin only */}
      <Route
        path="/books"
        element={
          <ProtectedRoute allowedRoles={['admin']}>
            <Layout>
              <Books />
            </Layout>
          </ProtectedRoute>
        }
      />
      <Route
        path="/books/new"
        element={
          <ProtectedRoute allowedRoles={['admin']}>
            <Layout>
              <BookNew />
            </Layout>
          </ProtectedRoute>
        }
      />
      <Route
        path="/books/:id"
        element={
          <ProtectedRoute allowedRoles={['admin']}>
            <Layout>
              <BookDetail />
            </Layout>
          </ProtectedRoute>
        }
      />
      <Route
        path="/writers"
        element={
          <ProtectedRoute allowedRoles={['admin']}>
            <Layout>
              <Writers />
            </Layout>
          </ProtectedRoute>
        }
      />
      <Route
        path="/writers/new"
        element={
          <ProtectedRoute allowedRoles={['admin']}>
            <Layout>
              <WriterNew />
            </Layout>
          </ProtectedRoute>
        }
      />
      <Route
        path="/writers/:id"
        element={
          <ProtectedRoute allowedRoles={['admin']}>
            <Layout>
              <WriterDetail />
            </Layout>
          </ProtectedRoute>
        }
      />
      <Route
        path="/earnings"
        element={
          <ProtectedRoute allowedRoles={['admin']}>
            <Layout>
              <Earnings />
            </Layout>
          </ProtectedRoute>
        }
      />

      {/* Writer only */}
      <Route
        path="/my-books"
        element={
          <ProtectedRoute allowedRoles={['writer']}>
            <Layout>
              <MyBooks />
            </Layout>
          </ProtectedRoute>
        }
      />
      <Route
        path="/my-books/new"
        element={
          <ProtectedRoute allowedRoles={['writer']}>
            <Layout>
              <MyBookNew />
            </Layout>
          </ProtectedRoute>
        }
      />
      <Route
        path="/my-earnings"
        element={
          <ProtectedRoute allowedRoles={['writer']}>
            <Layout>
              <MyEarnings />
            </Layout>
          </ProtectedRoute>
        }
      />

      {/* Fallback */}
      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  )
}

export default function App() {
  return (
    <BrowserRouter>
      <AuthProvider>
        <AppRoutes />
      </AuthProvider>
    </BrowserRouter>
  )
}
