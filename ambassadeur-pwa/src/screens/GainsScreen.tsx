import { useState } from 'react'
import { usePaginatedList } from '../hooks/usePaginatedList'
import { useAsync } from '../hooks/useAsync'
import { getCommissions, getMonEspace, getVersements } from '../api/ambassadeur'
import NotifBell from '../components/NotifBell'
import {
  Avatar,
  Card,
  EmptyState,
  ErrorState,
  SegmentedControl,
  SkeletonList,
  StatusBadge,
  formatDate,
  formatFcfa,
} from '../components/ui'

type Onglet = 'versements' | 'commissions'

export default function GainsScreen() {
  const [onglet, setOnglet] = useState<Onglet>('versements')
  const espace = useAsync(getMonEspace)
  const commissions = usePaginatedList(getCommissions)
  const versements = usePaginatedList(getVersements)

  return (
    <div className="screen">
      <div className="topbar">
        <h1>Mes gains</h1>
        <NotifBell />
      </div>

      {espace.data && (
        <div className="stat-row" style={{ marginTop: 0 }}>
          <div className="stat">
            <div>
              <div className="cap">À recevoir</div>
              <div className="num">{formatFcfa(espace.data.solde_a_recevoir)}</div>
            </div>
          </div>
          <div className="stat">
            <div>
              <div className="cap">Gagné à vie</div>
              <div className="num">{formatFcfa(espace.data.total_gagne)}</div>
            </div>
          </div>
        </div>
      )}

      <div style={{ marginTop: 20 }}>
        <SegmentedControl
          value={onglet}
          onChange={setOnglet}
          options={[
            { value: 'versements', label: 'Versements' },
            { value: 'commissions', label: 'Commissions' },
          ]}
        />
      </div>

      {onglet === 'versements' ? (
        <div style={{ marginTop: 16 }}>
          {versements.loading ? (
            <SkeletonList rows={3} />
          ) : versements.error ? (
            <ErrorState message={versements.error} onRetry={versements.reload} />
          ) : versements.items.length === 0 ? (
            <Card>
              <EmptyState
                emoji="💸"
                title="Aucun versement"
                subtitle="Tes commissions validées sont regroupées et versées chaque semaine."
              />
            </Card>
          ) : (
            <>
              <Card>
                <div className="list">
                  {versements.items.map((v) => (
                    <div className="list-item" key={v.id}>
                      <div className="li-body">
                        <div className="li-title">Semaine {v.semaine}</div>
                        <div className="li-sub">
                          {v.reference_transfert
                            ? `Réf. ${v.reference_transfert}`
                            : formatDate(v.date_creation)}
                        </div>
                      </div>
                      <div className="li-trailing">
                        <div className="li-amount">{formatFcfa(v.montant_total)}</div>
                        <div style={{ marginTop: 5 }}>
                          <StatusBadge statut={v.statut} />
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              </Card>
              {versements.hasMore && (
                <button
                  className="btn btn--outline btn--block"
                  style={{ marginTop: 12 }}
                  disabled={versements.loadingMore}
                  onClick={versements.loadMore}
                >
                  {versements.loadingMore ? 'Chargement…' : 'Charger plus'}
                </button>
              )}
            </>
          )}
        </div>
      ) : (
        <div style={{ marginTop: 16 }}>
          {commissions.loading ? (
            <SkeletonList rows={3} />
          ) : commissions.error ? (
            <ErrorState message={commissions.error} onRetry={commissions.reload} />
          ) : commissions.items.length === 0 ? (
            <Card>
              <EmptyState emoji="🌱" title="Aucune commission" />
            </Card>
          ) : (
            <>
              <Card>
                <div className="list">
                  {commissions.items.map((c) => (
                    <div className="list-item" key={c.id}>
                      <Avatar nom={c.filleul_nom} />
                      <div className="li-body">
                        <div className="li-title">{c.filleul_nom}</div>
                        <div className="li-sub">
                          {formatDate(c.date_creation)} · sur {formatFcfa(c.montant_paye)}
                        </div>
                      </div>
                      <div className="li-trailing">
                        <div className="li-amount">+{formatFcfa(c.montant_commission)}</div>
                        <div style={{ marginTop: 5 }}>
                          <StatusBadge statut={c.statut} />
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              </Card>
              {commissions.hasMore && (
                <button
                  className="btn btn--outline btn--block"
                  style={{ marginTop: 12 }}
                  disabled={commissions.loadingMore}
                  onClick={commissions.loadMore}
                >
                  {commissions.loadingMore ? 'Chargement…' : 'Charger plus'}
                </button>
              )}
            </>
          )}
        </div>
      )}
    </div>
  )
}
