import { useState, type FormEvent } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { useAuth } from '../auth/AuthContext'

export default function LoginScreen() {
  const { login } = useAuth()
  const navigate = useNavigate()
  const [email, setEmail] = useState('')
  const [mdp, setMdp] = useState('')
  const [error, setError] = useState<string>()
  const [loading, setLoading] = useState(false)

  async function submit(e: FormEvent) {
    e.preventDefault()
    setError(undefined)
    setLoading(true)
    try {
      await login(email.trim(), mdp)
      navigate('/', { replace: true })
    } catch (err) {
      setError((err as Error)?.message ?? 'Connexion impossible')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="app-shell">
      <div className="screen--auth">
        <div className="brand">
          <img className="logo" src="/icon.svg" alt="" />
          <h1>Espace Ambassadeur</h1>
          <p>Parraine, suis tes filleuls, encaisse tes commissions.</p>
        </div>

        <form onSubmit={submit}>
          {error && <div className="form-error">{error}</div>}
          <div className="field">
            <label>Email</label>
            <input
              className="input"
              type="email"
              inputMode="email"
              autoComplete="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
            />
          </div>
          <div className="field">
            <label>Mot de passe</label>
            <input
              className="input"
              type="password"
              autoComplete="current-password"
              value={mdp}
              onChange={(e) => setMdp(e.target.value)}
              required
            />
          </div>
          <button className="btn btn--primary btn--block" disabled={loading}>
            {loading ? 'Connexion…' : 'Se connecter'}
          </button>
        </form>

        <div className="auth-footer">
          Pas encore ambassadeur ? <Link to="/register">Créer un compte</Link>
        </div>
      </div>
    </div>
  )
}
