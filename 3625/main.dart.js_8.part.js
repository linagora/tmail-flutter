// Generated by dart2js (NullSafetyMode.sound, trust primitives, omit checks, lax runtime type, csp, intern-composite-values), the Dart to JavaScript compiler version: 3.5.4.
((s, d, e) => {
  s[d] = s[d] || {};
  s[d][e] = s[d][e] || [];
  s[d][e].push({p: "main.dart.js_8", e: "beginPart"});
})(self, "$__dart_deferred_initializers__", "eventLog");
$__dart_deferred_initializers__.current = function(hunkHelpers, init, holdersList, $) {
  var J, A, C,
  B = {
    HtmlContentViewerOnWeb$(allowResizeToDocumentSize, contentHtml, contentPadding, direction, heightContent, mailtoDelegate, onClickHyperLinkAction, useDefaultFont, widthContent) {
      return new B.HtmlContentViewerOnWeb(contentHtml, widthContent, heightContent, direction, contentPadding, useDefaultFont, mailtoDelegate, onClickHyperLinkAction, allowResizeToDocumentSize, null);
    },
    HtmlContentViewerOnWeb: function HtmlContentViewerOnWeb(t0, t1, t2, t3, t4, t5, t6, t7, t8, t9) {
      var _ = this;
      _.contentHtml = t0;
      _.widthContent = t1;
      _.heightContent = t2;
      _.direction = t3;
      _.contentPadding = t4;
      _.useDefaultFont = t5;
      _.mailtoDelegate = t6;
      _.onClickHyperLinkAction = t7;
      _.allowResizeToDocumentSize = t8;
      _.key = t9;
    },
    _HtmlContentViewerOnWebState: function _HtmlContentViewerOnWebState() {
      var _ = this;
      _.___HtmlContentViewerOnWebState__actualWidth_A = _.___HtmlContentViewerOnWebState__actualHeight_A = _.___HtmlContentViewerOnWebState__createdViewId_A = $;
      _._html_content_viewer_on_web_widget$_htmlData = _._webInit = null;
      _._html_content_viewer_on_web_widget$_isLoading = true;
      _.minHeight = 100;
      _.___HtmlContentViewerOnWebState_sizeListener_F = $;
      _._html_content_viewer_on_web_widget$_iframeLoaded = false;
      _._framework$_element = _._widget = null;
    },
    _HtmlContentViewerOnWebState_initState_closure: function _HtmlContentViewerOnWebState_initState_closure(t0) {
      this.$this = t0;
    },
    _HtmlContentViewerOnWebState_initState__closure: function _HtmlContentViewerOnWebState_initState__closure(t0, t1) {
      this.$this = t0;
      this.scrollHeightWithBuffer = t1;
    },
    _HtmlContentViewerOnWebState_initState__closure0: function _HtmlContentViewerOnWebState_initState__closure0(t0) {
      this.$this = t0;
    },
    _HtmlContentViewerOnWebState_initState__closure1: function _HtmlContentViewerOnWebState_initState__closure1(t0, t1) {
      this.$this = t0;
      this.docWidth = t1;
    },
    _HtmlContentViewerOnWebState__setUpWeb_closure: function _HtmlContentViewerOnWebState__setUpWeb_closure(t0) {
      this.iframe = t0;
    },
    _HtmlContentViewerOnWebState__setUpWeb_closure0: function _HtmlContentViewerOnWebState__setUpWeb_closure0(t0) {
      this.$this = t0;
    },
    _HtmlContentViewerOnWebState_build_closure: function _HtmlContentViewerOnWebState_build_closure(t0) {
      this.$this = t0;
    },
    _HtmlContentViewerOnWebState_build__closure: function _HtmlContentViewerOnWebState_build__closure(t0) {
      this.$this = t0;
    }
  },
  D;
  J = holdersList[1];
  A = holdersList[0];
  C = holdersList[2];
  B = hunkHelpers.updateHolder(holdersList[12], B);
  D = holdersList[21];
  B.HtmlContentViewerOnWeb.prototype = {
    createState$0() {
      return new B._HtmlContentViewerOnWebState();
    }
  };
  B._HtmlContentViewerOnWebState.prototype = {
    initState$0() {
      var t1, _this = this;
      _this.super$State$initState();
      t1 = _this._widget;
      _this.___HtmlContentViewerOnWebState__actualHeight_A = t1.heightContent;
      _this.___HtmlContentViewerOnWebState__actualWidth_A = t1.widthContent;
      _this.___HtmlContentViewerOnWebState__createdViewId_A = _this._getRandString$1(10);
      _this._html_content_viewer_on_web_widget$_setUpWeb$0();
      t1 = window;
      t1.toString;
      t1 = A._EventStreamSubscription$(t1, "message", new B._HtmlContentViewerOnWebState_initState_closure(_this), false, type$.MessageEvent);
      _this.___HtmlContentViewerOnWebState_sizeListener_F !== $ && A.throwUnnamedLateFieldAI();
      _this.___HtmlContentViewerOnWebState_sizeListener_F = t1;
    },
    didUpdateWidget$1(oldWidget) {
      var t1, t2, _this = this;
      _this.super$State$didUpdateWidget(oldWidget);
      t1 = oldWidget.direction;
      A.log("_HtmlContentViewerOnWebState::didUpdateWidget():Old-Direction: " + t1.toString$0(0) + " | Current-Direction: " + _this._widget.direction.toString$0(0), C.Level_3);
      t2 = _this._widget;
      if (t2.contentHtml !== oldWidget.contentHtml || t2.direction !== t1) {
        _this.___HtmlContentViewerOnWebState__createdViewId_A = _this._getRandString$1(10);
        _this._html_content_viewer_on_web_widget$_setUpWeb$0();
      }
      t1 = _this._widget;
      t2 = t1.heightContent;
      if (t2 !== oldWidget.heightContent)
        _this.___HtmlContentViewerOnWebState__actualHeight_A = t2;
      t1 = t1.widthContent;
      if (t1 !== oldWidget.widthContent)
        _this.___HtmlContentViewerOnWebState__actualWidth_A = t1;
    },
    _getRandString$1(len) {
      var i,
        random = $.$get$Random__secureRandom(),
        values = J.JSArray_JSArray$allocateGrowable(len, type$.int);
      for (i = 0; i < len; ++i)
        values[i] = random.nextInt$1(255);
      return C.Base64Codec_Base64Encoder_true.get$encoder().convert$1(values);
    },
    _html_content_viewer_on_web_widget$_setUpWeb$0() {
      var t4, t5, t6, t7, t8, t9, t10, t11, t12, _this = this,
        t1 = _this._widget,
        t2 = t1.contentHtml,
        t3 = _this.___HtmlContentViewerOnWebState__createdViewId_A;
      t3 === $ && A.throwUnnamedLateFieldNI();
      t4 = t1.mailtoDelegate != null;
      t5 = t4 ? '                function handleOnClickEmailLink(e) {\n                   var href = this.href;\n                   window.parent.postMessage(JSON.stringify({"view": "' + t3 + '", "type": "toDart: OpenLink", "url": "" + href}), "*");\n                   e.preventDefault();\n                }\n              ' : "";
      t6 = t1.onClickHyperLinkAction != null;
      t7 = t6 ? '                function onClickHyperLink(e) {\n                   var href = this.href;\n                   window.parent.postMessage(JSON.stringify({"view": "' + t3 + '", "type": "toDart: onClickHyperLink", "url": "" + href}), "*");\n                   e.preventDefault();\n                }\n              ' : "";
      t6 = t6 ? "                  var hyperLinks = document.querySelectorAll('a');\n                  for (var i=0; i < hyperLinks.length; i++){\n                      hyperLinks[i].addEventListener('click', onClickHyperLink);\n                  }\n                " : "";
      t4 = t4 ? "                  var emailLinks = document.querySelectorAll('a[href^=\"mailto:\"]');\n                  for (var i=0; i < emailLinks.length; i++){\n                      emailLinks[i].addEventListener('click', handleOnClickEmailLink);\n                  }\n                " : "";
      t8 = _this.minHeight;
      t9 = t1.widthContent;
      t10 = t1.direction;
      t11 = t1.contentPadding;
      t1 = t1.useDefaultFont;
      t1;
      t12 = "";
      t1 = t1 ? "          body {\n            font-family: 'Inter', sans-serif;\n            font-weight: 500;\n            font-size: 16px;\n            line-height: 24px;\n          }\n        " : "";
      t10 = t10 === C.TextDirection_0 ? 'dir="rtl"' : "";
      t11 = t11 != null ? "margin: " + A.S(t11) + ";" : "";
      _this._html_content_viewer_on_web_widget$_htmlData = '      <!DOCTYPE html>\n      <html>\n      <head>\n      <meta name="viewport" content="width=device-width, initial-scale=1.0">\n      <meta http-equiv="Content-Type" content="text/html; charset=utf-8">\n      ' + t12 + "\n      <style>\n        " + t1 + "\n        .tmail-content {\n          min-height: " + A.S(t8) + "px;\n          min-width: 300px;\n          overflow: auto;\n        }\n                  .tmail-content::-webkit-scrollbar {\n            display: none;\n          }\n          .tmail-content {\n            -ms-overflow-style: none;  /* IE and Edge */\n            scrollbar-width: none;  /* Firefox */\n          }\n        \n            .tmail-tooltip .tooltiptext {\n      visibility: hidden;\n      max-width: 400px;\n      background-color: black;\n      color: #fff;\n      text-align: center;\n      border-radius: 6px;\n      padding: 5px 8px 5px 8px;\n      white-space: nowrap; \n      overflow: hidden;\n      text-overflow: ellipsis;\n      position: absolute;\n      z-index: 1;\n    }\n    .tmail-tooltip:hover .tooltiptext {\n      visibility: visible;\n    }\n  \n      </style>\n      </head>\n      <body " + t10 + ' style = "overflow-x: hidden; ' + t11 + '";>\n      <div class="tmail-content">' + t2 + "</div>\n      " + ("      <script type=\"text/javascript\">\n        window.parent.addEventListener('message', handleMessage, false);\n        window.addEventListener('load', handleOnLoad);\n        window.addEventListener('pagehide', (event) => {\n          window.parent.removeEventListener('message', handleMessage, false);\n        });\n      \n        function handleMessage(e) {\n          if (e && e.data && e.data.includes(\"toIframe:\")) {\n            var data = JSON.parse(e.data);\n            if (data[\"view\"].includes(\"" + t3 + '")) {\n              if (data["type"].includes("getHeight")) {\n                var height = document.body.scrollHeight;\n                window.parent.postMessage(JSON.stringify({"view": "' + t3 + '", "type": "toDart: htmlHeight", "height": height}), "*");\n              }\n              if (data["type"].includes("getWidth")) {\n                var width = document.body.scrollWidth;\n                window.parent.postMessage(JSON.stringify({"view": "' + t3 + '", "type": "toDart: htmlWidth", "width": width}), "*");\n              }\n              if (data["type"].includes("execCommand")) {\n                if (data["argument"] === null) {\n                  document.execCommand(data["command"], false);\n                } else {\n                  document.execCommand(data["command"], false, data["argument"]);\n                }\n              }\n            }\n          }\n        }\n        \n        ' + t5 + "\n        \n        \n        \n        " + t7 + '\n        \n        function handleOnLoad() {\n          window.parent.postMessage(JSON.stringify({"view": "' + t3 + '", "message": "iframeHasBeenLoaded"}), "*");\n          window.parent.postMessage(JSON.stringify({"view": "' + t3 + '", "type": "toIframe: getHeight"}), "*");\n          window.parent.postMessage(JSON.stringify({"view": "' + t3 + '", "type": "toIframe: getWidth"}), "*");\n          \n          ' + t6 + "\n          \n          " + t4 + "\n        }\n      </script>\n          <script type=\"text/javascript\">\n        document.addEventListener('wheel', function(e) {\n          e.ctrlKey && e.preventDefault();\n        }, {\n          passive: false,\n        });\n        window.addEventListener('keydown', function(e) {\n          if (event.metaKey || event.ctrlKey) {\n            switch (event.key) {\n              case '=':\n              case '-':\n                event.preventDefault();\n                break;\n            }\n          }\n        });\n      </script>\n        <script>\n      const lazyImages = document.querySelectorAll('[lazy]');\n      const lazyImageObserver = new IntersectionObserver((entries, observer) => {\n        entries.forEach((entry) => {\n          if (entry.isIntersecting) {\n            const lazyImage = entry.target;\n            const src = lazyImage.dataset.src;\n            lazyImage.tagName.toLowerCase() === 'img'\n              ? lazyImage.src = src\n              : lazyImage.style.backgroundImage = \"url('\" + src + \"')\";\n            lazyImage.removeAttribute('lazy');\n            observer.unobserve(lazyImage);\n          }\n        });\n      });\n      \n      lazyImages.forEach((lazyImage) => {\n        lazyImageObserver.observe(lazyImage);\n      });\n    </script>\n  " + ('      <script type="text/javascript">\n        const displayWidth = ' + A.S(t9) + ";\n    \n        const sizeUnits = ['px', 'in', 'cm', 'mm', 'pt', 'pc'];\n    \n        function convertToPx(value, unit) {\n          switch (unit.toLowerCase()) {\n            case 'px': return value;\n            case 'in': return value * 96;\n            case 'cm': return value * 37.8;\n            case 'mm': return value * 3.78;\n            case 'pt': return value * (96 / 72);\n            case 'pc': return value * (96 / 6);\n            default: return value;\n          }\n        }\n    \n        function removeWidthHeightFromStyle(style) {\n          style = style.replace(/width\\s*:\\s*[\\d.]+[a-zA-Z%]+\\s*;?/gi, '');\n          style = style.replace(/height\\s*:\\s*[\\d.]+[a-zA-Z%]+\\s*;?/gi, '');\n          style = style.trim();\n          if (style.length && !style.endsWith(';')) {\n            style += ';';\n          }\n          return style;\n        }\n    \n        function extractWidthHeightFromStyle(style) {\n          const result = {};\n          const widthMatch = style.match(/width\\s*:\\s*([\\d.]+)([a-zA-Z%]+)\\s*;?/);\n          const heightMatch = style.match(/height\\s*:\\s*([\\d.]+)([a-zA-Z%]+)\\s*;?/);\n    \n          if (widthMatch) {\n            const value = parseFloat(widthMatch[1]);\n            const unit = widthMatch[2];\n            if (!isNaN(value) && unit) {\n              result['width'] = { value, unit };\n            }\n          }\n    \n          if (heightMatch) {\n            const value = parseFloat(heightMatch[1]);\n            const unit = heightMatch[2];\n            if (!isNaN(value) && unit) {\n              result['height'] = { value, unit };\n            }\n          }\n    \n          return result;\n        }\n    \n        function normalizeStyleAttribute(attrs) {\n          let style = attrs['style'];\n          if (!style) {\n            attrs['style'] = 'display:inline;max-width:100%;';\n            return;\n          }\n    \n          style = style.trim();\n          const dimensions = extractWidthHeightFromStyle(style);\n          const hasWidth = dimensions.hasOwnProperty('width');\n    \n          if (hasWidth) {\n            const widthData = dimensions['width'];\n            const widthPx = convertToPx(widthData.value, widthData.unit);\n    \n            if (displayWidth !== undefined &&\n                widthPx > displayWidth &&\n                sizeUnits.includes(widthData.unit)) {\n              style = removeWidthHeightFromStyle(style).trim();\n            }\n          }\n    \n          if (style.length && !style.endsWith(';')) {\n            style += ';';\n          }\n    \n          if (!style.includes('max-width')) {\n            style += 'max-width:100%;height:auto;';\n          }\n    \n          if (!style.includes('display')) {\n            style += 'display:inline;';\n          }\n    \n          attrs['style'] = style;\n        }\n    \n        function normalizeWidthHeightAttribute(attrs) {\n          const widthStr = attrs['width'];\n          const heightStr = attrs['height'];\n    \n          if (!widthStr || displayWidth === undefined) return;\n    \n          const widthValue = parseFloat(widthStr);\n          if (isNaN(widthValue) || widthValue <= displayWidth) return;\n    \n          delete attrs['width'];\n          delete attrs['height'];\n        }\n    \n        function normalizeImageSize(attrs) {\n          normalizeStyleAttribute(attrs);\n          normalizeWidthHeightAttribute(attrs);\n        }\n    \n        function applyImageNormalization() {\n          document.querySelectorAll('img').forEach(img => {\n            const attrs = {\n              style: img.getAttribute('style'),\n              width: img.getAttribute('width'),\n              height: img.getAttribute('height')\n            };\n    \n            normalizeImageSize(attrs);\n    \n            if (attrs.style != null) img.setAttribute('style', attrs.style);\n            if ('width' in attrs) img.setAttribute('width', attrs.width);\n            else img.removeAttribute('width');\n    \n            if ('height' in attrs) img.setAttribute('height', attrs.height);\n            else img.removeAttribute('height');\n          });\n        }\n        \n        function safeApplyImageNormalization() {\n          try {\n            applyImageNormalization();\n          } catch (e) {\n            console.error('Image normalization failed:', e);\n          }\n        }\n        \n        window.onload = safeApplyImageNormalization;\n      </script>\n    ")) + "\n      </body>\n      </html> \n    ";
      t1 = document.createElement("iframe");
      t1.toString;
      t2 = _this.___HtmlContentViewerOnWebState__actualWidth_A;
      t2 === $ && A.throwUnnamedLateFieldNI();
      t1.width = C.JSNumber_methods.toString$0(t2);
      t2 = _this.___HtmlContentViewerOnWebState__actualHeight_A;
      t2 === $ && A.throwUnnamedLateFieldNI();
      t1.height = C.JSNumber_methods.toString$0(t2);
      t2 = _this._html_content_viewer_on_web_widget$_htmlData;
      t1.srcdoc = t2 == null ? "" : t2;
      t2 = t1.style;
      t2.border = "none";
      t2 = t1.style;
      t2.overflow = "hidden";
      t2 = t1.style;
      t2.width = "100%";
      t2 = t1.style;
      t2.height = "100%";
      $.$get$platformViewRegistry();
      t2 = _this.___HtmlContentViewerOnWebState__createdViewId_A;
      $.$get$PlatformViewManager_instance().registerFactory$3$isVisible(t2, new B._HtmlContentViewerOnWebState__setUpWeb_closure(t1), true);
      if (_this._framework$_element != null)
        _this.setState$1(new B._HtmlContentViewerOnWebState__setUpWeb_closure0(_this));
    },
    build$1(context) {
      return new A.LayoutBuilder(new B._HtmlContentViewerOnWebState_build_closure(this), null);
    },
    dispose$0() {
      this._html_content_viewer_on_web_widget$_htmlData = null;
      var t1 = this.___HtmlContentViewerOnWebState_sizeListener_F;
      t1 === $ && A.throwUnnamedLateFieldNI();
      t1.cancel$0(0);
      this.super$State$dispose();
    }
  };
  var typesOffset = hunkHelpers.updateTypes([]);
  B._HtmlContentViewerOnWebState_initState_closure.prototype = {
    call$1($event) {
      var docHeight, scrollHeightWithBuffer, docWidth, link, _s4_ = "type",
        data = C.C_JsonCodec.decode$1(0, new A._AcceptStructuredCloneDart2Js([], []).convertNativeToDart_AcceptStructuredClone$2$mustCopy($event.data, true)),
        t1 = J.getInterceptor$asx(data),
        t2 = t1.$index(data, "view"),
        t3 = this.$this,
        t4 = t3.___HtmlContentViewerOnWebState__createdViewId_A;
      t4 === $ && A.throwUnnamedLateFieldNI();
      if (!J.$eq$(t2, t4))
        return;
      if (J.$eq$(t1.$index(data, "message"), "iframeHasBeenLoaded"))
        t3._html_content_viewer_on_web_widget$_iframeLoaded = true;
      if (!t3._html_content_viewer_on_web_widget$_iframeLoaded)
        return;
      if (t1.$index(data, _s4_) != null && J.contains$1$asx(t1.$index(data, _s4_), "toDart: htmlHeight")) {
        docHeight = t1.$index(data, "height");
        if (docHeight == null) {
          t2 = t3.___HtmlContentViewerOnWebState__actualHeight_A;
          t2 === $ && A.throwUnnamedLateFieldNI();
          docHeight = t2;
        }
        t2 = t3._framework$_element;
        if (t2 != null) {
          scrollHeightWithBuffer = J.$add$ansx(docHeight, 30);
          if (J.$gt$n(scrollHeightWithBuffer, t3.minHeight))
            t3.setState$1(new B._HtmlContentViewerOnWebState_initState__closure(t3, scrollHeightWithBuffer));
        }
        if (t3._framework$_element != null && t3._html_content_viewer_on_web_widget$_isLoading)
          t3.setState$1(new B._HtmlContentViewerOnWebState_initState__closure0(t3));
      }
      if (t1.$index(data, _s4_) != null) {
        t2 = J.contains$1$asx(t1.$index(data, _s4_), "toDart: htmlWidth");
        if (t2)
          t3._widget.toString;
      } else
        t2 = false;
      if (t2) {
        docWidth = t1.$index(data, "width");
        if (docWidth == null) {
          t2 = t3.___HtmlContentViewerOnWebState__actualWidth_A;
          t2 === $ && A.throwUnnamedLateFieldNI();
          docWidth = t2;
        }
        t2 = t3._framework$_element;
        if (t2 != null)
          if (J.$gt$n(docWidth, 300) && t3._widget.allowResizeToDocumentSize)
            t3.setState$1(new B._HtmlContentViewerOnWebState_initState__closure1(t3, docWidth));
      }
      if (t1.$index(data, _s4_) != null && J.contains$1$asx(t1.$index(data, _s4_), "toDart: OpenLink")) {
        link = t1.$index(data, "url");
        if (link != null && t3._framework$_element != null) {
          A._asString(link);
          if (C.JSString_methods.startsWith$1(link, "mailto:")) {
            t2 = t3._widget.mailtoDelegate;
            if (t2 != null)
              t2.call$1(A.Uri_parse(link, 0, null));
          }
        }
      }
      if (t1.$index(data, _s4_) != null && J.contains$1$asx(t1.$index(data, _s4_), "toDart: onClickHyperLink")) {
        link = A._asStringQ(t1.$index(data, "url"));
        if (link != null && t3._framework$_element != null) {
          t1 = t3._widget.onClickHyperLinkAction;
          if (t1 != null)
            t1.call$1(A.Uri_parse(link, 0, null));
        }
      }
    },
    $signature: 129
  };
  B._HtmlContentViewerOnWebState_initState__closure.prototype = {
    call$0() {
      var t1 = this.$this;
      t1.___HtmlContentViewerOnWebState__actualHeight_A = this.scrollHeightWithBuffer;
      t1._html_content_viewer_on_web_widget$_isLoading = false;
    },
    $signature: 0
  };
  B._HtmlContentViewerOnWebState_initState__closure0.prototype = {
    call$0() {
      this.$this._html_content_viewer_on_web_widget$_isLoading = false;
    },
    $signature: 0
  };
  B._HtmlContentViewerOnWebState_initState__closure1.prototype = {
    call$0() {
      this.$this.___HtmlContentViewerOnWebState__actualWidth_A = this.docWidth;
    },
    $signature: 0
  };
  B._HtmlContentViewerOnWebState__setUpWeb_closure.prototype = {
    call$1(viewId) {
      return this.iframe;
    },
    $signature: 473
  };
  B._HtmlContentViewerOnWebState__setUpWeb_closure0.prototype = {
    call$0() {
      this.$this._webInit = A.Future_Future$value(true, type$.bool);
    },
    $signature: 0
  };
  B._HtmlContentViewerOnWebState_build_closure.prototype = {
    call$2(context, constraint) {
      var t2, t3,
        t1 = this.$this;
      t1.minHeight = Math.max(constraint.maxHeight, t1.minHeight);
      t2 = A._setArrayType([], type$.JSArray_Widget);
      t3 = t1._html_content_viewer_on_web_widget$_htmlData;
      if ((t3 == null ? null : t3.length !== 0) === false)
        t2.push(C.SizedBox_0_0_null_null);
      else
        t2.push(A.FutureBuilder$(new B._HtmlContentViewerOnWebState_build__closure(t1), t1._webInit, type$.bool));
      if (t1._html_content_viewer_on_web_widget$_isLoading)
        t2.push(D.Align_ChN);
      t1._widget.toString;
      return new A.Stack(C.AlignmentDirectional_m1_m1, null, C.StackFit_0, C.Clip_1, t2, null);
    },
    $signature: 1844
  };
  B._HtmlContentViewerOnWebState_build__closure.prototype = {
    call$2(context, snapshot) {
      var t1, t2, t3, t4;
      if (snapshot.data != null) {
        t1 = this.$this;
        t2 = t1.___HtmlContentViewerOnWebState__actualHeight_A;
        t2 === $ && A.throwUnnamedLateFieldNI();
        t3 = t1.___HtmlContentViewerOnWebState__actualWidth_A;
        t3 === $ && A.throwUnnamedLateFieldNI();
        t4 = t1._html_content_viewer_on_web_widget$_htmlData;
        t1 = t1.___HtmlContentViewerOnWebState__createdViewId_A;
        t1 === $ && A.throwUnnamedLateFieldNI();
        return new A.SizedBox(t3, t2, new A.HtmlElementView(t1, null, null, new A.ValueKey(t4, type$.ValueKey_nullable_String)), null);
      } else
        return C.SizedBox_0_0_null_null;
    },
    $signature: 1845
  };
  (function inheritance() {
    var _inherit = hunkHelpers.inherit,
      _inheritMany = hunkHelpers.inheritMany;
    _inherit(B.HtmlContentViewerOnWeb, A.StatefulWidget);
    _inherit(B._HtmlContentViewerOnWebState, A.State0);
    _inheritMany(A.Closure, [B._HtmlContentViewerOnWebState_initState_closure, B._HtmlContentViewerOnWebState__setUpWeb_closure]);
    _inheritMany(A.Closure0Args, [B._HtmlContentViewerOnWebState_initState__closure, B._HtmlContentViewerOnWebState_initState__closure0, B._HtmlContentViewerOnWebState_initState__closure1, B._HtmlContentViewerOnWebState__setUpWeb_closure0]);
    _inheritMany(A.Closure2Args, [B._HtmlContentViewerOnWebState_build_closure, B._HtmlContentViewerOnWebState_build__closure]);
  })();
  A._Universe_addRules(init.typeUniverse, JSON.parse('{"HtmlContentViewerOnWeb":{"StatefulWidget":[],"Widget":[],"DiagnosticableTree":[]},"_HtmlContentViewerOnWebState":{"State0":["HtmlContentViewerOnWeb"]}}'));
  var type$ = {
    JSArray_Widget: A.findType("JSArray<Widget>"),
    MessageEvent: A.findType("MessageEvent"),
    ValueKey_nullable_String: A.findType("ValueKey<String?>"),
    bool: A.findType("bool"),
    int: A.findType("int")
  };
  (function constants() {
    D.SizedBox_qzd0 = new A.SizedBox(30, 30, C.CupertinoActivityIndicator_Rjd, null);
    D.Padding_J28 = new A.Padding(C.EdgeInsets_16_16_16_16, D.SizedBox_qzd0, null);
    D.Align_ChN = new A.Align(C.Alignment_0_m1, null, null, D.Padding_J28, null);
  })();
};
;
((d, h) => {
  d[h] = d.current;
  d.eventLog.push({p: "main.dart.js_8", e: "endPart", h: h});
})($__dart_deferred_initializers__, "SD3a/y6exle1bAnLX2KYm2PzYcE=");
;