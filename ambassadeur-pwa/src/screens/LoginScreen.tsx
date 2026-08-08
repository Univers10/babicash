import { useState, type FormEvent } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { useAuth } from '../auth/AuthContext'
import { IconEye, IconEyeOff, IconMail } from '../components/icons'

export default function LoginScreen() {
  const { login } = useAuth()
  const navigate = useNavigate()
  const [email, setEmail] = useState('')
  const [mdp, setMdp] = useState('')
  const [showMdp, setShowMdp] = useState(false)
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
        <div className="spacer" style={{ flex: 0.6 }} />
        <div className="brand">
          <img className="logo" src="/icon.svg" alt="" />
          <h1>Espace Ambassadeur</h1>
          <p>Parraine, suis tes filleuls, encaisse tes commissions.</p>
        </div>

        <form onSubmit={submit}>
          {error && <div className="form-error">{error}</div>}
          <div className="field">
            <label>Email</label>
            <div className="input-wrap">
              <input
                className="input"
                style={{ paddingLeft: 40 }}
                type="email"
                inputMode="email"
                autoComplete="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
              />
              <span
                style={{
                  position: 'absolute',
                  left: 14,
                  top: '50%',
                  transform: 'translateY(-50%)',
                  color: 'var(--text-tertiary)',
                }}
              >
                <IconMail width={17} height={17} />
              </span>
            </div>
          </div>
          <div className="field">
            <label>Mot de passe</label>
            <div className="input-wrap">
              <input
                className="input"
                type={showMdp ? 'text' : 'password'}
                autoComplete="current-password"
                value={mdp}
                onChange={(e) => setMdp(e.target.value)}
                required
              />
              <button
                type="button"
                className="input-suffix-btn"
                onClick={() => setShowMdp((v) => !v)}
                aria-label={showMdp ? 'Masquer le mot de passe' : 'Afficher le mot de passe'}
              >
                {showMdp ? <IconEyeOff width={18} height={18} /> : <IconEye width={18} height={18} />}
              </button>
            </div>
          </div>
          <button className="btn btn--primary btn--block" disabled={loading} style={{ marginTop: 6 }}>
            {loading ? 'Connexion…' : 'Se connecter'}
          </button>
        </form>

        <div className="spacer" />

        <div className="auth-footer">
          Pas encore ambassadeur ? <Link to="/register">Créer un compte</Link>
        </div>
      </div>
    </div>
  )
}
