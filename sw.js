const CACHE = 'mog-v3';

const ASSETS = [
  './',
  './index.html',
  './styles.css',
  './app.js',
  './manifest.webmanifest',
  './assets/app-icon-192.png',
  './assets/app-icon-512.png',
  './assets/app-icon-maskable-512.png',
  './assets/apple-touch-icon.png',
  './assets/art-hourglass-256.webp',
  './assets/art-hourglass-512.webp',
  './assets/art-prayer-256.webp',
  './assets/art-prayer-512.webp',
  './assets/art-ring-256.webp',
  './assets/badge-creator-256.webp',
  './assets/badge-rank-128.webp',
  './assets/badge-rank-256.webp',
  './assets/badge-rank-512.webp',
  './assets/badge-verified-128.webp',
  './assets/badge-verified-256.webp',
  './assets/crest-breakthrough-256.webp',
  './assets/crest-breakthrough-640.webp',
  './assets/crest-brotherhood-256.webp',
  './assets/crest-brotherhood-512.webp',
  './assets/crest-streak-256.webp',
  './assets/crest-streak-640.webp',
  './assets/emblem-shield-128.webp',
  './assets/lockup-horizontal-720.webp',
  './assets/lockup-stacked-960.webp',
  './assets/mark-gold-256.webp',
  './assets/mark-silver-256.webp',
  './assets/mog-mark.svg',
  './assets/talent.svg',
  './assets/verified.svg'
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
