const androidStore = 'https://play.google.com/store/apps/details?id=com.linagora.android.teammail';
const iosStore = 'https://apps.apple.com/app/twake-mail/id1587086189';
const iosPlatform = 'iOS';
const androidPlatform = 'android';
const otherPlatform = 'other';
const timeoutDuration = 4000;
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
    navigator.serviceWorker.register('web-sockets-worker.js')
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
    }, timeoutDuration);
  } else {
    // Service workers not supported. Just drop the <script> tag.
    loadMainDartJs();
  }
}

function handleContinueTwakeMailOnWeb() {
  console.info('[TwakeMail] handleContinueTwakeMailOnWeb(): Continue on web.');
  closeSmartBanner();
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

function handleOpenTwakeMailApp() {
  const os = getPlatform();
  console.info('[TwakeMail] handleOpenTwakeMailApp() - OS:', os);
  if (os === androidPlatform) {
    document.location.replace(androidStore);
  } else if (os === iosPlatform) {
    document.location.replace(iosStore);
  }
}

function initialWorkerService() {
  const os = getPlatform();
  const originInUrl = window.location;

  console.info('[TwakeMail] initialWorkerService(): OriginInUrl:', originInUrl);

  //   For desktop, we don't show the open on app popup
  if (os === otherPlatform || typeof window === 'undefined') {
    fetchServiceWorker();
    return;
  }

  if (window.location.pathname.includes('/login')) {
    console.info('[TwakeMail] initialWorkerService(): Login callback');
    handleContinueTwakeMailOnWeb();
  } else {
    openSmartBanner();
  }
}

function openSmartBanner() {
  console.info('[TwakeMail] openSmartBanner(): Open the smart banner.');
  const smartBanner = document.querySelector(".smart-banner");
  smartBanner.style.display = "block";
  document.body.style.overflow = "hidden";
  smartBanner.style.top = "16px";
}

function closeSmartBanner() {
  console.info('[TwakeMail] closeSmartBanner(): Closing the smart banner.');
  const smartBanner = document.querySelector(".smart-banner");
  smartBanner.style.display = "none";
  document.body.style.overflow = "auto";
  smartBanner.style.top = 0;
}