import { useEffect, useState, type FormEvent } from 'react'
import { useAuth } from '../auth/AuthContext'
import { useAsync } from '../hooks/useAsync'
import { getMonEspace, updateMomo } from '../api/ambassadeur'
import { ErrorState, Loading } from '../components/ui'
import type { Operateur } from '../api/types'

const OPERATEURS: Operateur[] = ['WAVE', 'ORANGE', 'MTN', 'MOOV']

export default function ProfilScreen() {
  const { logout } = useAuth()
  const { data, loading, error, reload } = useAsync(getMonEspace)

  const [numero, setNumero] = useState('')
  const [op, setOp] = useState<Operateur>('WAVE')
  const [saving, setSaving] = useState(false)
  const [toast, setToast] = useState<string>()

  useEffect(() => {
    if (data) {
      setNumero(data.momo_numero)
      setOp((data.momo_operateur as Operateur) || 'WAVE')
    }
  }, [data])

  function flash(m: string) {
    setToast(m)
    setTimeout(() => setToast(undefined), 1800)
  }

  async function save(e: FormEvent) {
    e.preventDefault()
    setSaving(true)
    try {
      await updateMomo(numero.trim(), op)
      flash('Coordonnées enregistrées')
    } catch (err) {
      flash((err as Error)?.message ?? 'Erreur')
    } finally {
      setSaving(false)
    }
  }

  if (loading)
    return (
      <div className="screen">
        <Loading />
      </div>
    )
  if (error || !data)
    return (
      <div className="screen">
        <ErrorState message={error} onRetry={reload} />
      </div>
    )

  return (
    <div className="screen">
      <div className="topbar">
        <h1>Profil</h1>
      </div>

      <div className="card stack">
        <div>
          <div className="li-sub">Nom</div>
          <div className="li-title">{data.nom}</div>
        </div>
        <div>
          <div className="li-sub">Email</div>
          <div className="li-title">{data.email ?? '—'}</div>
        </div>
        <div>
          <div className="li-sub">Code de parrainage</div>
          <div className="code-value">{data.code}</div>
        </div>
        <div>
          <div className="li-sub">Statut</div>
          <div>
            {data.actif ? (
              <span className="badge badge--success">Actif</span>
            ) : (
              <span className="badge badge--danger">Désactivé</span>
            )}
          </div>
        </div>
      </div>

      <div className="section-title">Versement Mobile Money</div>
      <form className="card" onSubmit={save}>
        <div className="field">
          <label>Numéro Mobile Money</label>
          <input
            className="input"
            inputMode="tel"
            value={numero}
            onChange={(e) => setNumero(e.target.value)}
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
        <button className="btn btn--primary btn--block" disabled={saving}>
          {saving ? 'Enregistrement…' : 'Enregistrer'}
        </button>
      </form>

      <button
        className="btn btn--danger btn--block"
        style={{ marginTop: 16 }}
        onClick={logout}
      >
        Se déconnecter
      </button>

      {toast && <div className="toast">{toast}</div>}
    </div>
  )
}
