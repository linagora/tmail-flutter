(function() {
  const BLOCKED_PATHNAME = '/bundle.tracing.min.js';

  function isSentryCdnHostname(hostname) {
    return hostname === 'sentry-cdn.com' || hostname.endsWith('.sentry-cdn.com');
  }

  function shouldBlockSentryUrl(urlString) {
    if (!urlString) return false;
    try {
      const parsed = new URL(urlString, document.baseURI);
      return isSentryCdnHostname(parsed.hostname.toLowerCase()) &&
             parsed.pathname.toLowerCase().endsWith(BLOCKED_PATHNAME);
    } catch (e) {
      return false;
    }
  }

  function blockAndNotify(element, channel, urlString) {
    console.log('[Sentry Interceptor] 🛑 Blocked CDN request (' + channel + '):', urlString);
    // Dispatch a synthetic 'load' event so the Sentry SDK's internal Promise
    // resolves cleanly instead of hanging indefinitely.
    setTimeout(() => element.dispatchEvent(new Event('load')), 10);
  }

  // sentry_flutter's web_script_dom_api.dart creates script elements via
  // `new HTMLScriptElement()` (Dart package:web interop), which bypasses
  // document.createElement entirely. We must patch the prototype-level src
  // setter to intercept ALL HTMLScriptElement src assignments universally.
  const nativeSrcDescriptor = Object.getOwnPropertyDescriptor(HTMLScriptElement.prototype, 'src');
  Object.defineProperty(HTMLScriptElement.prototype, 'src', {
    configurable: true,
    enumerable: true,
    get: function() {
      return nativeSrcDescriptor.get.call(this);
    },
    set: function(val) {
      const urlString = val ? String(val) : '';
      if (shouldBlockSentryUrl(urlString)) {
        blockAndNotify(this, 'HTMLScriptElement.src', urlString);
        return;
      }
      nativeSrcDescriptor.set.call(this, val);
    },
  });

  // Defense-in-depth: also intercept setAttribute('src', ...) as a fallback.
  const originalSetAttribute = Element.prototype.setAttribute;
  Element.prototype.setAttribute = function(name, value) {
    const urlString = value ? String(value) : '';
    const isScriptSrc = this instanceof HTMLScriptElement && String(name).toLowerCase() === 'src';
    if (isScriptSrc && shouldBlockSentryUrl(urlString)) {
      blockAndNotify(this, 'setAttribute', urlString);
      return;
    }
    originalSetAttribute.call(this, name, value);
  };
})();
