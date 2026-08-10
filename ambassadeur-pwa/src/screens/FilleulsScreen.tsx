import { useMemo, useState } from 'react'
import { usePaginatedList } from '../hooks/usePaginatedList'
import { getFilleuls } from '../api/ambassadeur'
import NotifBell from '../components/NotifBell'
import {
  Avatar,
  Card,
  EmptyState,
  ErrorState,
  SkeletonList,
  formatDate,
  formatFcfa,
} from '../components/ui'
import { IconSearch } from '../components/icons'

export default function FilleulsScreen() {
  const { items, loading, loadingMore, error, hasMore, reload, loadMore } =
    usePaginatedList(getFilleuls)
  const [q, setQ] = useState('')

  const filtres = useMemo(() => {
    const needle = q.trim().toLowerCase()
    if (!needle) return items
    return items.filter((f) => f.nom.toLowerCase().includes(needle))
  }, [items, q])

  return (
    <div className="screen">
      <div className="topbar">
        <h1>Mes filleuls</h1>
        <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
          {items.length > 0 && (
            <span className="badge">
              {items.length}
              {hasMore ? '+' : ''}
            </span>
          )}
          <NotifBell />
        </div>
      </div>

      {loading ? (
        <SkeletonList rows={4} />
      ) : error ? (
        <ErrorState message={error} onRetry={reload} />
      ) : items.length === 0 ? (
        <EmptyState
          emoji="👥"
          title="Aucun filleul"
          subtitle="Partage ton code pour parrainer tes premiers commerçants."
        />
      ) : (
        <>
          <div className="search-field">
            <IconSearch />
            <input
              className="input"
              placeholder="Rechercher un filleul…"
              value={q}
              onChange={(e) => setQ(e.target.value)}
            />
          </div>

          {filtres.length === 0 ? (
            <Card>
              <EmptyState emoji="🔍" title="Aucun résultat" subtitle={`Rien pour « ${q} ».`} />
            </Card>
          ) : (
            <Card>
              <div className="list">
                {filtres.map((f) => (
                  <div className="list-item" key={f.filleul_id}>
                    <Avatar nom={f.nom} />
                    <div className="li-body">
                      <div className="li-title">{f.nom}</div>
                      <div className="li-sub">Inscrit le {formatDate(f.date_inscription)}</div>
                    </div>
                    <div className="li-trailing">
                      <span className={'badge' + (f.plan === 'FREE' ? ' badge--muted' : '')}>
                        {f.plan}
                      </span>
                      <div className="li-amount" style={{ marginTop: 5 }}>
                        {formatFcfa(f.commission_cumulee)}
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </Card>
          )}

          {hasMore && !q && (
            <button
              className="btn btn--outline btn--block"
              style={{ marginTop: 16 }}
              disabled={loadingMore}
              onClick={loadMore}
            >
              {loadingMore ? 'Chargement…' : 'Charger plus'}
            </button>
          )}
        </>
      )}
    </div>
  )
}
