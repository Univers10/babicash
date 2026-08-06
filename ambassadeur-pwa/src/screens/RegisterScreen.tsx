import { useEffect, useState, type FormEvent } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { useAuth } from '../auth/AuthContext'
import { checkCode } from '../api/ambassadeur'
import type { Operateur } from '../api/types'

const OPERATEURS: Operateur[] = ['WAVE', 'ORANGE', 'MTN', 'MOOV']
const RAISONS: Record<string, string> = {
  format: 'Format invalide : 4 à 20 lettres ou chiffres.',
  reserve: 'Ce code est réservé.',
  pris: 'Ce code est déjà pris.',
}

interface CodeState {
  loading: boolean
  ok?: boolean
  raison?: string | null
}

export default function RegisterScreen() {
  const { register } = useAuth()
  const navigate = useNavigate()

  const [nom, setNom] = useState('')
  const [email, setEmail] = useState('')
  const [mdp, setMdp] = useState('')
  const [tel, setTel] = useState('')
  const [code, setCode] = useState('')
  const [momo, setMomo] = useState('')
  const [op, setOp] = useState<Operateur>('WAVE')

  const [codeState, setCodeState] = useState<CodeState>({ loading: false })
  const [error, setError] = useState<string>()
  const [loading, setLoading] = useState(false)

  const codeNorm = code.trim().toUpperCase()

  useEffect(() => {
    if (codeNorm.length < 4) {
      setCodeState({ loading: false })
      return
    }
    setCodeState({ loading: true })
    const t = setTimeout(async () => {
      try {
        const r = await checkCode(codeNorm)
        setCodeState({ loading: false, ok: r.disponible, raison: r.raison })
      } catch {
        setCodeState({ loading: false })
      }
    }, 400)
    return () => clearTimeout(t)
  }, [codeNorm])

  async function submit(e: FormEvent) {
    e.preventDefault()
    setError(undefined)
    setLoading(true)
    try {
      await register({
        nom: nom.trim(),
        email: email.trim(),
        mot_de_passe: mdp,
        telephone: tel.trim() || null,
        code: codeNorm,
        momo_numero: momo.trim(),
        momo_operateur: op,
      })
      navigate('/', { replace: true })
    } catch (err) {
      setError((err as Error)?.message ?? 'Inscription impossible')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="app-shell">
      <div className="screen--auth">
        <div className="brand">
          <img className="logo" src="/icon.svg" alt="" />
          <h1>Devenir ambassadeur</h1>
          <p>Choisis ton code et commence à parrainer.</p>
        </div>

        <form onSubmit={submit}>
          {error && <div className="form-error">{error}</div>}

          <div className="field">
            <label>Nom complet</label>
            <input className="input" value={nom} onChange={(e) => setNom(e.target.value)} required />
          </div>
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
              autoComplete="new-password"
              minLength={6}
              value={mdp}
              onChange={(e) => setMdp(e.target.value)}
              required
            />
          </div>
          <div className="field">
            <label>Téléphone (facultatif)</label>
            <input
              className="input"
              inputMode="tel"
              value={tel}
              onChange={(e) => setTel(e.target.value)}
            />
          </div>

          <div className="field">
            <label>Ton code de parrainage</label>
            <input
              className="input"
              value={code}
              onChange={(e) => setCode(e.target.value)}
              placeholder="ex. KOUASSI7"
              autoCapitalize="characters"
              maxLength={20}
              required
              style={{ textTransform: 'uppercase', letterSpacing: 1 }}
            />
            {codeNorm.length >= 4 && (
              <div
                className={
                  'hint ' +
                  (codeState.loading ? '' : codeState.ok ? 'hint--ok' : 'hint--ko')
                }
              >
                {codeState.loading
                  ? 'Vérification…'
                  : codeState.ok
                    ? '✅ Ce code est disponible'
                    : '❌ ' + (RAISONS[codeState.raison ?? ''] ?? 'Indisponible')}
              </div>
            )}
          </div>

          <div className="field">
            <label>Numéro Mobile Money (versements)</label>
            <input
              className="input"
              inputMode="tel"
              value={momo}
              onChange={(e) => setMomo(e.target.value)}
              required
            />
          </div>
          <div className="field">
            <label>Opérateur</label>
            <select
              className="select"
              value={op}
              onChange={(e) => setOp(e.target.value as Operateur)}
            >
              {OPERATEURS.map((o) => (
                <option key={o} value={o}>
                  {o}
                </option>
              ))}
            </select>
          </div>

          <button
            className="btn btn--primary btn--block"
            disabled={loading || (codeNorm.length >= 4 && codeState.ok === false)}
          >
            {loading ? 'Création…' : 'Créer mon compte'}
          </button>
        </form>

        <div className="auth-footer">
          Déjà un compte ? <Link to="/login">Se connecter</Link>
        </div>
      </div>
    </div>
  )
}
