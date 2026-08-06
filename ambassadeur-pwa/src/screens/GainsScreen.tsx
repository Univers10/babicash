import { useAsync } from '../hooks/useAsync'
import { getCommissions, getVersements } from '../api/ambassadeur'
import {
  Avatar,
  EmptyState,
  ErrorState,
  Loading,
  StatusBadge,
  formatDate,
  formatFcfa,
} from '../components/ui'

export default function GainsScreen() {
  const commissions = useAsync(getCommissions)
  const versements = useAsync(getVersements)

  return (
    <div className="screen">
      <div className="topbar">
        <h1>Mes gains</h1>
      </div>

      <div className="section-title">Versements hebdomadaires</div>
      {versements.loading ? (
        <Loading />
      ) : versements.error ? (
        <ErrorState message={versements.error} onRetry={versements.reload} />
      ) : (versements.data ?? []).length === 0 ? (
        <div className="card">
          <EmptyState
            emoji="💸"
            title="Aucun versement"
            subtitle="Tes commissions validées sont regroupées et versées chaque semaine."
          />
        </div>
      ) : (
        <div className="card">
          <div className="list">
            {versements.data!.map((v) => (
              <div className="list-item" key={v.id}>
                <div className="li-body">
                  <div className="li-title">Semaine {v.semaine}</div>
                  <div className="li-sub">
                    {v.reference_transfert
                      ? `Réf. ${v.reference_transfert}`
                      : formatDate(v.date_creation)}
                  </div>
                </div>
                <div style={{ textAlign: 'right' }}>
                  <div className="li-amount">{formatFcfa(v.montant_total)}</div>
                  <div style={{ marginTop: 4 }}>
                    <StatusBadge statut={v.statut} />
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      <div className="section-title">Commissions</div>
      {commissions.loading ? (
        <Loading />
      ) : commissions.error ? (
        <ErrorState message={commissions.error} onRetry={commissions.reload} />
      ) : (commissions.data ?? []).length === 0 ? (
        <div className="card">
          <EmptyState emoji="🌱" title="Aucune commission" />
        </div>
      ) : (
        <div className="card">
          <div className="list">
            {commissions.data!.map((c) => (
              <div className="list-item" key={c.id}>
                <Avatar nom={c.filleul_nom} />
                <div className="li-body">
                  <div className="li-title">{c.filleul_nom}</div>
                  <div className="li-sub">
                    {formatDate(c.date_creation)} · sur {formatFcfa(c.montant_paye)}
                  </div>
                </div>
                <div style={{ textAlign: 'right' }}>
                  <div className="li-amount">+{formatFcfa(c.montant_commission)}</div>
                  <div style={{ marginTop: 4 }}>
                    <StatusBadge statut={c.statut} />
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  )
}
