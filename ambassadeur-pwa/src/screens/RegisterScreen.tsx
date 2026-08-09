import { useEffect, useState, type FormEvent } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { useAuth } from '../auth/AuthContext'
import { checkCode } from '../api/ambassadeur'
import type { Operateur } from '../api/types'
import {
  IconCheckCircle,
  IconEye,
  IconEyeOff,
  IconMail,
  IconPhone,
} from '../components/icons'

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
  const [showMdp, setShowMdp] = useState(false)
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
      <div className="screen--auth screen--scroll">
        <div className="brand">
          <img className="logo" src="/icon.svg" alt="" />
          <h1>Devenir ambassadeur</h1>
          <p>Choisis ton code et commence à parrainer.</p>
        </div>

        <form onSubmit={submit}>
          {error && <div className="form-error">{error}</div>}

          <div className="form-section-title">Informations personnelles</div>
          <div className="field">
            <label>Nom complet</label>
            <input className="input" value={nom} onChange={(e) => setNom(e.target.value)} required />
          </div>
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
                autoComplete="new-password"
                minLength={6}
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
          <div className="field">
            <label>Téléphone (facultatif)</label>
            <div className="input-wrap">
              <input
                className="input"
                style={{ paddingLeft: 40 }}
                inputMode="tel"
                value={tel}
                onChange={(e) => setTel(e.target.value)}
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
                <IconPhone width={17} height={17} />
              </span>
            </div>
          </div>

          <div className="form-section-title">Ton code de parrainage</div>
          <div className="field">
            <label>Choisis un code unique</label>
            <input
              className={'input' + (codeState.ok === false ? ' invalid' : '')}
              value={code}
              onChange={(e) => setCode(e.target.value)}
              placeholder="ex. KOUASSI7"
              autoCapitalize="characters"
              maxLength={20}
              required
              style={{ textTransform: 'uppercase', letterSpacing: 1, fontWeight: 700 }}
            />
            {codeNorm.length >= 4 && (
              <div className={'hint ' + (codeState.loading ? 'hint--loading' : codeState.ok ? 'hint--ok' : 'hint--ko')}>
                {codeState.loading ? (
                  'Vérification…'
                ) : codeState.ok ? (
                  <>
                    <IconCheckCircle width={14} height={14} /> Ce code est disponible
                  </>
                ) : (
                  RAISONS[codeState.raison ?? ''] ?? 'Indisponible'
                )}
              </div>
            )}
            <div className="field-hint">4 à 20 caractères, lettres et chiffres uniquement.</div>
          </div>

          <div className="form-section-title">Versement Mobile Money</div>
          <div className="field">
            <label>Numéro Mobile Money</label>
            <div className="input-wrap">
              <input
                className="input"
                style={{ paddingLeft: 40 }}
                inputMode="tel"
                value={momo}
                onChange={(e) => setMomo(e.target.value)}
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
                <IconPhone width={17} height={17} />
              </span>
            </div>
          </div>
          <div className="field" style={{ marginBottom: 6 }}>
            <label>Opérateur</label>
            <div className="chip-group">
              {OPERATEURS.map((o) => (
                <button
                  key={o}
                  type="button"
                  className={'chip-option' + (op === o ? ' active' : '')}
                  onClick={() => setOp(o)}
                >
                  {o}
                </button>
              ))}
            </div>
          </div>

          <button
            className="btn btn--primary btn--block"
            style={{ marginTop: 20 }}
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
