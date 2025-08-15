'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter_bootstrap.js": "8510abbdd647e968664c04cecc5c91aa",
"flutter.js": "83d881c1dbb6d6bcd6b42e274605b69c",
"version.json": "ada863b6a1cab20045c61588e2267ff2",
"canvaskit/skwasm.js": "ea559890a088fe28b4ddf70e17e60052",
"canvaskit/chromium/canvaskit.js": "8191e843020c832c9cf8852a4b909d4c",
"canvaskit/chromium/canvaskit.wasm": "f504de372e31c8031018a9ec0a9ef5f0",
"canvaskit/chromium/canvaskit.js.symbols": "b61b5f4673c9698029fa0a746a9ad581",
"canvaskit/canvaskit.js": "728b2d477d9b8c14593d4f9b82b484f3",
"canvaskit/skwasm.wasm": "39dd80367a4e71582d234948adc521c0",
"canvaskit/skwasm.js.symbols": "e72c79950c8a8483d826a7f0560573a1",
"canvaskit/canvaskit.wasm": "7a3f4ae7d65fc1de6a6e7ddd3224bc93",
"canvaskit/canvaskit.js.symbols": "bdcd3835edf8586b6d6edfce8749fb77",
"main.dart.js": "32aa9dc2f6e349a241a5184c5e1bf8ba",
"index.html": "30a70d9edd79de03bc76174549961cb2",
"/": "30a70d9edd79de03bc76174549961cb2",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "109c43694250615a6c06dd286b5a18ca",
"assets/FontManifest.json": "3020802906dc520f88ca973c65aa46d8",
"assets/NOTICES": "3f6de63add7a3762a2bc40b8eeabcbb2",
"assets/AssetManifest.json": "f19636bfae1013d0f8c6e62956756188",
"assets/AssetManifest.bin": "a13e8ea0012cf42308845f5d1efa0352",
"assets/AssetManifest.bin.json": "59e262104670701a774a9aa91ffe9148",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/assets/checklists/pre_night_de.json": "fdb4fb7a84e77e181f5cb321cb6bfc73",
"assets/assets/wissen_en/wearables_detection_en.md": "8174df1f9642e6450cfc4c18f8b9f83a",
"assets/assets/wissen_en/techniques_en.md": "eecf4830f78e8a418979004968c7d0cf",
"assets/assets/wissen_en/ethics_risks_en.md": "bbf38e7cbfc34a574dc3c65bbc0c58e5",
"assets/assets/wissen_en/nightmare_irt_en.md": "e2fe1f5163f5f24075aa302cd0febdbb",
"assets/assets/wissen_en/basics_en.md": "1b69c865efc51a2e48f155670575fae5",
"assets/assets/wissen_en/troubleshooting_en.md": "385960ee291ef74d82cb222e1a2f8ff6",
"assets/assets/wissen_en/glossary_en.md": "e99f8b70f01c15efe3167242fc89e1d7",
"assets/assets/wissen_en/faq_en.md": "8bb656807ff7661f0a0d3654e366f2d4",
"assets/assets/wissen_en/citations_en.md": "c370260388cd68de1a79855d3790e565",
"assets/assets/wissen_en/neuro_sleep_en.md": "f61a662ea85a8a2afd9da0b771b47439",
"assets/assets/wissen_en/journal_guide_en.md": "f13b71a6d0dd39c25b8bcd9c8b6800ce",
"assets/assets/brand/hero_bg.webp": "277b9bffd4c87b7c70f6ecb193030c0e",
"assets/assets/wissen/nightmare_irt_de.md": "a1cd3df0de70af8d49de85130a52125f",
"assets/assets/wissen/citations_de.md": "35788896158de4d0d7379b9f9d4aefb3",
"assets/assets/wissen/grundlagen_de.md": "d1ca4bf056769fd1380681c8cc611245",
"assets/assets/wissen/journal_guide_de.md": "ddc747e42a83a62faa6e5b341a5db2b8",
"assets/assets/wissen/troubleshooting_de.md": "dc6c2cdac0d754553972d165b2b2bea8",
"assets/assets/wissen/ethics_risks_de.md": "e4670d790f837329b994cb1c321a9f40",
"assets/assets/wissen/faq_de.md": "50b30d74aac1ef8038f4ca9cb295f022",
"assets/assets/wissen/neuro_sleep_de.md": "f3eec52e93e79f2d36b993949e3dc0f8",
"assets/assets/wissen/wearables_detection_de.md": "8ea76f7f5447ea970d375a7dd43c46fc",
"assets/assets/wissen/klartraum_grundlagen_de.md": "96d80e08f80bffd2df1c18897fe626b1",
"assets/assets/wissen/techniken_de.md": "eaa2f474423a10abcbbad897517f5622",
"assets/assets/wissen/glossary_de.md": "52acd85d277274362a649a4d200a4753",
"assets/assets/quizzes/techniken_de.json": "0e802e209722e21ac80d908826152ac9"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
