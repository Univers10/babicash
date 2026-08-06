import {
  createContext,
  useContext,
  useEffect,
  useMemo,
  useState,
  type ReactNode,
} from 'react'
import { api, setToken, setUnauthorizedHandler } from '../api/client'
import type { RegisterPayload, Token } from '../api/types'

interface Session {
  token: string
  nom: string
  role: string
  email: string | null
}

const SESSION_KEY = 'babicash_amb_session'

function loadSession(): Session | null {
  try {
    const raw = localStorage.getItem(SESSION_KEY)
    return raw ? (JSON.parse(raw) as Session) : null
  } catch {
    return null
  }
}

interface AuthContextValue {
  session: Session | null
  login: (email: string, motDePasse: string) => Promise<void>
  register: (payload: RegisterPayload) => Promise<void>
  logout: () => void
}

const AuthContext = createContext<AuthContextValue | null>(null)

export function AuthProvider({ children }: { children: ReactNode }) {
  const [session, setSession] = useState<Session | null>(() => loadSession())

  useEffect(() => {
    // Ré-aligne le token du client HTTP au rechargement.
    if (session) setToken(session.token)
    setUnauthorizedHandler(() => {
      localStorage.removeItem(SESSION_KEY)
      setSession(null)
    })
  }, [])

  function apply(tok: Token) {
    const next: Session = {
      token: tok.access_token,
      nom: tok.nom ?? '',
      role: tok.role,
      email: tok.email ?? null,
    }
    setToken(next.token)
    localStorage.setItem(SESSION_KEY, JSON.stringify(next))
    setSession(next)
  }

  const value = useMemo<AuthContextValue>(
    () => ({
      session,
      async login(email, motDePasse) {
        const tok = await api<Token>('/ambassadeurs/login', {
          method: 'POST',
          auth: false,
          body: { email, mot_de_passe: motDePasse },
        })
        apply(tok)
      },
      async register(payload) {
        const tok = await api<Token>('/ambassadeurs/register', {
          method: 'POST',
          auth: false,
          body: payload,
        })
        apply(tok)
      },
      logout() {
        setToken(null)
        localStorage.removeItem(SESSION_KEY)
        setSession(null)
      },
    }),
    [session],
  )

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>
}

export function useAuth(): AuthContextValue {
  const ctx = useContext(AuthContext)
  if (!ctx) throw new Error('useAuth doit être utilisé dans <AuthProvider>')
  return ctx
}
