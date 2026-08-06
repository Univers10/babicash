import { useAsync } from '../hooks/useAsync'
import { getFilleuls } from '../api/ambassadeur'
import {
  Avatar,
  EmptyState,
  ErrorState,
  Loading,
  formatDate,
  formatFcfa,
} from '../components/ui'

export default function FilleulsScreen() {
  const { data, loading, error, reload } = useAsync(getFilleuls)
  const filleuls = data ?? []

  return (
    <div className="screen">
      <div className="topbar">
        <h1>Mes filleuls</h1>
      </div>

      {loading ? (
        <Loading />
      ) : error ? (
        <ErrorState message={error} onRetry={reload} />
      ) : filleuls.length === 0 ? (
        <EmptyState
          emoji="👥"
          title="Aucun filleul"
          subtitle="Partage ton code pour parrainer tes premiers commerçants."
        />
      ) : (
        <div className="card">
          <div className="list">
            {filleuls.map((f) => (
              <div className="list-item" key={f.filleul_id}>
                <Avatar nom={f.nom} />
                <div className="li-body">
                  <div className="li-title">{f.nom}</div>
                  <div className="li-sub">Inscrit le {formatDate(f.date_inscription)}</div>
                </div>
                <div style={{ textAlign: 'right' }}>
                  <span className={'badge' + (f.plan === 'FREE' ? ' badge--muted' : '')}>
                    {f.plan}
                  </span>
                  <div className="li-amount" style={{ marginTop: 4 }}>
                    {formatFcfa(f.commission_cumulee)}
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
