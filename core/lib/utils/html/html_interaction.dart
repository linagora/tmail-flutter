
import 'package:core/presentation/views/html_viewer/utils/event_constants.dart';

class HtmlInteraction {
  const HtmlInteraction._();

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

  static String scriptHandleMouseAndKeyboardEventListeners({required String viewId}) => '''
    <script type="text/javascript">
      function initializeEventListeners() {
        document.querySelectorAll('*').forEach(element => {
          element.setAttribute('tabindex', '-1');
        });
      }

      window.addEventListener('message', function (event) {
        try {
          if (typeof event.data !== 'string') return;
    
          const data = JSON.parse(event.data);

          if (data.viewId !== "$viewId") return;
          
          if (data.command === '${EventConstants.mouseEvent}') {
            const element = document.elementFromPoint(data.clientX, data.clientY);

            if (element) {
              const eventDataInit = {
                bubbles: data.shouldBubble,
                cancelable: data.isCancelable,
                view: window,
                detail: 1,
                screenX: data.screenX,
                screenY: data.screenY,
                clientX: data.clientX,
                clientY: data.clientY,
                button: data.clickedMouseButtonType,
                buttons: data.pressedMouseButtonsMaskType,
                relatedTarget: null,
              };
              const mouseEvent = new MouseEvent(data.eventType, eventDataInit);
              element.dispatchEvent(mouseEvent);
              
              if (data.eventType === '${EventConstants.mouseDown}') {
                if (window.getSelection && document.caretRangeFromPoint) {
                  const range = document.caretRangeFromPoint(data.clientX, data.clientY);
                  if (range) {
                    const selection = window.getSelection();
                    selection.removeAllRanges();
                    selection.addRange(range);
                  }
                }
                
                event.stopPropagation();
              } else if (data.eventType === '${EventConstants.mouseMove}' && data.isPointerDown) {
                const selection = window.getSelection();
                if (selection.rangeCount > 0) {
                  const newRange = document.caretRangeFromPoint(data.clientX, data.clientY);
                  if (newRange) {
                    try {
                      selection.extend(newRange.startContainer, newRange.startOffset);
                      const range = selection.getRangeAt(0);
                      range.startContainer.parentElement?.scrollIntoView({ block: 'nearest' });
                    } catch (e) {
                      console.error('Selection error:', e);
                    }
                  }
                }
                
                event.stopPropagation();
              } else if (data.eventType === '${EventConstants.mouseUp}') {
                element.focus();
                
                const selection = window.getSelection();
                if (selection && selection.toString().length > 0) {
                  document.designMode = 'off';
                } else {
                  const clickEvent = new MouseEvent('click', eventDataInit);
                  element.dispatchEvent(clickEvent);
                }
                
                event.stopPropagation();
              }
            }
          }
        } catch (e) {
          console.error('Message handling error:', e);
        }
      });
      
      // Initialize when page loads
      if (document.readyState === 'loading') {
          document.addEventListener('DOMContentLoaded', initializeEventListeners);
      } else {
          initializeEventListeners();
      }
    </script>
  ''';
}