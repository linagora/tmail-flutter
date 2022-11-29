
import 'package:core/presentation/utils/html_transformer/html_event_action.dart';

class HtmlUtils {

  static const scrollEventJSChannelName = 'ScrollEventListener';

  static const runScriptsHandleScrollEvent = '''
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
         
        /*  
          console.log('newScrollLeft: ' + newScrollLeft);
          console.log('scrollWidth: ' + scrollWidth);
          console.log('offsetWidth: ' + offsetWidth);
          console.log('maxOffset: ' + maxOffset);
          console.log('scrollLeftRounded: ' + scrollLeftRounded); */
          
        if (xDiff > 0) {
          if (maxOffset === scrollLeftRounded || 
              maxOffset === (scrollLeftRounded + 1) || 
              maxOffset === (scrollLeftRounded - 1)) {
            window.$scrollEventJSChannelName.postMessage('${HtmlEventAction.scrollRightEndAction}');
          }
        } else {
          if (scrollLeftRounded === 0) {
            window.$scrollEventJSChannelName.postMessage('${HtmlEventAction.scrollLeftEndAction}');
          }
        }                       
      }
      
      xDown = null;
      yDown = null;                                             
    }
  ''';
}
