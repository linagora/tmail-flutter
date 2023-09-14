
import 'package:core/presentation/utils/html_transformer/html_event_action.dart';
import 'package:core/presentation/utils/icon_utils.dart';
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

  static const runScriptsCollapsedExpandedSignature = '''
    const signatureNode = document.querySelector('.tmail-content > .tmail-signature');
    if (signatureNode) {
      const signatureContainer = document.createElement('div');
      signatureContainer.setAttribute('class', 'tmail-signature');
  
      const signatureContent = document.createElement('div');
      signatureContent.setAttribute('class', 'tmail-signature-content');
      signatureContent.innerHTML = signatureNode.innerHTML;
      signatureContent.style.display = 'none';
  
      const signatureButton = document.createElement('button');
      signatureButton.setAttribute('class', 'tmail-signature-button');
      signatureButton.textContent = 'Signature';
      signatureButton.style.backgroundImage = `${IconUtils.chevronDownSVGIconUrlEncoded}`;
      signatureButton.setAttribute('onclick', 'handleOnClickSignature()');
  
      signatureContainer.appendChild(signatureButton);
      signatureContainer.appendChild(signatureContent);
  
      if (signatureNode.outerHTML) {
        signatureNode.outerHTML = signatureContainer.outerHTML;
      } else {
        signatureNode.parentNode.replaceChild(signatureContainer, signatureNode);
      }
    }
  ''';

  static const scriptCollapsedExpandedSignatureOnMobile = '''
    <script type="text/javascript">
      function showSignature() {
        const signatureNode = document.querySelector('.tmail-content > .tmail-signature');
        if (signatureNode) {
          const signatureContainer = document.createElement('div');
          signatureContainer.setAttribute('class', 'tmail-signature');
      
          const signatureContent = document.createElement('div');
          signatureContent.setAttribute('class', 'tmail-signature-content');
          signatureContent.innerHTML = signatureNode.innerHTML;
          signatureContent.style.display = 'none';
      
          const signatureButton = document.createElement('button');
          signatureButton.setAttribute('class', 'tmail-signature-button');
          signatureButton.textContent = 'Signature';
          signatureButton.style.backgroundImage = `${IconUtils.chevronDownSVGIconUrlEncoded}`;
          signatureButton.setAttribute('onclick', 'handleOnClickSignature()');
      
          signatureContainer.appendChild(signatureButton);
          signatureContainer.appendChild(signatureContent);
      
          if (signatureNode.outerHTML) {
            signatureNode.outerHTML = signatureContainer.outerHTML;
          } else {
            signatureNode.parentNode.replaceChild(signatureContainer, signatureNode);
          }
        }
      }
      
      function handleOnClickSignature() {
        const contentElement = document.querySelector('.tmail-content > .tmail-signature > .tmail-signature-content');
        const buttonElement = document.querySelector('.tmail-content > .tmail-signature > .tmail-signature-button');
        if (contentElement && buttonElement) {
          if (contentElement.style.display === 'block') {
            contentElement.style.display = 'none';
            buttonElement.style.backgroundImage = `${IconUtils.chevronDownSVGIconUrlEncoded}`;
          } else {
            contentElement.style.display = 'block';
            buttonElement.style.backgroundImage = `${IconUtils.chevronUpSVGIconUrlEncoded}`;
          }
        }
      }
    </script>
  ''';

  static String customCssStyleHtmlEditor({TextDirection direction = TextDirection.ltr}) {
    if (PlatformInfo.isWeb) {
      return '''
        <style>
          .note-editable {
            direction: ${direction.name};
          }
          
          .note-editable .tmail-signature {
            text-align: ${direction == TextDirection.rtl ? 'right' : 'left'};
          }
        </style>
      ''';
    } else if (PlatformInfo.isMobile) {
      return '''
        #editor {
          direction: ${direction.name};
        }
        
        #editor .tmail-signature {
          text-align: ${direction == TextDirection.rtl ? 'right' : 'left'};
        }
      ''';
    } else {
      return '';
    }
  }
}
