(function() {
  const originalCreateElement = document.createElement;
  
  document.createElement = function(tagName, options) {
    const element = originalCreateElement.call(document, tagName, options);

    if (tagName === 'script' || tagName === 'SCRIPT') {
      const originalSetAttribute = element.setAttribute;

      Object.defineProperty(element, 'src', {
        set: function(val) {
          const urlString = val ? String(val) : '';

          if (urlString.includes('sentry-cdn.com')) {
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

          if (urlString.includes('sentry-cdn.com')) {
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