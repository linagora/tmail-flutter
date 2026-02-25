(function() {
  const originalCreateElement = document.createElement;

    function shouldBlockSentryUrl(urlString) {
      if (!urlString) {
        return false;
      }
      try {
        const parsed = new URL(urlString, document.baseURI);
        const hostname = (parsed.hostname || '').toLowerCase();
        return hostname === 'sentry-cdn.com' || hostname.endsWith('.sentry-cdn.com');
      } catch (e) {
       // Fallback for non-standard or non-parseable URLs:
       // treat plain host-like strings consistently with the hostname check above.
       const str = String(urlString).trim().toLowerCase();
       // Only apply the check to host-like values (no spaces and no obvious path/query fragments).
       const isHostLike = str !== '' && !/\s/.test(str) && !/[\/?#]/.test(str);
       if (!isHostLike) {
         return false;
       }
       return str === 'sentry-cdn.com' || str.endsWith('.sentry-cdn.com');
      }
    }

  document.createElement = function(tagName, options) {
    const element = originalCreateElement.call(document, tagName, options);

    if (tagName === 'script' || tagName === 'SCRIPT') {
      const originalSetAttribute = element.setAttribute;

      Object.defineProperty(element, 'src', {
        set: function(val) {
          const urlString = val ? String(val) : '';

          if (shouldBlockSentryUrl(urlString)) {
            console.log('[Sentry Interceptor] 🛑 Blocked CDN request (Property):', urlString);
            setTimeout(() => this.dispatchEvent(new Event('load')), 10);
          } else {
            originalSetAttribute.call(this, 'src', val);
          }
        },
        get: function() {
          return this.getAttribute('src') || '';
        }
      });

      element.setAttribute = function(name, value) {
        if (name === 'src' || name === 'SRC') {
          const urlString = value ? String(value) : '';

          if (shouldBlockSentryUrl(urlString)) {
            console.log('[Sentry Interceptor] 🛑 Blocked CDN request (Attribute):', urlString);
            setTimeout(() => this.dispatchEvent(new Event('load')), 10);
            return;
          }
        }
        originalSetAttribute.call(this, name, value);
      };
    }
    
    return element;
  };
})();