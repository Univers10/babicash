import { useEffect, useState, type FormEvent } from 'react'
import { useAuth } from '../auth/AuthContext'
import { useAsync } from '../hooks/useAsync'
import { getMonEspace, updateMomo } from '../api/ambassadeur'
import { Avatar, Card, ErrorState, Loading } from '../components/ui'
import { IconChevronRight, IconLogout, IconMail, IconPhone, IconUser } from '../components/icons'
import type { Operateur } from '../api/types'

const OPERATEURS: Operateur[] = ['WAVE', 'ORANGE', 'MTN', 'MOOV']

export default function ProfilScreen() {
  const { logout } = useAuth()
  const { data, loading, error, reload } = useAsync(getMonEspace)

  const [numero, setNumero] = useState('')
  const [op, setOp] = useState<Operateur>('WAVE')
  const [saving, setSaving] = useState(false)
  const [toast, setToast] = useState<string>()
  const [confirmLogout, setConfirmLogout] = useState(false)

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

      <Card>
        <div style={{ display: 'flex', alignItems: 'center', gap: 14 }}>
          <Avatar nom={data.nom} />
          <div style={{ flex: 1, minWidth: 0 }}>
            <div className="li-title" style={{ fontSize: 17 }}>
              {data.nom}
            </div>
            <div className="li-sub">Ambassadeur BabiCash</div>
          </div>
          {data.actif ? (
            <span className="badge badge--success">Actif</span>
          ) : (
            <span className="badge badge--danger">Désactivé</span>
          )}
        </div>
      </Card>

      <div className="section-title">Compte</div>
      <Card>
        <div className="list">
          <div className="list-item">
            <span className="avatar avatar--icon">
              <IconMail width={17} height={17} />
            </span>
            <div className="li-body">
              <div className="li-sub">Email</div>
              <div className="li-title">{data.email ?? '—'}</div>
            </div>
          </div>
          <div className="list-item">
            <span className="avatar avatar--icon">
              <IconUser width={17} height={17} />
            </span>
            <div className="li-body">
              <div className="li-sub">Code de parrainage</div>
              <div className="code-value" style={{ fontSize: 17 }}>
                {data.code}
              </div>
            </div>
          </div>
        </div>
      </Card>

      <div className="section-title">Versement Mobile Money</div>
      <form className="card" onSubmit={save}>
        <div className="field">
          <label>Numéro Mobile Money</label>
          <div className="input-wrap">
            <input
              className="input"
              style={{ paddingLeft: 40 }}
              inputMode="tel"
              value={numero}
              onChange={(e) => setNumero(e.target.value)}
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
        <button className="btn btn--primary btn--block" style={{ marginTop: 16 }} disabled={saving}>
          {saving ? 'Enregistrement…' : 'Enregistrer'}
        </button>
      </form>

      <div className="section-title">Session</div>
      <Card tight>
        {!confirmLogout ? (
          <button
            className="list-item tappable"
            style={{
              width: '100%',
              border: 'none',
              background: 'none',
              textAlign: 'left',
            }}
            onClick={() => setConfirmLogout(true)}
          >
            <span className="avatar avatar--icon" style={{ background: 'var(--danger-container)', color: 'var(--danger)' }}>
              <IconLogout width={17} height={17} />
            </span>
            <div className="li-body">
              <div className="li-title" style={{ color: 'var(--danger)' }}>
                Se déconnecter
              </div>
            </div>
            <IconChevronRight width={17} height={17} style={{ color: 'var(--text-tertiary)' }} />
          </button>
        ) : (
          <div style={{ padding: 4 }}>
            <p style={{ fontSize: 13.5, color: 'var(--text-secondary)', margin: '4px 4px 12px' }}>
              Confirmer la déconnexion de l'espace ambassadeur ?
            </p>
            <div style={{ display: 'flex', gap: 8 }}>
              <button
                className="btn btn--outline btn--block btn--sm"
                onClick={() => setConfirmLogout(false)}
              >
                Annuler
              </button>
              <button className="btn btn--danger btn--block btn--sm" onClick={logout}>
                Déconnexion
              </button>
            </div>
          </div>
        )}
      </Card>

      {toast && <div className="toast">{toast}</div>}
    </div>
  )
}
