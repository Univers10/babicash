import { useCallback, useEffect, useState } from 'react'

/** Petit hook de chargement de données (fetch au montage + reload manuel). */
export function useAsync<T>(fn: () => Promise<T>) {
  const [data, setData] = useState<T>()
  const [error, setError] = useState<string>()
  const [loading, setLoading] = useState(true)

  const reload = useCallback(() => {
    setLoading(true)
    setError(undefined)
    fn()
      .then((d) => setData(d))
      .catch((e) => setError(e?.message ?? 'Une erreur est survenue'))
      .finally(() => setLoading(false))
    // fn est un callback stable côté écrans (pas de dépendances mouvantes)
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [])

  useEffect(() => {
    reload()
  }, [reload])

  return { data, error, loading, reload }
}
