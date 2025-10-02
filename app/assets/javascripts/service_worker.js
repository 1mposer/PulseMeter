// Service Worker for PulseMeter - Basic offline support

const CACHE_VERSION = 'v1'
const CACHE_NAME = `pulsemeter-${CACHE_VERSION}`
const RUNTIME_CACHE = `runtime-${CACHE_VERSION}`

// Assets to precache on install
const PRECACHE_ASSETS = [
  '/assets/application.css',
  '/assets/application.js',
  '/assets/tailwind.css',
  '/offline.html'
]

// Install event - precache critical assets
self.addEventListener('install', (event) => {
  console.log('[ServiceWorker] Install')

  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => {
      console.log('[ServiceWorker] Precaching app shell')
      // Try to cache, but don't fail install if some assets are missing
      return Promise.allSettled(
        PRECACHE_ASSETS.map(url =>
          cache.add(url).catch(err =>
            console.warn(`Failed to cache ${url}:`, err)
          )
        )
      )
    })
  )

  // Activate immediately
  self.skipWaiting()
})

// Activate event - clean up old caches
self.addEventListener('activate', (event) => {
  console.log('[ServiceWorker] Activate')

  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames
          .filter(name => name.startsWith('pulsemeter-') || name.startsWith('runtime-'))
          .filter(name => name !== CACHE_NAME && name !== RUNTIME_CACHE)
          .map(name => {
            console.log('[ServiceWorker] Deleting old cache:', name)
            return caches.delete(name)
          })
      )
    })
  )

  // Take control immediately
  self.clients.claim()
})

// Fetch event - serve from cache when possible
self.addEventListener('fetch', (event) => {
  const { request } = event
  const url = new URL(request.url)

  // Skip non-GET requests
  if (request.method !== 'GET') return

  // Skip external requests
  if (url.origin !== location.origin) return

  // Handle /ui/* panel requests with stale-while-revalidate
  if (url.pathname.startsWith('/ui/')) {
    event.respondWith(
      caches.open(RUNTIME_CACHE).then(async (cache) => {
        // Try cache first
        const cachedResponse = await cache.match(request)

        // Fetch in background to update cache
        const fetchPromise = fetch(request).then((response) => {
          if (response.ok) {
            cache.put(request, response.clone())
          }
          return response
        }).catch(() => {
          // If fetch fails and we have cache, use it
          if (cachedResponse) return cachedResponse

          // Otherwise return offline message
          return new Response(
            `<turbo-frame id="main_panel">
              <div class="flex items-center justify-center h-full">
                <div class="text-center p-8">
                  <div class="text-6xl text-gray-600 mb-4">⊗</div>
                  <h2 class="text-2xl font-bold text-gray-400 mb-2">You're Offline</h2>
                  <p class="text-gray-500">Tables and Reservations data may be stale.</p>
                  <p class="text-sm text-gray-600 mt-4">Your actions won't be saved until connection is restored.</p>
                </div>
              </div>
            </turbo-frame>`,
            {
              headers: {
                'Content-Type': 'text/html',
                'Cache-Control': 'no-store'
              }
            }
          )
        })

        // Return cached response immediately if available
        return cachedResponse || fetchPromise
      })
    )
    return
  }

  // Handle analytics JSON (mock for now)
  if (url.pathname === '/analytics/summary.json') {
    event.respondWith(
      fetch(request).catch(() => {
        // Return mock data when offline
        return new Response(
          JSON.stringify({
            today: {
              revenue: 1250.50,
              sessions: 42,
              avg_duration: 87
            },
            week: {
              revenue: 8420.25,
              sessions: 284
            }
          }),
          {
            headers: {
              'Content-Type': 'application/json',
              'Cache-Control': 'no-store'
            }
          }
        )
      })
    )
    return
  }

  // For everything else, try network first, fall back to cache
  event.respondWith(
    fetch(request).catch(() => {
      return caches.match(request)
    })
  )
})

// Listen for messages from the app
self.addEventListener('message', (event) => {
  if (event.data && event.data.type === 'SKIP_WAITING') {
    self.skipWaiting()
  }
})