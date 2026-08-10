import { Navigate, Route, Routes } from 'react-router-dom'
import type { ReactNode } from 'react'
import { useAuth } from './auth/AuthContext'
import BottomNav from './components/BottomNav'
import InstallBanner from './components/InstallBanner'
import LoginScreen from './screens/LoginScreen'
import RegisterScreen from './screens/RegisterScreen'
import HomeScreen from './screens/HomeScreen'
import FilleulsScreen from './screens/FilleulsScreen'
import GainsScreen from './screens/GainsScreen'
import NotificationsScreen from './screens/NotificationsScreen'
import ProfilScreen from './screens/ProfilScreen'
import TermsScreen from './screens/TermsScreen'

function Shell({ children }: { children: ReactNode }) {
  const { session } = useAuth()
  if (!session) return <Navigate to="/login" replace />
  return (
    <div className="app-shell">
      <InstallBanner />
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
      <Route path="/conditions-utilisation" element={<TermsScreen />} />
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
      <Route
        path="/notifications"
        element={
          <Shell>
            <NotificationsScreen />
          </Shell>
        }
      />
      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  )
}
