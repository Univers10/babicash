import { useState } from 'react'
import { Link } from 'react-router-dom'
import { useAuth } from '../auth/AuthContext'
import { useAsync } from '../hooks/useAsync'
import { getCommissions, getMonEspace } from '../api/ambassadeur'
import {
  Avatar,
  Card,
  EmptyState,
  ErrorState,
  SkeletonHero,
  SkeletonList,
  formatDate,
  formatFcfa,
} from '../components/ui'
import { IconCopy, IconGift, IconShare, IconUsers, IconWallet } from '../components/icons'

function heureDuJour(): string {
  const h = new Date().getHours()
  if (h < 12) return 'Bonjour'
  if (h < 18) return 'Bon après-midi'
  return 'Bonsoir'
}

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
    const text = `Rejoins BabiCash avec mon code parrain ${code} et gère ta boutique comme un pro 🚀`
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

  const prenom = (session?.nom || '').split(' ')[0] || 'Ambassadeur'

  if (espace.loading)
    return (
      <div className="screen">
        <div className="topbar">
          <div>
            <p className="greeting">{heureDuJour()}</p>
            <h1>{prenom}</h1>
          </div>
        </div>
        <SkeletonHero />
        <div style={{ marginTop: 22 }}>
          <SkeletonList rows={3} />
        </div>
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
          <p className="greeting">{heureDuJour()}</p>
          <h1>{prenom}</h1>
        </div>
        <Avatar nom={session?.nom || e.nom} />
      </div>

      <div className="hero">
        <div className="hero-top">
          <span className="label">
            <IconWallet width={15} height={15} /> Commission à recevoir
          </span>
          {!e.actif && <span className="hero-pill">Compte désactivé</span>}
        </div>
        <p className="amount">{formatFcfa(e.solde_a_recevoir)}</p>
        <p className="sub">Total gagné à vie · {formatFcfa(e.total_gagne)}</p>

        <div className="hero-actions">
          <button className="hero-action" onClick={() => copier(e.code)}>
            <IconCopy width={16} height={16} /> Copier
          </button>
          <button className="hero-action hero-action--solid" onClick={() => partager(e.code)}>
            <IconShare width={16} height={16} /> Partager
          </button>
        </div>
      </div>

      <div className="code-card">
        <div>
          <div className="li-sub">Ton code de parrainage</div>
          <div className="code-value">{e.code}</div>
        </div>
        <div className="code-actions">
          <button className="icon-btn" onClick={() => copier(e.code)} aria-label="Copier">
            <IconCopy />
          </button>
          <button className="icon-btn" onClick={() => partager(e.code)} aria-label="Partager">
            <IconShare />
          </button>
        </div>
      </div>

      <div className="stat-row">
        <div className="stat">
          <span className="stat-icon">
            <IconUsers width={18} height={18} />
          </span>
          <div>
            <div className="num">{e.nb_filleuls}</div>
            <div className="cap">Filleuls</div>
          </div>
        </div>
        <div className="stat">
          <span className="stat-icon">
            <IconGift width={18} height={18} />
          </span>
          <div>
            <div className="num">{e.nb_filleuls_payants}</div>
            <div className="cap">Filleuls payants</div>
          </div>
        </div>
      </div>

      <div className="section-title">
        <span>Activité récente</span>
        {commissions.length > 0 && (
          <Link className="link" to="/gains">
            Voir tout
          </Link>
        )}
      </div>
      {activite.loading ? (
        <SkeletonList rows={3} />
      ) : commissions.length === 0 ? (
        <Card>
          <EmptyState
            emoji="🌱"
            title="Rien pour l'instant"
            subtitle="Partage ton code pour gagner tes premières commissions."
          />
        </Card>
      ) : (
        <Card>
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
        </Card>
      )}

      {toast && <div className="toast">{toast}</div>}
    </div>
  )
}
