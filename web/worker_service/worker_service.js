const androidStore = 'https://play.google.com/store/apps/details?id=com.linagora.android.teammail';
const iosStore = 'https://apps.apple.com/vn/app/twake-mail/id1587086189';
const iosPlatform = 'iOS';
const androidPlatform = 'android';
const otherPlatform = 'other';
var serviceWorkerVersion = null;
var scriptLoaded = false;

function loadMainDartJs() {
  if (scriptLoaded) {
    return;
  }
  scriptLoaded = true;
  var scriptTag = document.createElement('script');
  scriptTag.src = 'main.dart.js';
  scriptTag.type = 'application/javascript';
  document.body.append(scriptTag);
}

function fetchServiceWorker() {
if ('serviceWorker' in navigator) {
  // Service workers are supported. Use them.
  // Wait for registration to finish before dropping the <script>tag.
  // Otherwise, the browser will load the script multiple times,
  // potentially different versions.
  navigator.serviceWorker.register('firebase-messaging-sw.js').then(serviceWorkerRegistration => {
    console.info('[TwakeMail] fetchServiceWorker(): Service worker firebase-messaging was registered.');
  }).catch(error => {
    console.error(
      '[TwakeMail] fetchServiceWorker(): An error occurred while registering the service worker firebase-messaging.'
      );
    console.error(error);
  });
  var serviceWorkerUrl = 'flutter_service_worker.js?v=' + serviceWorkerVersion;
  navigator.serviceWorker.register(serviceWorkerUrl)
    .then((reg) => {
      function waitForActivation(serviceWorker) {
        serviceWorker.addEventListener('statechange', () => {
          if (serviceWorker.state == 'activated') {
            console.log('[TwakeMail] fetchServiceWorker(): Installed new service worker.');
            loadMainDartJs();
          }
        });
      }
      if (!reg.active && (reg.installing || reg.waiting)) {
        // No active web worker and we have installed or are installing
        // one for the first time. Simply wait for it to activate.
        waitForActivation(reg.installing || reg.waiting);
      } else if (!reg.active.scriptURL.endsWith(serviceWorkerVersion)) {
        // When the app updates the serviceWorkerVersion changes, so we
        // need to ask the service worker to update.
        console.log('[TwakeMail] fetchServiceWorker(): New service worker available.');
        reg.update();
        waitForActivation(reg.installing);
      } else {
        // Existing service worker is still good.
        console.log('[TwakeMail] fetchServiceWorker(): Loading app from service worker.');
        loadMainDartJs();
      }
    });
  // If service worker doesn't succeed in a reasonable amount of time,
  // fallback to plaint <script> tag.
  setTimeout(() => {
    if (!scriptLoaded) {
      console.warn(
        '[TwakeMail] fetchServiceWorker(): Failed to load app from service worker. Falling back to plain <script> tag.',
      );
      loadMainDartJs();
    }
  }, 4000);
  }
  else {
    // Service workers not supported. Just drop the <script> tag.
    loadMainDartJs();
  }
  }

  function handleContinueTwakeMailOnWeb() {
    console.info('[TwakeMail] handleContinueTwakeMailOnWeb(): Continue on web.');
    closeBottomSheet();
    fetchServiceWorker();
  }

  function getPlatform() {
    console.info('[TwakeMail] getPlatform(): ', navigator.userAgent);
    if (/iPhone|iPad|iPod/i.test(navigator.userAgent)) {
      return iosPlatform;
    }
    if (/Android/i.test(navigator.userAgent)) {
      return androidPlatform;
    }
    return otherPlatform;
  }

  function hanldeOpenTwakeMailApp() {
    const os = getPlatform();
    console.info('[TwakeMail] hanldeOpenTwakeMailApp() - OS:', os);
    if (os === androidPlatform) {
      document.location.replace(androidStore);
    } else if (os === iosPlatform) {
      document.location.replace(iosStore);
    }
  }

  function initialWorkerService() {
    const os = getPlatform();
    const searchParams = Object.fromEntries(
      new URLSearchParams(window.location.search),
    );
    const originInUrl = searchParams.origin;
    //   For desktop, we don't show the open on app popup
    if (os === otherPlatform || typeof window === 'undefined') {
      if (os !== otherPlatform) {
        console.log('[TwakeMail] initialWorkerService(): Keep on browser because:', {
          os,
          originInUrl,
          windowUndefined: typeof window === 'undefined',
        });
      }
      fetchServiceWorker();
      return;
    }
    console.log('[TwakeMail] initialWorkerService(): Open the bottom sheet.');
    const bottomSheet = document.querySelector(".bottom-sheet");
    bottomSheet.style.display = "block";
    document.body.style.overflow = "hidden";
    bottomSheet.style.bottom = "0";
  }

  function closeBottomSheet() {
    console.info('[TwakeMail] closeBottomSheet(): Closing the bottom sheet.');
    const bottomSheet = document.querySelector(".bottom-sheet");
    bottomSheet.style.display = "none";
    document.body.style.overflow = "auto";
    bottomSheet.style.bottom = "-100%";
  }