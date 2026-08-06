import { Navigate, Route, Routes } from 'react-router-dom'
import type { ReactNode } from 'react'
import { useAuth } from './auth/AuthContext'
import BottomNav from './components/BottomNav'
import LoginScreen from './screens/LoginScreen'
import RegisterScreen from './screens/RegisterScreen'
import HomeScreen from './screens/HomeScreen'
import FilleulsScreen from './screens/FilleulsScreen'
import GainsScreen from './screens/GainsScreen'
import ProfilScreen from './screens/ProfilScreen'

function Shell({ children }: { children: ReactNode }) {
  const { session } = useAuth()
  if (!session) return <Navigate to="/login" replace />
  return (
    <div className="app-shell">
      {children}
      <BottomNav />
    </div>
  )
}

export default function App() {
  const { session } = useAuth()
  return (
    <Routes>
      <Route
        path="/login"
        element={session ? <Navigate to="/" replace /> : <LoginScreen />}
      />
      <Route
        path="/register"
        element={session ? <Navigate to="/" replace /> : <RegisterScreen />}
      />
      <Route
        path="/"
        element={
          <Shell>
            <HomeScreen />
          </Shell>
        }
      />
      <Route
        path="/filleuls"
        element={
          <Shell>
            <FilleulsScreen />
          </Shell>
        }
      />
      <Route
        path="/gains"
        element={
          <Shell>
            <GainsScreen />
          </Shell>
        }
      />
      <Route
        path="/profil"
        element={
          <Shell>
            <ProfilScreen />
          </Shell>
        }
      />
      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  )
}
