const CACHE = 'mog-v2';

const ASSETS = [
  './',
  './index.html',
  './styles.css',
  './app.js',
  './manifest.webmanifest',
  './icon.svg',
  './assets/mog-mark.svg',
  './assets/talent.svg',
  './assets/verified.svg',
  './assets/badge-verified-128.webp',
  './assets/badge-verified-256.webp',
  './assets/badge-rank-128.webp',
  './assets/badge-rank-256.webp',
  './assets/badge-rank-512.webp',
  './assets/badge-creator-256.webp',
  './assets/crest-streak-256.webp',
  './assets/crest-streak-640.webp',
  './assets/crest-breakthrough-256.webp',
  './assets/crest-breakthrough-640.webp'
];

self.addEventListener('install', e => {
  self.skipWaiting();
  e.waitUntil(caches.open(CACHE).then(c => c.addAll(ASSETS)));
});

self.addEventListener('activate', e => {
  e.waitUntil(
    caches.keys()
      .then(keys => Promise.all(keys.filter(k => k !== CACHE).map(k => caches.delete(k))))
      .then(() => self.clients.claim())
  );
});

self.addEventListener('fetch', e => {
  if (e.request.method !== 'GET') return;
  e.respondWith(
    caches.match(e.request).then(hit => hit || fetch(e.request).then(res => {
      const copy = res.clone();
      caches.open(CACHE).then(c => c.put(e.request, copy));
      return res;
    }).catch(() => caches.match('./index.html')))
  );
});
