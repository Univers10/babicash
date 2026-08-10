/// <reference lib="webworker" />
// Service worker custom (stratégie injectManifest) : précache Workbox +
// gestion des notifications Web Push pour l'espace ambassadeur.
import { precacheAndRoute } from 'workbox-precaching'

declare let self: ServiceWorkerGlobalScope

precacheAndRoute(self.__WB_MANIFEST)

// Permet au client (virtual:pwa-register) de forcer l'activation immédiate
// de la nouvelle version lors d'une mise à jour.
self.addEventListener('message', (event) => {
  if (event.data && event.data.type === 'SKIP_WAITING') self.skipWaiting()
})

interface PushPayload {
  title?: string
  body?: string
}

self.addEventListener('push', (event: PushEvent) => {
  let data: PushPayload = {}
  try {
    data = event.data ? (event.data.json() as PushPayload) : {}
  } catch {
    data = { title: 'BabiCash Ambassadeur', body: event.data?.text() ?? '' }
  }

  const title = data.title || 'BabiCash Ambassadeur'
  const options: NotificationOptions = {
    body: data.body || '',
    icon: '/icon.svg',
    badge: '/icon.svg',
  }

  event.waitUntil(self.registration.showNotification(title, options))
})

self.addEventListener('notificationclick', (event: NotificationEvent) => {
  event.notification.close()
  event.waitUntil(
    self.clients.matchAll({ type: 'window', includeUncontrolled: true }).then((clientsArr) => {
      const existing = clientsArr.find((c) => 'focus' in c) as WindowClient | undefined
      if (existing) return existing.focus()
      return self.clients.openWindow('/notifications')
    }),
  )
})
