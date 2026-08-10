import { usePaginatedList } from '../hooks/usePaginatedList'
import { usePushNotifications } from '../hooks/usePushNotifications'
import { getNotifications, marquerNotificationLue, marquerToutesNotificationsLues } from '../api/ambassadeur'
import {
  Card,
  EmptyState,
  ErrorState,
  IconAvatar,
  SkeletonList,
  formatDate,
} from '../components/ui'
import { IconBell, IconCheckCircle, IconGift, IconUsers } from '../components/icons'
import type { AmbassadeurNotification, NotificationType } from '../api/types'

const TYPE_ICON: Record<NotificationType, JSX.Element> = {
  NOUVEAU_FILLEUL: <IconUsers width={18} height={18} />,
  COMMISSION: <IconGift width={18} height={18} />,
  VERSEMENT: <IconCheckCircle width={18} height={18} />,
}

function NotificationRow({
  notif,
  onRead,
}: {
  notif: AmbassadeurNotification
  onRead: (id: string) => void
}) {
  return (
    <div
      className={'list-item' + (notif.lu ? '' : ' list-item--unread')}
      onClick={() => !notif.lu && onRead(notif.id)}
      style={{ cursor: notif.lu ? 'default' : 'pointer' }}
    >
      <IconAvatar>{TYPE_ICON[notif.type] ?? <IconBell width={18} height={18} />}</IconAvatar>
      <div className="li-body">
        <div className="li-title">{notif.titre}</div>
        <div className="li-sub">{notif.message}</div>
        <div className="li-sub" style={{ marginTop: 2 }}>
          {formatDate(notif.date_creation)}
        </div>
      </div>
      {!notif.lu && <span className="badge-dot badge-dot--accent" aria-label="Non lue" />}
    </div>
  )
}

export default function NotificationsScreen() {
  const { items, loading, error, hasMore, reload, loadMore, loadingMore } =
    usePaginatedList(getNotifications)
  const push = usePushNotifications()

  async function marquerLue(id: string) {
    try {
      await marquerNotificationLue(id)
      reload()
    } catch {
      /* on retentera au prochain rechargement */
    }
  }

  async function toutMarquer() {
    try {
      await marquerToutesNotificationsLues()
      reload()
    } catch {
      /* silencieux */
    }
  }

  const nonLues = items.filter((n) => !n.lu).length

  return (
    <div className="screen">
      <div className="topbar">
        <h1>Notifications</h1>
        {nonLues > 0 && (
          <button className="link" onClick={toutMarquer} style={{ background: 'none', border: 'none' }}>
            Tout marquer comme lu
          </button>
        )}
      </div>

      {push.supported && !push.subscribed && (
        <Card style={{ marginBottom: 16 }}>
          <div className="li-body" style={{ marginBottom: 12 }}>
            <div className="li-title">Activer les notifications push</div>
            <div className="li-sub">
              Reçois une alerte immédiate pour chaque filleul, commission ou versement.
            </div>
          </div>
          <button
            className="btn btn--outline btn--block"
            disabled={push.loading}
            onClick={() => push.enable()}
          >
            {push.loading ? 'Activation…' : 'Activer les notifications'}
          </button>
        </Card>
      )}

      {loading ? (
        <SkeletonList rows={4} />
      ) : error ? (
        <ErrorState message={error} onRetry={reload} />
      ) : items.length === 0 ? (
        <EmptyState
          emoji="🔔"
          title="Aucune notification"
          subtitle="Tu seras prévenu ici pour chaque nouveau filleul, commission ou versement."
        />
      ) : (
        <>
          <Card>
            <div className="list">
              {items.map((n) => (
                <NotificationRow key={n.id} notif={n} onRead={marquerLue} />
              ))}
            </div>
          </Card>
          {hasMore && (
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
