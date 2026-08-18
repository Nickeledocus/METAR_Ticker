/* Service worker voor de METAR Ticker.
   Doet twee dingen: de app installeerbaar maken, en de app-schil onthouden
   zodat hij ook zonder internet nog opstart. De weerdata zelf wordt NOOIT
   bewaard - die komt van een andere server en moet altijd vers zijn. */

const CACHE = 'metar-ticker-v1';   // hoog dit getal op als je de app wijzigt
const SHELL = [
  './',
  './index.html',
  './manifest.webmanifest',
  './icons/icon-192.png',
  './icons/icon-512.png'
];

// Installeren: de schil in de kast leggen
self.addEventListener('install', (e) => {
  e.waitUntil(
    caches.open(CACHE).then((c) => c.addAll(SHELL)).then(() => self.skipWaiting())
  );
});

// Activeren: oude versies van de kast opruimen
self.addEventListener('activate', (e) => {
  e.waitUntil(
    caches.keys()
      .then((keys) => Promise.all(keys.filter((k) => k !== CACHE).map((k) => caches.delete(k))))
      .then(() => self.clients.claim())
  );
});

// Ophalen: eigen bestanden uit de kast (of van het net); vreemde servers met rust laten
self.addEventListener('fetch', (e) => {
  const req = e.request;
  const url = new URL(req.url);

  // Verzoeken naar een andere server (de weerdata via de proxy) niet aanraken
  if (url.origin !== self.location.origin) return;

  // De pagina zelf: eerst het net proberen (zo krijg je updates), anders uit de kast
  if (req.mode === 'navigate') {
    e.respondWith(
      fetch(req)
        .then((r) => { const copy = r.clone(); caches.open(CACHE).then((c) => c.put(req, copy)); return r; })
        .catch(() => caches.match('./index.html'))
    );
    return;
  }

  // Overige eigen bestandjes (icoon, manifest): eerst uit de kast
  e.respondWith(caches.match(req).then((r) => r || fetch(req)));
});
