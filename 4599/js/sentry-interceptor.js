(function() {
  // Guard against double-execution (e.g. duplicate script tag, hot-reload).
  // On a second load, nativeSrcDescriptor would resolve to our already-patched
  // setter instead of the native one, causing infinite recursion.
  if (window.__sentryInterceptorActive) return;
  window.__sentryInterceptorActive = true;

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
    Promise.resolve().then(() => element.dispatchEvent(new Event('load')));
  }

  // sentry_flutter's web_script_dom_api.dart creates script elements via
  // `new HTMLScriptElement()` (Dart package:web interop), which bypasses
  // document.createElement entirely. We must patch the prototype-level src
  // setter to intercept ALL HTMLScriptElement src assignments universally.
  const nativeSrcDescriptor = Object.getOwnPropertyDescriptor(HTMLScriptElement.prototype, 'src');
  const canPatchSrc =
    nativeSrcDescriptor &&
    typeof nativeSrcDescriptor.get === 'function' &&
    typeof nativeSrcDescriptor.set === 'function' &&
    nativeSrcDescriptor.configurable === true;

  if (canPatchSrc) {
    try {
      Object.defineProperty(HTMLScriptElement.prototype, 'src', {
        configurable: true,
        enumerable: nativeSrcDescriptor.enumerable,
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
    } catch (e) {
      console.warn('[Sentry Interceptor] Failed to patch HTMLScriptElement.src:', e);
    }
  } else {
    console.warn('[Sentry Interceptor] HTMLScriptElement.src patch unavailable; using setAttribute fallback only.');
  }

  // Defense-in-depth: also intercept setAttribute('src', ...) as a fallback.
  // Patched on HTMLScriptElement.prototype only (not Element) to avoid
  // intercepting setAttribute on every element in the DOM.
  const originalSetAttribute = Element.prototype.setAttribute;
  try {
    Object.defineProperty(HTMLScriptElement.prototype, 'setAttribute', {
      configurable: true,
      writable: true,
      value: function(name, value) {
        if (String(name).toLowerCase() === 'src') {
          const urlString = String(value || '');
          if (shouldBlockSentryUrl(urlString)) {
            blockAndNotify(this, 'setAttribute', urlString);
            return;
          }
        }
        originalSetAttribute.call(this, name, value);
      },
    });
  } catch (e) {
    console.warn('[Sentry Interceptor] Failed to patch HTMLScriptElement.setAttribute:', e);
  }
})();
