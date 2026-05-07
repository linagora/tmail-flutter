(function() {
  const originalCreateElement = document.createElement;

  // Only block the specific tracing bundle we self-host. Narrowing to this pathname
  // prevents silently swallowing future CDN assets that have no local replacement.
  const BLOCKED_PATHNAME = '/bundle.tracing.min.js';

  function isSentryCdnHostname(hostname) {
    return hostname === 'sentry-cdn.com' || hostname.endsWith('.sentry-cdn.com');
  }

  function shouldBlockSentryUrl(urlString) {
    if (!urlString) return false;
    try {
      const parsed = new URL(urlString, document.baseURI);
      const hostname = parsed.hostname.toLowerCase();
      const pathname = parsed.pathname.toLowerCase();
      return isSentryCdnHostname(hostname) && pathname.endsWith(BLOCKED_PATHNAME);
    } catch (e) {
      // Fallback for non-parseable URLs: check if it looks like a plain hostname
      // (no whitespace, no path/query/fragment separators).
      const str = String(urlString).trim().toLowerCase();
      const isHostLike = str.length > 0 && !/[\s/?#]/.test(str);
      return isHostLike && isSentryCdnHostname(str);
    }
  }

  function blockAndNotify(element, channel, urlString) {
    console.log('[Sentry Interceptor] 🛑 Blocked CDN request (' + channel + '):', urlString);
    // Fire a synthetic 'load' event so the Sentry SDK's internal Promise resolves
    // cleanly instead of hanging indefinitely waiting for a CDN script we blocked.
    setTimeout(() => element.dispatchEvent(new Event('load')), 10);
  }

  function makeSrcSetter(nativeSrcDescriptor) {
    return function(val) {
      const urlString = val ? String(val) : '';
      if (shouldBlockSentryUrl(urlString)) {
        blockAndNotify(this, 'Property', urlString);
      } else {
        nativeSrcDescriptor?.set?.call(this, val);
      }
    };
  }

  function makeSrcGetter(nativeSrcDescriptor) {
    return function() {
      return nativeSrcDescriptor?.get?.call(this) ?? '';
    };
  }

  function makeSetAttribute(originalSetAttribute) {
    return function(name, value) {
      const urlString = value ? String(value) : '';
      if (String(name).toLowerCase() === 'src' && shouldBlockSentryUrl(urlString)) {
        blockAndNotify(this, 'Attribute', urlString);
        return;
      }
      originalSetAttribute.call(this, name, value);
    };
  }

  function patchScriptElement(element) {
    const nativeSrcDescriptor = Object.getOwnPropertyDescriptor(HTMLScriptElement.prototype, 'src');
    Object.defineProperty(element, 'src', {
      configurable: true,
      set: makeSrcSetter(nativeSrcDescriptor),
      get: makeSrcGetter(nativeSrcDescriptor),
    });
    element.setAttribute = makeSetAttribute(element.setAttribute);
  }

  // Load order: sentry-tracing.min.js (self-hosted SDK) must run before this interceptor.
  // This interceptor patches document.createElement to block any subsequent CDN injection
  // the SDK may attempt at runtime.
  document.createElement = function(tagName, options) {
    const element = originalCreateElement.call(document, tagName, options);
    if (String(tagName).toLowerCase() === 'script') {
      patchScriptElement(element);
    }
    return element;
  };
})();
