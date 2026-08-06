import { useState } from 'react'
import { useAuth } from '../auth/AuthContext'
import { useAsync } from '../hooks/useAsync'
import { getCommissions, getMonEspace } from '../api/ambassadeur'
import {
  Avatar,
  EmptyState,
  ErrorState,
  Loading,
  formatDate,
  formatFcfa,
} from '../components/ui'

export default function HomeScreen() {
  const { session } = useAuth()
  const espace = useAsync(getMonEspace)
  const activite = useAsync(getCommissions)
  const [toast, setToast] = useState<string>()

  function showToast(m: string) {
    setToast(m)
    setTimeout(() => setToast(undefined), 1600)
  }

  async function copier(code: string) {
    try {
      await navigator.clipboard.writeText(code)
      showToast('Code copié !')
    } catch {
      /* clipboard indisponible */
    }
  }

  async function partager(code: string) {
    const text = `Rejoins BabiCash avec mon code parrain ${code} 🚀`
    if (navigator.share) {
      try {
        await navigator.share({ title: 'BabiCash', text })
      } catch {
        /* partage annulé */
      }
    } else {
      copier(code)
    }
  }

  if (espace.loading)
    return (
      <div className="screen">
        <Loading />
      </div>
    )
  if (espace.error || !espace.data)
    return (
      <div className="screen">
        <ErrorState message={espace.error} onRetry={espace.reload} />
      </div>
    )

  const e = espace.data
  const commissions = activite.data ?? []

  return (
    <div className="screen">
      <div className="topbar">
        <div>
          <p className="greeting">Bonjour</p>
          <h1>{session?.nom || e.nom}</h1>
        </div>
      </div>

      <div className="hero">
        <p className="label">Commission à recevoir</p>
        <p className="amount">{formatFcfa(e.solde_a_recevoir)}</p>
        <p className="sub">Total gagné à vie : {formatFcfa(e.total_gagne)}</p>
      </div>

      <div className="card code-card">
        <div>
          <div className="li-sub">Ton code de parrainage</div>
          <div className="code-value">{e.code}</div>
        </div>
        <div className="code-actions">
          <button className="icon-btn" onClick={() => copier(e.code)} aria-label="Copier">
            <svg width="20" height="20" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={2}
                d="M8 16H6a2 2 0 01-2-2V6a2 2 0 012-2h8a2 2 0 012 2v2m-6 12h8a2 2 0 002-2v-8a2 2 0 00-2-2h-8a2 2 0 00-2 2v8a2 2 0 002 2z"
              />
            </svg>
          </button>
          <button className="icon-btn" onClick={() => partager(e.code)} aria-label="Partager">
            <svg width="20" height="20" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={2}
                d="M8.684 13.342C8.886 12.938 9 12.482 9 12c0-.482-.114-.938-.316-1.342m0 2.684a3 3 0 110-2.684m0 2.684l6.632 3.316m-6.632-6l6.632-3.316m0 0a3 3 0 105.367-2.684 3 3 0 00-5.367 2.684zm0 9.316a3 3 0 105.368 2.684 3 3 0 00-5.368-2.684z"
              />
            </svg>
          </button>
        </div>
      </div>

      <div className="stat-row">
        <div className="stat">
          <div className="num">{e.nb_filleuls}</div>
          <div className="cap">Filleuls</div>
        </div>
        <div className="stat">
          <div className="num">{e.nb_filleuls_payants}</div>
          <div className="cap">Filleuls payants</div>
        </div>
      </div>

      <div className="section-title">Activité récente</div>
      <div className="card">
        {activite.loading ? (
          <Loading />
        ) : commissions.length === 0 ? (
          <EmptyState
            emoji="🌱"
            title="Rien pour l'instant"
            subtitle="Partage ton code pour gagner tes premières commissions."
          />
        ) : (
          <div className="list">
            {commissions.slice(0, 5).map((c) => (
              <div className="list-item" key={c.id}>
                <Avatar nom={c.filleul_nom} />
                <div className="li-body">
                  <div className="li-title">{c.filleul_nom}</div>
                  <div className="li-sub">{formatDate(c.date_creation)}</div>
                </div>
                <div className="li-amount">+{formatFcfa(c.montant_commission)}</div>
              </div>
            ))}
          </div>
        )}
      </div>

      {toast && <div className="toast">{toast}</div>}
    </div>
  )
}
