
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
      document.body.onload= function() {
        document.body.offsetHeight;
        window.print();
      };
    </script>
  ''';
}