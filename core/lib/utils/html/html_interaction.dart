class HtmlInteraction {
  static const String scrollRightEndAction = 'ScrollRightEndAction';
  static const String scrollLeftEndAction = 'ScrollLeftEndAction';
  static const String scrollEventJSChannelName = 'ScrollEventListener';
  static const String contentSizeChangedEventJSChannelName =
      'ContentSizeChangedEventListener';
  static const String iframeFindShortcutEvent = 'iframeFindShortcut';
  static const String iframeFindResultEvent = 'iframeFindResult';
  static const String iframeFindApplyEvent = 'findApply';
  static const String iframeFindNextEvent = 'findNext';
  static const String iframeFindPreviousEvent = 'findPrevious';
  static const String iframeFindClearEvent = 'findClear';

  static const String runScriptsHandleScrollEvent =
      '''
    let contentElement = document.getElementsByClassName('tmail-content')[0];
    var xDown = null;                                                        
    var yDown = null;
    
    contentElement.addEventListener('touchstart', handleTouchStart, false);
    contentElement.addEventListener('touchmove', handleTouchMove, false);
    
    function getTouches(evt) {
      return evt.touches || evt.originalEvent.touches;
    }                                                     
                                                                             
    function handleTouchStart(evt) {
      const firstTouch = getTouches(evt)[0];                                      
      xDown = firstTouch.clientX;                                      
      yDown = firstTouch.clientY;                                     
    }                                               
                                                                             
    function handleTouchMove(evt) {
      if (!xDown || !yDown) {
        return;
      }
  
      var xUp = evt.touches[0].clientX;                                    
      var yUp = evt.touches[0].clientY;
  
      var xDiff = xDown - xUp;
      var yDiff = yDown - yUp;
                                                                           
      if (Math.abs(xDiff) > Math.abs(yDiff)) {
        let newScrollLeft = contentElement.scrollLeft;
        let scrollWidth = contentElement.scrollWidth;
        let offsetWidth = contentElement.offsetWidth;
        let maxOffset = Math.round(scrollWidth - offsetWidth);
        let scrollLeftRounded = Math.round(newScrollLeft);
         
        if (xDiff > 0) {
          if (maxOffset === scrollLeftRounded || 
              maxOffset === (scrollLeftRounded + 1) || 
              maxOffset === (scrollLeftRounded - 1)) {
            window.flutter_inappwebview.callHandler('$scrollEventJSChannelName', '$scrollRightEndAction');
          }
        } else {
          if (scrollLeftRounded === 0) {
            window.flutter_inappwebview.callHandler('$scrollEventJSChannelName', '$scrollLeftEndAction');
          }
        }                       
      }
      
      xDown = null;
      yDown = null;                                             
    }
  ''';

  static const String scriptsHandleContentSizeChanged =
      '''
    <script type="text/javascript">
      const bodyResizeObserver = new ResizeObserver(entries => {
        window.flutter_inappwebview.callHandler('$contentSizeChangedEventJSChannelName', '');
      })
      
      bodyResizeObserver.observe(document.body)
    </script>
  ''';

  static const String scriptsHandleLazyLoadingBackgroundImage = '''
    <script type="text/javascript">
      const lazyImages = document.querySelectorAll('[lazy]');
      const lazyImageObserver = new IntersectionObserver((entries, observer) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            const lazyImage = entry.target;
            const src = lazyImage.dataset.src;
            lazyImage.tagName.toLowerCase() === 'img'
              ? lazyImage.src = src
              : lazyImage.style.backgroundImage = "url(\'" + src + "\')";
            lazyImage.removeAttribute('lazy');
            observer.unobserve(lazyImage);
          }
        });
      });
      
      lazyImages.forEach((lazyImage) => {
        lazyImageObserver.observe(lazyImage);
      });
    </script>
  ''';

  static const String scriptHandleInvokePrinterOnBrowser = '''
    <script type="text/javascript">
      document.body.onload = function() {
        window.print();
      };
    </script>
  ''';

  static String generateNormalizeImageScript(double displayWidth) {
    return '''
      <script type="text/javascript">
        const displayWidth = $displayWidth;
    
        const sizeUnits = ['px', 'in', 'cm', 'mm', 'pt', 'pc'];
    
        function convertToPx(value, unit) {
          switch (unit.toLowerCase()) {
            case 'px': return value;
            case 'in': return value * 96;
            case 'cm': return value * 37.8;
            case 'mm': return value * 3.78;
            case 'pt': return value * (96 / 72);
            case 'pc': return value * (96 / 6);
            default: return value;
          }
        }
    
        function removeWidthHeightFromStyle(style) {
          // Remove width and height properties from style string
          style = style.replace(/width\\s*:\\s*[\\d.]+[a-zA-Z%]+\\s*;?/gi, '');
          style = style.replace(/height\\s*:\\s*[\\d.]+[a-zA-Z%]+\\s*;?/gi, '');
          style = style.trim();
          if (style.length && !style.endsWith(';')) {
            style += ';';
          }
          return style;
        }
    
        function extractWidthHeightFromStyle(style) {
          // Extract width and height values with units from style string
          const result = {};
          const widthMatch = style.match(/width\\s*:\\s*([\\d.]+)([a-zA-Z%]+)\\s*;?/);
          const heightMatch = style.match(/height\\s*:\\s*([\\d.]+)([a-zA-Z%]+)\\s*;?/);
    
          if (widthMatch) {
            const value = parseFloat(widthMatch[1]);
            const unit = widthMatch[2];
            if (!isNaN(value) && unit) {
              result['width'] = { value, unit };
            }
          }
    
          if (heightMatch) {
            const value = parseFloat(heightMatch[1]);
            const unit = heightMatch[2];
            if (!isNaN(value) && unit) {
              result['height'] = { value, unit };
            }
          }
    
          return result;
        }
    
        function normalizeStyleAttribute(attrs) {
          // Normalize style attribute to ensure proper responsive behavior
          let style = attrs['style'];
          
          if (!style) {
            attrs['style'] = 'max-width:100%;height:auto;display:inline;';
            return;
          }
    
          style = style.trim();
          const dimensions = extractWidthHeightFromStyle(style);
          const hasWidth = dimensions.hasOwnProperty('width');
    
          if (hasWidth) {
            const widthData = dimensions['width'];
            const widthPx = convertToPx(widthData.value, widthData.unit);
    
            if (displayWidth !== undefined &&
                widthPx > displayWidth &&
                sizeUnits.includes(widthData.unit)) {
              style = removeWidthHeightFromStyle(style).trim();
            }
          }
    
          // Ensure proper style string formatting
          if (style.length && !style.endsWith(';')) {
            style += ';';
          }
    
          // Add responsive defaults if missing
          if (!style.includes('max-width')) {
            style += 'max-width:100%;';
          }
    
          if (!style.includes('height')) {
            style += 'height:auto;';
          }
    
          if (!style.includes('display')) {
            style += 'display:inline;';
          }
    
          attrs['style'] = style;
        }
    
        function normalizeWidthHeightAttribute(attrs) {
          // Normalize width/height attributes and remove if necessary
          const widthStr = attrs['width'];
          const heightStr = attrs['height'];
    
          // Remove attribute if value is null or undefined
          if (widthStr === null || widthStr === undefined) {
            delete attrs['width'];
          } else if (displayWidth !== undefined) {
            const widthValue = parseFloat(widthStr);
            if (!isNaN(widthValue)) {
              if (widthValue > displayWidth) {
                delete attrs['width'];
                delete attrs['height'];
              }
            }
          }
    
          // Remove height attribute if value is null or undefined
          if (heightStr === null || heightStr === undefined) {
            delete attrs['height'];
          }
        }
    
        function normalizeImageSize(attrs) {
          // Apply both style and attribute normalization
          normalizeWidthHeightAttribute(attrs);
          normalizeStyleAttribute(attrs);
        }
    
        function applyImageNormalization() {
          // Process all images on the page
          document.querySelectorAll('img').forEach(img => {
            const attrs = {
              style: img.getAttribute('style'),
              width: img.getAttribute('width'),
              height: img.getAttribute('height')
            };
    
            normalizeImageSize(attrs);
    
            // Handle style attribute
            if (attrs.style !== null && attrs.style !== undefined) {
              img.setAttribute('style', attrs.style);
            } else {
              img.removeAttribute('style');
            }
    
            // Handle width attribute
            if ('width' in attrs && attrs.width !== null && attrs.width !== undefined) {
              img.setAttribute('width', attrs.width);
            } else {
              img.removeAttribute('width');
            }
    
            // Handle height attribute
            if ('height' in attrs && attrs.height !== null && attrs.height !== undefined) {
              img.setAttribute('height', attrs.height);
            } else {
              img.removeAttribute('height');
            }
          });
        }
        
        function safeApplyImageNormalization() {
          // Error-safe wrapper for the normalization function
          try {
            applyImageNormalization();
          } catch (e) {
            console.error('Image normalization failed:', e);
          }
        }
        
        // Run normalization when page loads
        window.onload = safeApplyImageNormalization;
      </script>
    ''';
  }

  static const scriptsDisableZoom = '''
    <script type="text/javascript">
      document.addEventListener('wheel', function(e) {
        e.ctrlKey && e.preventDefault();
      }, {
        passive: false,
      });
      window.addEventListener('keydown', disableZoomControl);
      
      window.addEventListener('pagehide', (event) => {
        window.removeEventListener('keydown', disableZoomControl);
      });
      
      function disableZoomControl(event) {
        if (event.metaKey || event.ctrlKey) {
          switch (event.key) {
            case '=':
            case '-':
              event.preventDefault();
              break;
          }
        }
      }
    </script>
  ''';

  static String scriptsWheelEventListener({
    required String viewId,
    required String onScrollChangedEvent,
  }) =>
      '''
    <script type="text/javascript">
      function onWheel(e) { 
        const deltaY = event.deltaY;
        window.parent.postMessage(JSON.stringify({
          "view": "$viewId",
          "type": "toDart: $onScrollChangedEvent",
          "deltaY": deltaY
        }), "*");
      }
      
      window.addEventListener('wheel', onWheel, { passive: true });
      
      window.addEventListener('pagehide', (event) => {
        window.removeEventListener('wheel', onWheel);
      });
    </script>
  ''';

  static String scriptsTouchEventListener({
    required String viewId,
    required String onScrollChangedEvent,
    required String onScrollEndEvent,
  }) =>
      '''
    <script type="text/javascript">
      let lastY = 0;
      let lastTime = 0;
      let velocity = 0;
    
      function onTouchStart(e) { 
        lastY = e.touches[0].clientY;
        lastTime = performance.now();
        velocity = 0;
      }
    
      function onTouchMove(e) { 
        const now = performance.now();
        const y = e.touches[0].clientY;
        const dy = lastY - y;
        const dt = now - lastTime;
    
        if (dt > 0) {
          velocity = dy / dt; // px per ms
          velocity = Math.max(Math.min(velocity, 2), -2); // clamp velocity
        }
    
        lastY = y;
        lastTime = now;
    
        window.parent.postMessage(JSON.stringify({
          view: "$viewId",
          type: "toDart: $onScrollChangedEvent",
          deltaY: dy,
        }), '*');
      }
    
      function onTouchEnd(e) { 
        window.parent.postMessage(JSON.stringify({
          view: "$viewId",
          type: "toDart: $onScrollEndEvent",
          velocity: velocity,
        }), '*');
      }
    
      window.addEventListener('touchstart', onTouchStart, { passive: true });
      window.addEventListener('touchmove', onTouchMove, { passive: true });
      window.addEventListener('touchend', onTouchEnd, { passive: true });
    
      window.addEventListener('pagehide', () => {
        window.removeEventListener('touchstart', onTouchStart);
        window.removeEventListener('touchmove', onTouchMove);
        window.removeEventListener('touchend', onTouchEnd);
      });
    </script>

  ''';

  static String scriptHandleIframeKeyboardListener(String viewId) =>
      '''
    <script type="text/javascript">
      window.addEventListener('keydown', handleIframeKeydown);
      
      window.addEventListener('pagehide', (event) => {
        window.removeEventListener('keydown', handleIframeKeydown);
      });
      
      function handleIframeKeydown(event) {
        const payload = {
          view: '$viewId',
          type: 'toDart: iframeKeydown',
          key: event.key,
          code: event.code,
          shift: event.shiftKey,
          ctrl: event.ctrlKey,
          meta: event.metaKey,
          alt: event.altKey
        };
        window.parent.postMessage(JSON.stringify(payload), "*");
      }
    </script>
  ''';

  static String scriptHandleIframeFindShortcutListener(String viewId) =>
      '''
    <script type="text/javascript">
      window.addEventListener('keydown', handleIframeFindShortcut);

      window.addEventListener('pagehide', () => {
        window.removeEventListener('keydown', handleIframeFindShortcut);
      });

      function handleIframeFindShortcut(event) {
        const key = (event.key || '').toLowerCase();
        const isFindShortcut = (event.ctrlKey || event.metaKey) &&
          !event.altKey &&
          key === 'f';

        if (!isFindShortcut) {
          return;
        }

        event.preventDefault();
        event.stopImmediatePropagation();
        window.parent.postMessage(JSON.stringify({
          view: '$viewId',
          type: 'toDart: $iframeFindShortcutEvent'
        }), '*');
      }
    </script>
  ''';

  static String scriptHandleIframeContentFind(String viewId) =>
      '''
    <script type="text/javascript">
      const tmailFindState = {
        marks: [],
        activeIndex: -1,
        query: ''
      };

      window.addEventListener('message', handleTMailFindMessage, false);

      window.addEventListener('pagehide', () => {
        window.removeEventListener('message', handleTMailFindMessage, false);
      });

      function handleTMailFindMessage(event) {
        if (!event || !event.data || !String(event.data).includes('toIframe:')) {
          return;
        }

        let data;
        try {
          data = JSON.parse(event.data);
        } catch (_) {
          return;
        }

        if (!data.view || data.view !== '$viewId' || !data.type) {
          return;
        }

        if (data.type.includes('$iframeFindApplyEvent')) {
          applyTMailFindQuery(data.query || '');
        } else if (data.type.includes('$iframeFindNextEvent')) {
          moveTMailFindActive(1);
        } else if (data.type.includes('$iframeFindPreviousEvent')) {
          moveTMailFindActive(-1);
        } else if (data.type.includes('$iframeFindClearEvent')) {
          clearTMailFindMarks();
          postTMailFindResult();
        }
      }

      function postTMailFindResult() {
        window.parent.postMessage(JSON.stringify({
          view: '$viewId',
          type: 'toDart: $iframeFindResultEvent',
          total: tmailFindState.marks.length,
          active: tmailFindState.activeIndex
        }), '*');
      }

      function escapeTMailFindRegExp(value) {
        return value.replace(/[.*+?^\\\${}()|[\\]\\\\]/g, '\\\\\$&');
      }

      function clearTMailFindMarks() {
        const existingMarks = Array.from(
          document.querySelectorAll('mark.tmail-find-hit')
        );

        existingMarks.forEach((mark) => {
          const parent = mark.parentNode;
          if (!parent) {
            return;
          }
          parent.replaceChild(document.createTextNode(mark.textContent || ''), mark);
          parent.normalize();
        });

        tmailFindState.marks = [];
        tmailFindState.activeIndex = -1;
        tmailFindState.query = '';
      }

      function isTMailFindSearchableNode(node) {
        const parent = node.parentElement;
        if (!parent) {
          return false;
        }

        if (!node.nodeValue || !node.nodeValue.trim()) {
          return false;
        }

        const excluded = parent.closest(
          'script, style, noscript, textarea, input, select, mark.tmail-find-hit'
        );
        return !excluded;
      }

      function collectTMailFindTextNodes(root) {
        const textNodes = [];
        const walker = document.createTreeWalker(
          root,
          NodeFilter.SHOW_TEXT,
          {
            acceptNode: (node) => isTMailFindSearchableNode(node)
              ? NodeFilter.FILTER_ACCEPT
              : NodeFilter.FILTER_REJECT
          }
        );

        let node;
        while ((node = walker.nextNode())) {
          textNodes.push(node);
        }
        return textNodes;
      }

      function markTMailFindTextNode(node, regex) {
        const text = node.nodeValue || '';
        const fragment = document.createDocumentFragment();
        let lastIndex = 0;
        let hasMatch = false;
        let match;

        regex.lastIndex = 0;
        while ((match = regex.exec(text)) !== null) {
          if (match.index > lastIndex) {
            fragment.appendChild(
              document.createTextNode(text.slice(lastIndex, match.index))
            );
          }

          const mark = document.createElement('mark');
          mark.className = 'tmail-find-hit';
          mark.textContent = match[0];
          fragment.appendChild(mark);
          tmailFindState.marks.push(mark);
          hasMatch = true;
          lastIndex = regex.lastIndex;

          if (regex.lastIndex === match.index) {
            regex.lastIndex++;
          }
        }

        if (!hasMatch) {
          return;
        }

        if (lastIndex < text.length) {
          fragment.appendChild(document.createTextNode(text.slice(lastIndex)));
        }

        node.parentNode.replaceChild(fragment, node);
      }

      function setTMailFindActive(index) {
        tmailFindState.marks.forEach((mark) => {
          mark.classList.remove('tmail-find-hit-active');
        });

        if (index < 0 || index >= tmailFindState.marks.length) {
          tmailFindState.activeIndex = -1;
          return;
        }

        tmailFindState.activeIndex = index;
        const activeMark = tmailFindState.marks[index];
        activeMark.classList.add('tmail-find-hit-active');
        activeMark.scrollIntoView({ behavior: 'smooth', block: 'center' });
      }

      function moveTMailFindActive(delta) {
        const total = tmailFindState.marks.length;
        if (!total) {
          postTMailFindResult();
          return;
        }

        const currentIndex = tmailFindState.activeIndex < 0
          ? 0
          : tmailFindState.activeIndex;
        const nextIndex = (currentIndex + delta + total) % total;
        setTMailFindActive(nextIndex);
        postTMailFindResult();
      }

      function applyTMailFindQuery(rawQuery) {
        const query = String(rawQuery).trim();
        clearTMailFindMarks();

        if (!query) {
          postTMailFindResult();
          return;
        }

        tmailFindState.query = query;
        const contentRoot = document.querySelector('.tmail-content') || document.body;
        const regex = new RegExp(escapeTMailFindRegExp(query), 'gi');

        collectTMailFindTextNodes(contentRoot).forEach((node) => {
          markTMailFindTextNode(node, regex);
        });

        if (tmailFindState.marks.length > 0) {
          setTMailFindActive(0);
        }

        postTMailFindResult();
      }
    </script>
  ''';

  static String scriptsHandleIframeClickListener(String viewId) =>
      '''
    <script type="text/javascript">
      document.addEventListener('click', function (e) {
        try {
          const payload = {
            view: '$viewId',
            type: 'toDart: iframeClick',
          };
          window.parent.postMessage(JSON.stringify(payload), "*");
        } catch (_) {}
      });
    </script>
  ''';

  static String scriptsHandleIframeLinkHoverListener(String viewId) =>
      '''
    <script type="text/javascript">
      document.addEventListener("mouseover", function (e) {
        const target = e.target;
        if (target.tagName.toLowerCase() === "a") {
          const rect = target.getBoundingClientRect();
          
          const payload = {
            view: '$viewId',
            type: 'toDart: iframeLinkHover',
            url: target.href,
            rect: {
              x: rect.x,
              y: rect.y,
              width: rect.width,
              height: rect.height
            }
          };
          window.parent.postMessage(JSON.stringify(payload), "*");
        }
      });
    
      document.addEventListener("mouseout", function (e) {
        const target = e.target;
        if (target.tagName.toLowerCase() === "a") {
          const payload = {
            view: '$viewId',
            type: 'toDart: iframeLinkOut'
          };
          window.parent.postMessage(JSON.stringify(payload), "*");
        }
      });
    </script>
  ''';
}
