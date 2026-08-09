import { NavLink } from 'react-router-dom'
import { IconHome, IconUser, IconUsers, IconWallet } from './icons'

const items = [
  { to: '/', label: 'Accueil', Icon: IconHome },
  { to: '/filleuls', label: 'Filleuls', Icon: IconUsers },
  { to: '/gains', label: 'Gains', Icon: IconWallet },
  { to: '/profil', label: 'Profil', Icon: IconUser },
]

export default function BottomNav() {
  return (
    <nav className="bottom-nav">
      <div className="bottom-nav-inner">
        {items.map(({ to, label, Icon }) => (
          <NavLink
            key={to}
            to={to}
            end={to === '/'}
            className={({ isActive }) => 'nav-item' + (isActive ? ' active' : '')}
          >
            <span className="nav-icon-wrap">
              <Icon />
            </span>
            {label}
          </NavLink>
        ))}
      </div>
    </nav>
  )
}
