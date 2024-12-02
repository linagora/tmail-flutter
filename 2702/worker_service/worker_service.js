const androidStore = 'https://play.google.com/store/apps/details?id=com.linagora.android.teammail';
const iosStore = 'https://apps.apple.com/app/twake-mail/id1587086189';
const iosPlatform = 'iOS';
const androidPlatform = 'android';
const otherPlatform = 'other';

function handleContinueTwakeMailOnWeb() {
  console.info('[TwakeMail] handleContinueTwakeMailOnWeb(): Continue on web.');
  closeSmartBanner();
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

function initialTmailApp() {
  const os = getPlatform();
  const originInUrl = window.location;

  console.info('[TwakeMail] initialWorkerService(): OriginInUrl:', originInUrl);

  //   For desktop, we don't show the open on app popup
  if (os === otherPlatform || typeof window === 'undefined') {
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