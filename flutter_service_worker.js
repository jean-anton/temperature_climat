'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter_bootstrap.js": "35fe93aff45e8be52ce7c479fd9b2a01",
"version.json": "2778927de5c1b3c0019af9ae3c21bcfe",
"index.html": "29ef05d8e6abdac1b540a187cfd6ed19",
"/": "29ef05d8e6abdac1b540a187cfd6ed19",
"main.dart.js": "e35ebdb8fa59ef2ef39b0e207ae6e3f5",
"flutter.js": "83d881c1dbb6d6bcd6b42e274605b69c",
"favicon.png": "7e71b625975838742e5693c6323a8406",
"icons/Icon-192.png": "f893ebf086583ba14add7642d68a9c03",
"icons/Icon-maskable-192.png": "f893ebf086583ba14add7642d68a9c03",
"icons/Icon-maskable-512.png": "372ca671b1e8784f2b9ed72ad3374201",
"icons/Icon-512.png": "372ca671b1e8784f2b9ed72ad3374201",
"manifest.json": "7b861741d9f20ab3ac8c58ee06a6156c",
"assets/AssetManifest.json": "5e467ba0303b750e81b8feeac2d0833b",
"assets/NOTICES": "daaff9bd02e402f720b9861ab157b797",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/AssetManifest.bin.json": "d8b702544263b25931e6959266c5844f",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.bin": "03be4226cce54bcd9a7c019b568ddf38",
"assets/fonts/MaterialIcons-Regular.otf": "c079a1c238a51c7fb0d0461ba1241611",
"assets/assets/google_weather_icons/v4/snow_with_cloudy_light.svg": "a0584597bf9025c2374b102ad347f51e",
"assets/assets/google_weather_icons/v4/icy.svg": "1ecc9dc29e309324c51c4ef3a77dbaa2",
"assets/assets/google_weather_icons/v4/moderate_rain_showers.svg": "1482d5702338626044c7e1e5943cbe7e",
"assets/assets/google_weather_icons/v4/tropical_storm_hurricane.svg": "fd2be5dac09e0b9d517fc910fca35482",
"assets/assets/google_weather_icons/v4/windy.svg": "f19b7c1f0796762b5a163db7602cbd00",
"assets/assets/google_weather_icons/v4/isolated_scattered_thunderstorms_day.svg": "2f726b853c3f03c6181df2521441bb7e",
"assets/assets/google_weather_icons/v4/slight_snow.svg": "bacea524081014f81b8c29634254a731",
"assets/assets/google_weather_icons/v4/rain_with_cloudy_light.svg": "fdbc92563ebcd34af52bfefcc5b6aa73",
"assets/assets/google_weather_icons/v4/sunny_with_cloudy_light.svg": "111ee3a20e96447dc4949f03c89c0f32",
"assets/assets/google_weather_icons/v4/umbrella.svg": "5d4e1ffa0e37a41962c1275f86f88146",
"assets/assets/google_weather_icons/v4/rain_with_sunny_light.svg": "6add86a99189ddb079b82a1022613ccd",
"assets/assets/google_weather_icons/v4/showers_snow.svg": "fee84f5cb9756564496adc631c0288d4",
"assets/assets/google_weather_icons/v4/very_hot.svg": "a906bd825969a41eca75e2d17885fc49",
"assets/assets/google_weather_icons/v4/snow_with_sunny_light.svg": "93eba3eb6e080982c1d5d0a1e717c5ab",
"assets/assets/google_weather_icons/v4/cloudy_with_rain_light.svg": "6d50a72a6c0ca5ab1b505c7334d7b861",
"assets/assets/google_weather_icons/v4/snow_with_rain_light.svg": "db5e29aea340ca2c3f792081b0d38b0a",
"assets/assets/google_weather_icons/v4/tornado.svg": "8cb61c28d22b47be1c0778d751011c48",
"assets/assets/google_weather_icons/v4/mixed_rain_snow.svg": "ab01723377d0c1cfae0fb95850d24d60",
"assets/assets/google_weather_icons/v4/mostly_cloudy_day.svg": "37871399465d85ca177c0071730aaf25",
"assets/assets/google_weather_icons/v4/heavy_snow.svg": "b1f6d071867b6ba5f9e8baba0d3d56ec",
"assets/assets/google_weather_icons/v4/scattered_snow_showers_day.svg": "5f45aff1d4fb2b5820eb6358da453c02",
"assets/assets/google_weather_icons/v4/scattered_showers_day.svg": "f2ef7e8140c2435201b6bf6cce90ec64",
"assets/assets/google_weather_icons/v4/slight_rain_showers.svg": "b48a7099cbffd2e6953b508e75667280",
"assets/assets/google_weather_icons/v4/partly_cloudy_day.svg": "a51edb721d94941c90f87d5912a5c197",
"assets/assets/google_weather_icons/v4/cloudy_with_sunny_light.svg": "01c15a673b0537c81ec132a97e21624c",
"assets/assets/google_weather_icons/v4/sunny_with_rain_light.svg": "bce4519e43746b648256127a500f20ec",
"assets/assets/google_weather_icons/v4/mostly_clear_day.svg": "05022abb50adb1756dc07ff961ca756a",
"assets/assets/google_weather_icons/v4/mixed_rain_hail_sleet.svg": "00fcc178e42cf45a776413c5ef0eaf93",
"assets/assets/google_weather_icons/v4/sleet_hail.svg": "ca11de070e20d84d86bd4d45cbee9bbf",
"assets/assets/google_weather_icons/v4/moderate_drizzle.svg": "84e6d80a4824ef7c0d7df5013b221d88",
"assets/assets/google_weather_icons/v4/showers_rain.svg": "a2febf601016afaa23056eb97505caf1",
"assets/assets/google_weather_icons/v4/drizzle.svg": "a906ea648e6fc6f6207984dc79e70d44",
"assets/assets/google_weather_icons/v4/sunny_with_snow_light.svg": "3cccbaeabc55975aa4d4d31b35570111",
"assets/assets/google_weather_icons/v4/flurries.svg": "bacea524081014f81b8c29634254a731",
"assets/assets/google_weather_icons/v4/very_cold.svg": "d0c9850ae8342485666902cb892eebc4",
"assets/assets/google_weather_icons/v4/isolated_thunderstorms.svg": "255d629e772716bbc8b3fc7a6aa20a21",
"assets/assets/google_weather_icons/v4/slight_rain.svg": "a906ea648e6fc6f6207984dc79e70d44",
"assets/assets/google_weather_icons/v4/blowing_snow.svg": "595ee77f77d9e4d4dd8710379ed435d2",
"assets/assets/google_weather_icons/v4/heavy_rain.svg": "3d06fb2222eec018e3184373857dbc2c",
"assets/assets/google_weather_icons/v4/strong_thunderstorms.svg": "d336b05073939b66e3e66bcba725a28e",
"assets/assets/google_weather_icons/v4/cloudy_with_snow_light.svg": "db698a8ac559e4f24df28b216b3b89e1",
"assets/assets/google_weather_icons/v4/blizzard.svg": "3a5779e27bfda0ccf75067bea3e15b47",
"assets/assets/google_weather_icons/v4/light_drizzle.svg": "f73b6a82f5bd45dd9dadcd5151c42fc2",
"assets/assets/google_weather_icons/v4/dense_drizzle.svg": "8cd2867ef39999f888f15d3b394a3d7b",
"assets/assets/google_weather_icons/v4/rain_with_snow_light.svg": "aa0e557c855efc206b525a9ea4293d0c",
"assets/assets/google_weather_icons/v4/cloudy.svg": "d90284e2092644cf6ec39a57b3ce5bc7",
"assets/assets/google_weather_icons/v4/clear_day.svg": "071dabc4b19c140c856956ed4d78601e",
"assets/assets/google_weather_icons/v4/haze_fog_dust_smoke.svg": "2ae216c574222d5906105b8970109430",
"assets/assets/google_weather_icons/v4/violent_rain_showers.svg": "b72b1f1bfd2a4d9f987766091417ef0d",
"assets/assets/data/climatologie_sarrebruck_04336.csv": "f83a131134771b852e3a7363d1b26265",
"assets/assets/data/climatologie_berus_00460.csv": "6cc0dd7b478938db6700a11062f4d049",
"canvaskit/skwasm.js": "ea559890a088fe28b4ddf70e17e60052",
"canvaskit/skwasm.js.symbols": "e72c79950c8a8483d826a7f0560573a1",
"canvaskit/canvaskit.js.symbols": "bdcd3835edf8586b6d6edfce8749fb77",
"canvaskit/skwasm.wasm": "39dd80367a4e71582d234948adc521c0",
"canvaskit/chromium/canvaskit.js.symbols": "b61b5f4673c9698029fa0a746a9ad581",
"canvaskit/chromium/canvaskit.js": "8191e843020c832c9cf8852a4b909d4c",
"canvaskit/chromium/canvaskit.wasm": "f504de372e31c8031018a9ec0a9ef5f0",
"canvaskit/canvaskit.js": "728b2d477d9b8c14593d4f9b82b484f3",
"canvaskit/canvaskit.wasm": "7a3f4ae7d65fc1de6a6e7ddd3224bc93"};
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
