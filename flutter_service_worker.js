'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter_bootstrap.js": "45edb17bdd912f3cef5107edc380419b",
"version.json": "424897348b4aaecf58e8c7da74983364",
"index.html": "70ea7420b1c491f62015a17ea69ddb15",
"/": "70ea7420b1c491f62015a17ea69ddb15",
"main.dart.js": "b3a83dc5440bd5927dea1b327704bb82",
"flutter.js": "76f08d47ff9f5715220992f993002504",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"manifest.json": "ebab2514385bfb02770423a98263699c",
"assets/Agora_Web_SDK_FULL/favicon.ico": "6464eb4bd09af54c697617040dd74209",
"assets/Agora_Web_SDK_FULL/index.html": "e7cd3e59daaeaf9f057f107afae6feab",
"assets/Agora_Web_SDK_FULL/AgoraRTC_N-4.23.2.js": "f86c6acf46d30911562bb4e85fcc10a6",
"assets/Agora_Web_SDK_FULL/index.js": "2e9c9dccc03d10ad8d6655dd0fec134c",
"assets/Agora_Web_SDK_FULL/index.css": "475ea403ed9407583d83a1d61fe75cd8",
"assets/Agora_Web_SDK_FULL/indexandjs.html": "5a0cbaef0c94c16c7e37c0d15b9720ee",
"assets/Agora_Web_SDK_FULL/vendor/bootstrap.min.css": "7cc40c199d128af6b01e74a28c5900b0",
"assets/Agora_Web_SDK_FULL/vendor/bootstrap.bundle.min.js": "a5334e475209f965b4862f3bedf32618",
"assets/Agora_Web_SDK_FULL/vendor/jquery-3.4.1.min.js": "f832e36068ab203a3f89b1795480d0d7",
"assets/AssetManifest.json": "f79f53602680cf215bb660516b001c7f",
"assets/new_live_sy/icon_02.json": "6f61c6569457f07fd35ca40b8bdefca5",
"assets/new_live_sy/kaibo.png": "022ed8ed23eaf2339138ccb551484363",
"assets/new_live_sy/images.jpeg": "1d8e9bd0314f6638e707562434eb62e2",
"assets/new_live_sy/icon_03.json": "07414db3c6e0d658593a020fb7c3aca1",
"assets/new_live_sy/gz_tj_icon.png": "8a2ceb3e14399694ce82a219f495b10b",
"assets/new_live_sy/icon_04.json": "349b276d7c880acf4e7635f7b02c9d47",
"assets/new_live_sy/paihangbang.png": "7e25f3bd5d8861ea23450542c32bd907",
"assets/new_live_sy/gntj_zw.png": "a36e6ef240d6cf5aadb49fdf88e4a676",
"assets/new_live_sy/icon_03B1.json": "e5410af8a03f9a5b7c9a9c4b5d3632ce",
"assets/new_live_sy/search_icon.png": "3848d6e627f9da5f11e56cb4fdf544b5",
"assets/new_live_sy/icon_05.json": "5801797130db007c4b7b3500a00eacca",
"assets/new_live_sy/search.png": "b3d82bb060d01c74c5de03a118e74b29",
"assets/new_live_sy/icon_06.json": "b3d19469af9b15131cebca4f4bed95eb",
"assets/new_live_sy/no_content.png": "3f21d64f0196e6112711073572b93e92",
"assets/new_live_sy/icon_07.json": "1a7fb8c617968ca07e85ccb04bd89c83",
"assets/new_live_sy/new_live_sy_no_content.png": "f7de107bee3bd90891c78fbe05151799",
"assets/new_live_sy/gz_icon.png": "56e1273b8ce14b1ba5d1fb205e98820e",
"assets/new_live_sy/icon_01.json": "d4ff1b027beb45195e6399b8e37bd2f6",
"assets/new_live_sy/live_sy_pmd_bg.png": "2f4353a61f53d3dd9981044f4036157d",
"assets/NOTICES": "917553dd3c92ba92ebac5edc0912fde3",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/AssetManifest.bin.json": "bfd45f34f0e7d7427a4168b2ca99147a",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/packages/flutter_inappwebview_web/assets/web/web_support.js": "509ae636cfdd93e49b5a6eaf0f06d79f",
"assets/packages/flutter_inappwebview/assets/t_rex_runner/t-rex.css": "5a8d0222407e388155d7d1395a75d5b9",
"assets/packages/flutter_inappwebview/assets/t_rex_runner/t-rex.html": "16911fcc170c8af1c5457940bd0bf055",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/zw_title.png": "5c0201169c916c7313019f0734829392",
"assets/AssetManifest.bin": "c80f7150eaad6b78442e4a29a64feffa",
"assets/fonts/MaterialIcons-Regular.otf": "bfb45e33e15b192cce0319d61b44cdb4",
"canvaskit/skwasm_st.js": "d1326ceef381ad382ab492ba5d96f04d",
"canvaskit/skwasm.js": "f2ad9363618c5f62e813740099a80e63",
"canvaskit/skwasm.js.symbols": "80806576fa1056b43dd6d0b445b4b6f7",
"canvaskit/canvaskit.js.symbols": "68eb703b9a609baef8ee0e413b442f33",
"canvaskit/skwasm.wasm": "f0dfd99007f989368db17c9abeed5a49",
"canvaskit/chromium/canvaskit.js.symbols": "5a23598a2a8efd18ec3b60de5d28af8f",
"canvaskit/chromium/canvaskit.js": "34beda9f39eb7d992d46125ca868dc61",
"canvaskit/chromium/canvaskit.wasm": "64a386c87532ae52ae041d18a32a3635",
"canvaskit/skwasm_st.js.symbols": "c7e7aac7cd8b612defd62b43e3050bdd",
"canvaskit/canvaskit.js": "86e461cf471c1640fd2b461ece4589df",
"canvaskit/canvaskit.wasm": "efeeba7dcc952dae57870d4df3111fad",
"canvaskit/skwasm_st.wasm": "56c3973560dfcbf28ce47cebe40f3206"};
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
