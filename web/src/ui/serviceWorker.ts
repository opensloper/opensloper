// An app's service worker, the design, publish or measurements app's, which
// makes it work offline as an installed web app: it keeps every file the
// site serves for the app (the page, its scripts, the engine's .wasm, the
// icons and the app's examples) in a cache named
// after the app and the build, and answers from it before the network.
// A new build has a new version, so its worker installs beside the old one
// and waits; the page offers to reload into it, and the old cache goes once
// it takes over. Users' files never pass through it. The bundler (bundle.ts)
// fills in the app, the files and the version.

declare const SW_APP: string;
declare const SW_FILES: string[];
declare const SW_VERSION: string;

// Each app's own, as both are served from one site
const CACHE_PREFIX = `opensloper-${SW_APP}-`;
const CACHE = CACHE_PREFIX + SW_VERSION;
// The page a navigation to the app's folder gets
const PAGE = 'index.html';

if (!(self instanceof ServiceWorkerGlobalScope)) {
  throw new Error('sw.js runs as a service worker');
}
const worker = self;
const scope = new URL(worker.registration.scope);

// A request's file as SW_FILES names it, relative to the app's folder; undefined for anything else
function fileOf(request: Request): string | undefined {
  const url = new URL(request.url);
  if (request.method !== 'GET' || url.origin !== scope.origin || !url.pathname.startsWith(scope.pathname)) {
    return undefined;
  }
  const path = decodeURIComponent(url.pathname.slice(scope.pathname.length));
  if (request.mode === 'navigate' && (path === '' || path === PAGE)) {
    return PAGE;
  }
  return SW_FILES.includes(path) ? path : undefined;
}

// The page's and the worker's typings together leave the events plain, so each is checked
worker.addEventListener('install', (event) => {
  if (!(event instanceof ExtendableEvent)) {
    return;
  }
  event.waitUntil(
    caches.open(CACHE).then(async (cache) => cache.addAll(SW_FILES.map((file) => new URL(file, scope).href))),
  );
});

// The old builds' caches go once this one takes over, and pages open
// without a worker are taken over at once
worker.addEventListener('activate', (event) => {
  if (!(event instanceof ExtendableEvent)) {
    return;
  }
  event.waitUntil(
    caches
      .keys()
      .then(async (names) =>
        Promise.all(
          names
            .filter((name) => name.startsWith(CACHE_PREFIX) && name !== CACHE)
            .map(async (name) => caches.delete(name)),
        ),
      )
      .then(async () => worker.clients.claim()),
  );
});

worker.addEventListener('fetch', (event) => {
  if (!(event instanceof FetchEvent)) {
    return;
  }
  const file = fileOf(event.request);
  if (file === undefined) {
    return;
  }
  event.respondWith(
    caches.open(CACHE).then(async (cache) => (await cache.match(new URL(file, scope).href)) ?? fetch(event.request)),
  );
});

// The page asks a waiting worker to take over when the user chooses to reload
worker.addEventListener('message', (event) => {
  if (event instanceof ExtendableMessageEvent && event.data === 'skipWaiting') {
    void worker.skipWaiting();
  }
});
