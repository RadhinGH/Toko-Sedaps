/* Sedapss Cloth - Service Worker (PWA offline cache) */
const CACHE_NAME = 'sedapss-cache-v4-3';
const CORE_ASSETS = ['./', './index.html', './manifest.json', './media/logo.jpeg', './media/qris-sedapss.png'];

/* Install: cache aset inti */
self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then((cache) => cache.addAll(CORE_ASSETS))
      .then(() => self.skipWaiting())
  );
});

/* Activate: hapus cache lama */
self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys()
      .then((keys) => Promise.all(keys.filter((k) => k !== CACHE_NAME).map((k) => caches.delete(k))))
      .then(() => self.clients.claim())
  );
});

/* Fetch:
   - HTML dokumen: network-first (update selalu terambil, fallback cache saat offline)
   - Aset lokal lain (gambar): cache-first
   - CDN: biarkan network */
self.addEventListener('fetch', (event) => {
  if (event.request.method !== 'GET') return;
  if (event.request.headers.has('range')) return;
  const url = new URL(event.request.url);
  const isLocal = url.origin === self.location.origin;
  if (!isLocal) return;

  const isHTML = event.request.destination === 'document' || url.pathname.endsWith('.html') || url.pathname === '/';

  if (isHTML) {
    event.respondWith(
      fetch(event.request)
        .then((response) => {
          if (response && response.status === 200) {
            const clone = response.clone();
            caches.open(CACHE_NAME).then((cache) => cache.put(event.request, clone));
          }
          return response;
        })
        .catch(() => caches.match(event.request))
    );
    return;
  }

  event.respondWith(
    caches.match(event.request).then((cached) => {
      const fetchPromise = fetch(event.request)
        .then((response) => {
          if (response && response.status === 200) {
            const clone = response.clone();
            caches.open(CACHE_NAME).then((cache) => cache.put(event.request, clone));
          }
          return response;
        })
        .catch(() => cached);
      return cached || fetchPromise;
    })
  );
});
