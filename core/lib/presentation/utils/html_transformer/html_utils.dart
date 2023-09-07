
import 'package:core/presentation/utils/html_transformer/html_event_action.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';

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
            window.flutter_inappwebview.callHandler('$scrollEventJSChannelName', '${HtmlEventAction.scrollRightEndAction}');
          }
        } else {
          if (scrollLeftRounded === 0) {
            window.flutter_inappwebview.callHandler('$scrollEventJSChannelName', '${HtmlEventAction.scrollLeftEndAction}');
          }
        }                       
      }
      
      xDown = null;
      yDown = null;                                             
    }
  ''';

  static const scriptLazyLoadImage = '''
    <script type="text/javascript">
      const lazyImages = document.querySelectorAll("img.lazy-loading");
      
      const options = {
        root: null, // Use the viewport as the root
        rootMargin: "0px",
        threshold: 0 // Specify the threshold for intersection
      };
      
      const handleIntersection = (entries, observer) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            const img = entry.target;
            const src = img.getAttribute("data-src");
      
            // Replace the placeholder with the actual image source
            img.src = src;
      
            // Stop observing the image
            observer.unobserve(img);
          }
        });
      };
      
      const observer = new IntersectionObserver(handleIntersection, options);
      
      lazyImages.forEach((image) => {
        observer.observe(image);
      });
    </script>
  ''';

  static String customCssStyleHtmlEditor({TextDirection direction = TextDirection.ltr}) {
    if (PlatformInfo.isWeb) {
      return '''
        <style>
          .note-editable {
            direction: ${direction.name};
          }
          
          blockquote {
            margin-left: 8px;
            margin-right: 8px;
            padding-left: 12px;
            padding-right: 12px;
            border-left: 5px solid #eee;
          }
          
          pre {
            display: block;
            padding: 10px;
            margin: 0 0 10px;
            font-size: 13px;
            line-height: 1.5;
            color: #333;
            word-break: break-all;
            word-wrap: break-word;
            background-color: #f5f5f5;
            border: 1px solid #ccc;
            border-radius: 4px;
            overflow: auto;
          }
          
          div.tmail-signature {
            text-align: left;
            margin: 16px 0px 16px 0px;
          }
          
          .tmail-signature-button,
          .tmail-signature-button * {
            box-sizing: border-box;
          }
    
          .tmail-signature-button {
            padding: 6px 40px 6px 16px;
            border-radius: 4px;
            color: #fff;
            background-image: url("data:image/svg+xml,%3Csvg width='20' height='20' viewBox='0 0 20 20' fill='none' xmlns='http://www.w3.org/2000/svg'%3E%3Cpath d='M10.0003 11.8319L5.53383 8.1098C5.18027 7.81516 4.6548 7.86293 4.36016 8.21649C4.06553 8.57006 4.1133 9.09553 4.46686 9.39016L9.46686 13.5568C9.7759 13.8144 10.2248 13.8144 10.5338 13.5568L15.5338 9.39016C15.8874 9.09553 15.9352 8.57006 15.6405 8.21649C15.3459 7.86293 14.8204 7.81516 14.4669 8.1098L10.0003 11.8319Z' fill='%23AEAEC0'/%3E%3C/svg%3E%0A");
            background-repeat: no-repeat;
            background-position: right 16px center;
            background-color: #FFFFFF;
            border-radius: 36px;
            border-style: solid;
            border-color: var(--m-3-syslight-outline-shadow-outline-variant, #cac4d0);
            border-width: 0.5px;
            flex-direction: row;
            gap: 8px;
            align-items: center;
            justify-content: flex-start;
            flex-shrink: 0;
            position: relative;
            cursor: pointer;
            color: var(--m-3-syslight-tetirary-tertiary, #8c9caf);
            text-align: left;
            font: var(--m-3-body-large-2, 400 17px/24px "Inter", sans-serif);
          }
          
          .tmail-signature-content {
            padding: 12px;
            display: none;
            overflow: hidden;
          }
        </style>
      ''';
    } else if (PlatformInfo.isMobile) {
      return '''
        #editor {
          direction: ${direction.name};
        }
        
        div.tmail-signature {
          text-align: left;
          margin: 16px 0px 16px 0px;
        }
        
        .tmail-signature-button,
        .tmail-signature-button * {
          box-sizing: border-box;
        }
  
        .tmail-signature-button {
          padding: 6px 40px 6px 16px;
          border-radius: 4px;
          color: #fff;
          background-image: url("data:image/svg+xml,%3Csvg width='20' height='20' viewBox='0 0 20 20' fill='none' xmlns='http://www.w3.org/2000/svg'%3E%3Cpath d='M10.0003 11.8319L5.53383 8.1098C5.18027 7.81516 4.6548 7.86293 4.36016 8.21649C4.06553 8.57006 4.1133 9.09553 4.46686 9.39016L9.46686 13.5568C9.7759 13.8144 10.2248 13.8144 10.5338 13.5568L15.5338 9.39016C15.8874 9.09553 15.9352 8.57006 15.6405 8.21649C15.3459 7.86293 14.8204 7.81516 14.4669 8.1098L10.0003 11.8319Z' fill='%23AEAEC0'/%3E%3C/svg%3E%0A");
          background-repeat: no-repeat;
          background-position: right 16px center;
          background-color: #FFFFFF;
          border-radius: 36px;
          border-style: solid;
          border-color: var(--m-3-syslight-outline-shadow-outline-variant, #cac4d0);
          border-width: 0.5px;
          flex-direction: row;
          gap: 8px;
          align-items: center;
          justify-content: flex-start;
          flex-shrink: 0;
          position: relative;
          cursor: pointer;
          color: var(--m-3-syslight-tetirary-tertiary, #8c9caf);
          text-align: left;
          font: var(--m-3-body-large-2, 400 17px/24px "Inter", sans-serif);
        }
        
        .tmail-signature-content {
          padding: 12px;
          display: none;
          overflow: hidden;
        }
      ''';
    } else {
      return '';
    }
  }
}
