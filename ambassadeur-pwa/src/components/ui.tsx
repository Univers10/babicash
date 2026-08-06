import type { ReactNode } from 'react'

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

export function ErrorState({
  message,
  onRetry,
}: {
  message?: string
  onRetry?: () => void
}) {
  return (
    <div className="empty">
      <div className="emoji">😕</div>
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
      <div className="emoji">{emoji}</div>
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
  return <span className={`badge ${s.cls}`}>{s.label}</span>
}

export function Avatar({ nom }: { nom: string }) {
  return <div className="avatar">{initiales(nom)}</div>
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
