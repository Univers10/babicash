import { useCallback, useEffect, useState } from 'react'

const PAGE_SIZE = 50

/** Hook de liste paginée (offset/limit) avec chargement initial + "charger plus". */
export function usePaginatedList<T>(fetchPage: (offset: number, limit: number) => Promise<T[]>) {
  const [items, setItems] = useState<T[]>([])
  const [error, setError] = useState<string>()
  const [loading, setLoading] = useState(true)
  const [loadingMore, setLoadingMore] = useState(false)
  const [hasMore, setHasMore] = useState(false)

  const reload = useCallback(() => {
    setLoading(true)
    setError(undefined)
    fetchPage(0, PAGE_SIZE)
      .then((page) => {
        setItems(page)
        setHasMore(page.length === PAGE_SIZE)
      })
      .catch((e) => setError(e?.message ?? 'Une erreur est survenue'))
      .finally(() => setLoading(false))
    // fetchPage est un callback stable côté écrans (pas de dépendances mouvantes)
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [])

  useEffect(() => {
    reload()
  }, [reload])

  async function loadMore() {
    if (loadingMore || !hasMore) return
    setLoadingMore(true)
    try {
      const page = await fetchPage(items.length, PAGE_SIZE)
      setItems((prev) => [...prev, ...page])
      setHasMore(page.length === PAGE_SIZE)
    } catch (e) {
      setError((e as Error)?.message ?? 'Une erreur est survenue')
    } finally {
      setLoadingMore(false)
    }
  }

  return { items, error, loading, loadingMore, hasMore, reload, loadMore }
}
