const CACHE_NAME = 'babicash-admin-v1';
const STATIC_ASSETS = [
  '/admin/',
  '/admin/login',
  '/static/manifest.json',
  '/static/css/admin.css',
  '/static/js/admin.js',
  'https://cdn.jsdelivr.net/npm/daisyui@4/dist/full.min.css',
  'https://cdn.tailwindcss.com',
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => cache.addAll(STATIC_ASSETS))
  );
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((keys) =>
      Promise.all(keys.filter((k) => k !== CACHE_NAME).map((k) => caches.delete(k)))
    )
  );
  self.clients.claim();
});

self.addEventListener('fetch', (event) => {
  const { request } = event;
  // Ne pas cacher les requêtes API ni les redirections login
  if (request.url.includes('/api/') || request.url.includes('/admin/login')) {
    return;
  }
  event.respondWith(
    caches.match(request).then((cached) => {
      const fetched = fetch(request).then((response) => {
        if (response.ok) {
          const clone = response.clone();
          caches.open(CACHE_NAME).then((cache) => cache.put(request, clone));
        }
        return response;
      }).catch(() => cached);
      return cached || fetched;
    })
  );
});
