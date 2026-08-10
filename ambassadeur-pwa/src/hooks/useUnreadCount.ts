import { useCallback, useEffect, useState } from 'react'
import { getNonLuesCount } from '../api/ambassadeur'

/** Compte les notifications non lues, rafraîchi au montage puis périodiquement. */
export function useUnreadCount(intervalMs = 30000) {
  const [count, setCount] = useState(0)

  const refresh = useCallback(() => {
    getNonLuesCount()
      .then((r) => setCount(r.count))
      .catch(() => {
        /* silencieux : le badge n'est qu'indicatif */
      })
  }, [])

  useEffect(() => {
    refresh()
    const id = setInterval(refresh, intervalMs)
    return () => clearInterval(id)
  }, [refresh, intervalMs])

  return { count, refresh }
}
