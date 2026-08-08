import type { CSSProperties, ReactNode } from 'react'

export function formatFcfa(v: number | string | null | undefined): string {
  const n = typeof v === 'string' ? parseFloat(v) : v ?? 0
  const safe = Number.isFinite(n as number) ? (n as number) : 0
  return safe.toLocaleString('fr-FR', { maximumFractionDigits: 0 }) + ' F'
}

export function formatDate(iso: string | null | undefined): string {
  if (!iso) return '—'
  const d = new Date(iso)
  if (Number.isNaN(d.getTime())) return '—'
  return d.toLocaleDateString('fr-FR', {
    day: '2-digit',
    month: 'short',
    year: 'numeric',
  })
}

export function initiales(nom: string): string {
  const parts = nom.trim().split(/\s+/).slice(0, 2)
  return parts.map((p) => p[0]?.toUpperCase() ?? '').join('') || '?'
}

// Palette dérivée de la charte (vert / or / brun) pour varier les avatars
// tout en restant dans les tons de marque.
const AVATAR_PALETTE = ['#1B6B2F', '#2E8B46', '#BF7E0F', '#3D1F00', '#175A28']

function hashString(s: string): number {
  let h = 0
  for (let i = 0; i < s.length; i++) h = (h * 31 + s.charCodeAt(i)) >>> 0
  return h
}

export function Spinner() {
  return <div className="spinner" />
}

export function Loading() {
  return (
    <div className="center-pad">
      <Spinner />
    </div>
  )
}

/** Ligne de squelette pour une carte de type liste (avatar + 2 lignes de texte). */
export function SkeletonRow() {
  return (
    <div className="skeleton-row">
      <div className="skeleton skeleton-avatar" />
      <div className="skeleton-lines">
        <div className="skeleton skeleton-line" style={{ width: '55%' }} />
        <div className="skeleton skeleton-line" style={{ width: '35%' }} />
      </div>
    </div>
  )
}

/** Bloc de squelettes pour remplacer une liste en cours de chargement. */
export function SkeletonList({ rows = 3 }: { rows?: number }) {
  return (
    <div className="card">
      <div className="list">
        {Array.from({ length: rows }).map((_, i) => (
          <SkeletonRow key={i} />
        ))}
      </div>
    </div>
  )
}

export function SkeletonHero() {
  return <div className="skeleton skeleton-hero" />
}

export function ErrorState({
  message,
  onRetry,
}: {
  message?: string
  onRetry?: () => void
}) {
  return (
    <div className="empty">
      <div className="emoji-wrap">😕</div>
      <div className="t">Oups</div>
      <div className="s">{message ?? 'Impossible de charger les données.'}</div>
      {onRetry && (
        <button className="btn btn--outline" style={{ marginTop: 16 }} onClick={onRetry}>
          Réessayer
        </button>
      )}
    </div>
  )
}

export function EmptyState({
  emoji,
  title,
  subtitle,
}: {
  emoji: string
  title: string
  subtitle?: string
}) {
  return (
    <div className="empty">
      <div className="emoji-wrap">{emoji}</div>
      <div className="t">{title}</div>
      {subtitle && <div className="s">{subtitle}</div>}
    </div>
  )
}

const STATUTS: Record<string, { label: string; cls: string }> = {
  VALIDEE: { label: 'Validée', cls: 'badge--warning' },
  PAYEE: { label: 'Versée', cls: 'badge--success' },
  ANNULEE: { label: 'Annulée', cls: 'badge--danger' },
  A_PAYER: { label: 'À payer', cls: 'badge--warning' },
  PAYE: { label: 'Payé', cls: 'badge--success' },
}

export function StatusBadge({ statut }: { statut: string }) {
  const s = STATUTS[statut] ?? { label: statut, cls: 'badge--muted' }
  return (
    <span className={`badge ${s.cls}`}>
      <span className="badge-dot" />
      {s.label}
    </span>
  )
}

export function Avatar({ nom }: { nom: string }) {
  const color = AVATAR_PALETTE[hashString(nom) % AVATAR_PALETTE.length]
  return (
    <div className="avatar" style={{ background: color }}>
      {initiales(nom)}
    </div>
  )
}

/** Avatar « icône » neutre (vert clair), pour les entités non nominatives. */
export function IconAvatar({ children }: { children: ReactNode }) {
  return <div className="avatar avatar--icon">{children}</div>
}

export function Card({
  children,
  tight,
  style,
}: {
  children: ReactNode
  tight?: boolean
  style?: CSSProperties
}) {
  return (
    <div className={'card' + (tight ? ' card--tight' : '')} style={style}>
      {children}
    </div>
  )
}

export function SectionTitle({
  children,
  action,
}: {
  children: ReactNode
  action?: { label: string; onClick: () => void }
}) {
  return (
    <div className="section-title">
      <span>{children}</span>
      {action && (
        <button className="link" onClick={action.onClick} style={{ background: 'none', border: 'none' }}>
          {action.label}
        </button>
      )}
    </div>
  )
}

export function SegmentedControl<T extends string>({
  options,
  value,
  onChange,
}: {
  options: { value: T; label: string }[]
  value: T
  onChange: (v: T) => void
}) {
  return (
    <div className="segmented" role="tablist">
      {options.map((o) => (
        <button
          key={o.value}
          role="tab"
          aria-selected={o.value === value}
          className={o.value === value ? 'active' : ''}
          onClick={() => onChange(o.value)}
          type="button"
        >
          {o.label}
        </button>
      ))}
    </div>
  )
}

export function Row({
  title,
  subtitle,
  right,
  left,
}: {
  title: string
  subtitle?: ReactNode
  right?: ReactNode
  left?: ReactNode
}) {
  return (
    <div className="list-item">
      {left}
      <div className="li-body">
        <div className="li-title">{title}</div>
        {subtitle && <div className="li-sub">{subtitle}</div>}
      </div>
      {right}
    </div>
  )
}
