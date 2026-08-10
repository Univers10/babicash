import { useCallback, useEffect, useState } from 'react'
import { getVapidPublicKey, subscribePush, unsubscribePush } from '../api/ambassadeur'

/** Convertit une clé VAPID publique (base64 URL-safe) en tableau d'octets pour pushManager.subscribe. */
function urlBase64ToUint8Array(base64String: string): BufferSource {
  const padding = '='.repeat((4 - (base64String.length % 4)) % 4)
  const base64 = (base64String + padding).replace(/-/g, '+').replace(/_/g, '/')
  const rawData = atob(base64)
  const outputArray = new Uint8Array(rawData.length)
  for (let i = 0; i < rawData.length; i++) outputArray[i] = rawData.charCodeAt(i)
  return outputArray
}

/** Gère l'abonnement Web Push du navigateur (permission + PushManager + backend). */
export function usePushNotifications() {
  const [supported] = useState(
    () => 'serviceWorker' in navigator && 'PushManager' in window && 'Notification' in window,
  )
  const [permission, setPermission] = useState<NotificationPermission>(
    supported ? Notification.permission : 'denied',
  )
  const [subscribed, setSubscribed] = useState(false)
  const [loading, setLoading] = useState(false)

  useEffect(() => {
    if (!supported) return
    navigator.serviceWorker.ready
      .then((reg) => reg.pushManager.getSubscription())
      .then((sub) => setSubscribed(!!sub))
      .catch(() => {
        /* pas grave : l'utilisateur pourra réessayer de s'abonner */
      })
  }, [supported])

  const enable = useCallback(async (): Promise<boolean> => {
    if (!supported) return false
    setLoading(true)
    try {
      const perm = await Notification.requestPermission()
      setPermission(perm)
      if (perm !== 'granted') return false

      const { public_key } = await getVapidPublicKey()
      if (!public_key) return false // push non configuré côté serveur

      const reg = await navigator.serviceWorker.ready
      let sub = await reg.pushManager.getSubscription()
      if (!sub) {
        sub = await reg.pushManager.subscribe({
          userVisibleOnly: true,
          applicationServerKey: urlBase64ToUint8Array(public_key),
        })
      }
      const json = sub.toJSON()
      if (!json.endpoint || !json.keys?.p256dh || !json.keys?.auth) return false

      await subscribePush({
        endpoint: json.endpoint,
        keys: { p256dh: json.keys.p256dh, auth: json.keys.auth },
      })
      setSubscribed(true)
      return true
    } finally {
      setLoading(false)
    }
  }, [supported])

  const disable = useCallback(async () => {
    if (!supported) return
    setLoading(true)
    try {
      const reg = await navigator.serviceWorker.ready
      const sub = await reg.pushManager.getSubscription()
      if (sub) {
        await unsubscribePush({ endpoint: sub.endpoint }).catch(() => {})
        await sub.unsubscribe()
      }
      setSubscribed(false)
    } finally {
      setLoading(false)
    }
  }, [supported])

  return { supported, permission, subscribed, loading, enable, disable }
}
