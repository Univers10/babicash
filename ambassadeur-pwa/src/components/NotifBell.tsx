import { Link } from 'react-router-dom'
import { useUnreadCount } from '../hooks/useUnreadCount'
import { IconBell } from './icons'

/** Bouton cloche à placer dans le topbar d'un écran, avec badge non-lus. */
export default function NotifBell() {
  const { count } = useUnreadCount()
  return (
    <Link to="/notifications" className="icon-btn notif-bell" aria-label="Notifications">
      <IconBell />
      {count > 0 && <span className="notif-bell-badge">{count > 9 ? '9+' : count}</span>}
    </Link>
  )
}
