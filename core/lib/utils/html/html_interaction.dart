
class HtmlInteraction {
  static const String scrollRightEndAction = 'ScrollRightEndAction';
  static const String scrollLeftEndAction = 'ScrollLeftEndAction';
  static const String scrollEventJSChannelName = 'ScrollEventListener';
  static const String contentSizeChangedEventJSChannelName = 'ContentSizeChangedEventListener';

  static const String runScriptsHandleScrollEvent = '''
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

  static const String scriptsHandleContentSizeChanged = '''
    <script>
      const bodyResizeObserver = new ResizeObserver(entries => {
        window.flutter_inappwebview.callHandler('$contentSizeChangedEventJSChannelName', '');
      })
      
      bodyResizeObserver.observe(document.body)
    </script>
  ''';

  static const String scriptsHandleLazyLoadingBackgroundImage = '''
    <script>
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
}