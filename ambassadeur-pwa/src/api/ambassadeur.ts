import { api } from './client'
import type {
  AmbassadeurNotification,
  CodeDisponible,
  Commission,
  Filleul,
  MonEspace,
  Operateur,
  PushSubscriptionPayload,
  Versement,
} from './types'

const PAGE_SIZE = 50

export const getMonEspace = () => api<MonEspace>('/ambassadeurs/moi')

export const getFilleuls = (offset = 0, limit = PAGE_SIZE) =>
  api<Filleul[]>(`/ambassadeurs/filleuls?limit=${limit}&offset=${offset}`)

export const getCommissions = (offset = 0, limit = PAGE_SIZE) =>
  api<Commission[]>(`/ambassadeurs/commissions?limit=${limit}&offset=${offset}`)

export const getVersements = (offset = 0, limit = PAGE_SIZE) =>
  api<Versement[]>(`/ambassadeurs/versements?limit=${limit}&offset=${offset}`)

export const checkCode = (code: string) =>
  api<CodeDisponible>(
    `/ambassadeurs/code-disponible?code=${encodeURIComponent(code)}`,
    { auth: false },
  )

export const updateMomo = (momo_numero: string, momo_operateur: Operateur) =>
  api<MonEspace>('/ambassadeurs/moi', {
    method: 'PATCH',
    body: { momo_numero, momo_operateur },
  })

// ── Notifications ─────────────────────────────────────────────────────

export const getNotifications = (offset = 0, limit = PAGE_SIZE) =>
  api<AmbassadeurNotification[]>(
    `/ambassadeurs/notifications?limit=${limit}&offset=${offset}`,
  )

export const getNonLuesCount = () =>
  api<{ count: number }>('/ambassadeurs/notifications/non-lues')

export const marquerNotificationLue = (id: string) =>
  api<void>(`/ambassadeurs/notifications/${id}/lu`, { method: 'POST' })

export const marquerToutesNotificationsLues = () =>
  api<void>('/ambassadeurs/notifications/lu-tout', { method: 'POST' })

// ── Notifications push (Web Push) ─────────────────────────────────────

export const getVapidPublicKey = () =>
  api<{ public_key: string }>('/ambassadeurs/push/cle-publique', { auth: false })

export const subscribePush = (payload: PushSubscriptionPayload) =>
  api<void>('/ambassadeurs/push/abonner', { method: 'POST', body: payload })

export const unsubscribePush = (payload: { endpoint: string }) =>
  api<void>('/ambassadeurs/push/desabonner', { method: 'POST', body: payload })
