// Generated by dart2js (NullSafetyMode.sound, trust primitives, omit checks, lax runtime type, csp, intern-composite-values), the Dart to JavaScript compiler version: 3.5.4.
((s, d, e) => {
  s[d] = s[d] || {};
  s[d][e] = s[d][e] || [];
  s[d][e].push({p: "main.dart.js_2", e: "beginPart"});
})(self, "$__dart_deferred_initializers__", "eventLog");
$__dart_deferred_initializers__.current = function(hunkHelpers, init, holdersList, $) {
  var J, B, C,
  A = {ImageLoaderMixin: function ImageLoaderMixin() {
    }, ImageLoaderMixin_buildImage_closure: function ImageLoaderMixin_buildImage_closure() {
    }, ImageLoaderMixin_buildImage_closure0: function ImageLoaderMixin_buildImage_closure0() {
    }, ImageLoaderMixin_buildImage_closure1: function ImageLoaderMixin_buildImage_closure1(t0) {
      this.imageSize = t0;
    },
    _httpClient() {
      return new self.XMLHttpRequest();
    },
    NetworkImage: function NetworkImage(t0, t1, t2) {
      this.url = t0;
      this.scale = t1;
      this.headers = t2;
    },
    NetworkImage__loadAsync_closure: function NetworkImage__loadAsync_closure(t0, t1, t2) {
      this.request = t0;
      this.completer = t1;
      this.resolved = t2;
    },
    NetworkImage__loadAsync_closure0: function NetworkImage__loadAsync_closure0(t0) {
      this.completer = t0;
    },
    NetworkImage__loadAsync_closure1: function NetworkImage__loadAsync_closure1(t0) {
      this.chunkEvents = t0;
    },
    NetworkImageLoadException$(statusCode, uri) {
      return new A.NetworkImageLoadException("HTTP request failed, statusCode: " + statusCode + ", " + uri.toString$0(0));
    },
    NetworkImageLoadException: function NetworkImageLoadException(t0) {
      this._image_provider$_message = t0;
    },
    ImageChunkEvent: function ImageChunkEvent(t0, t1) {
      this.cumulativeBytesLoaded = t0;
      this.expectedTotalBytes = t1;
    },
    _ImageChunkEvent_Object_Diagnosticable: function _ImageChunkEvent_Object_Diagnosticable() {
    },
    SvgNetworkLoader: function SvgNetworkLoader(t0, t1, t2, t3) {
      var _ = this;
      _.url = t0;
      _.headers = t1;
      _.theme = t2;
      _.colorMapper = t3;
    },
    ApplicationLogoWidthTextWidget$(margin, onTapAction) {
      var t1;
      $.$get$Get();
      t1 = $.GetInstance__getInstance;
      if (t1 == null)
        t1 = $.GetInstance__getInstance = C.C_GetInstance;
      return new A.ApplicationLogoWidthTextWidget(t1.find$1$1$tag(0, null, type$.ImagePaths), onTapAction, margin, null);
    },
    ApplicationLogoWidthTextWidget: function ApplicationLogoWidthTextWidget(t0, t1, t2, t3) {
      var _ = this;
      _._application_logo_with_text_widget$_imagePaths = t0;
      _.onTapAction = t1;
      _.margin = t2;
      _.key = t3;
    },
    ApplicationVersionWidget: function ApplicationVersionWidget(t0, t1, t2) {
      this.padding = t0;
      this.title = t1;
      this.key = t2;
    },
    _ApplicationVersionWidgetState: function _ApplicationVersionWidgetState(t0) {
      var _ = this;
      _._application_version_widget$_applicationManager = t0;
      _._framework$_element = _._widget = _._versionStream = null;
    },
    _ApplicationVersionWidgetState_build_closure: function _ApplicationVersionWidgetState_build_closure(t0) {
      this.$this = t0;
    },
    httpGet(url, headers) {
      var $async$goto = 0,
        $async$completer = B._makeAsyncAwaitCompleter(type$.Uint8List),
        $async$returnValue, t1;
      var $async$httpGet = B._wrapJsFunctionForAsync(function($async$errorCode, $async$result) {
        if ($async$errorCode === 1)
          return B._asyncRethrow($async$result, $async$completer);
        while (true)
          switch ($async$goto) {
            case 0:
              // Function start
              $async$goto = 3;
              return B._asyncAwait(B.HttpRequest_request(url, null, null, null, headers, null, null, null), $async$httpGet);
            case 3:
              // returning from await.
              t1 = $async$result.responseText;
              t1.toString;
              $async$returnValue = new Uint8Array(B._ensureNativeList(C.C_Utf8Encoder.convert$1(t1)));
              // goto return
              $async$goto = 1;
              break;
            case 1:
              // return
              return B._asyncReturn($async$returnValue, $async$completer);
          }
      });
      return B._asyncStartSync($async$httpGet, $async$completer);
    }
  },
  D;
  J = holdersList[1];
  B = holdersList[0];
  C = holdersList[2];
  A = hunkHelpers.updateHolder(holdersList[11], A);
  D = holdersList[17];
  A.ImageLoaderMixin.prototype = {
    buildImage$2$imagePath$imageSize(imagePath, imageSize) {
      var _null = null;
      if (this.isImageNetworkLink$1(imagePath) && C.JSString_methods.endsWith$1(imagePath, "svg"))
        return new B.SvgPicture(imageSize, imageSize, C.BoxFit_0, C.Alignment_0_0, new A.SvgNetworkLoader(imagePath, _null, _null, _null), new A.ImageLoaderMixin_buildImage_closure(), _null, _null);
      else if (this.isImageNetworkLink$1(imagePath))
        return new B.Image(B.ResizeImage_resizeIfNeeded(_null, _null, new A.NetworkImage(imagePath, 1, _null)), new A.ImageLoaderMixin_buildImage_closure0(), new A.ImageLoaderMixin_buildImage_closure1(imageSize), imageSize, imageSize, C.BoxFit_0, _null);
      else if (C.JSString_methods.endsWith$1(imagePath, "svg"))
        return B.SvgPicture$asset(imagePath, C.Alignment_0_0, _null, C.BoxFit_1, imageSize, _null, _null, imageSize);
      else
        return new B.Image(B.ResizeImage_resizeIfNeeded(_null, _null, new B.AssetImage(imagePath, _null, _null)), _null, _null, imageSize, imageSize, C.BoxFit_0, _null);
    },
    isImageNetworkLink$1(imagePath) {
      return C.JSString_methods.startsWith$1(imagePath, "http") || C.JSString_methods.startsWith$1(imagePath, "https");
    }
  };
  A.NetworkImage.prototype = {
    obtainKey$1(configuration) {
      return new B.SynchronousFuture(this, type$.SynchronousFuture_NetworkImage);
    },
    loadBuffer$2(key, decode) {
      var _null = null,
        chunkEvents = B.StreamController_StreamController(_null, _null, _null, _null, false, type$.ImageChunkEvent);
      return B.MultiFrameImageStreamCompleter$(new B._ControllerStream(chunkEvents, B._instanceType(chunkEvents)._eval$1("_ControllerStream<1>")), this.__network_image_web$_loadAsync$3(key, decode, chunkEvents), key.url, _null, key.scale);
    },
    loadImage$2(key, decode) {
      var _null = null,
        chunkEvents = B.StreamController_StreamController(_null, _null, _null, _null, false, type$.ImageChunkEvent);
      return B.MultiFrameImageStreamCompleter$(new B._ControllerStream(chunkEvents, B._instanceType(chunkEvents)._eval$1("_ControllerStream<1>")), this.__network_image_web$_loadAsync$3(key, decode, chunkEvents), key.url, _null, key.scale);
    },
    __network_image_web$_loadAsync$3(key, decode, chunkEvents) {
      return this._loadAsync$body$NetworkImage(key, decode, chunkEvents);
    },
    _loadAsync$body$NetworkImage(key, decode, chunkEvents) {
      var $async$goto = 0,
        $async$completer = B._makeAsyncAwaitCompleter(type$.Codec),
        $async$returnValue, completer, request, bytes, t1, resolved, t2, $async$temp1;
      var $async$__network_image_web$_loadAsync$3 = B._wrapJsFunctionForAsync(function($async$errorCode, $async$result) {
        if ($async$errorCode === 1)
          return B._asyncRethrow($async$result, $async$completer);
        while (true)
          switch ($async$goto) {
            case 0:
              // Function start
              t1 = key.url;
              resolved = B.Uri_base().resolve$1(t1);
              t2 = self;
              t2 = t2.window.flutterCanvasKit != null || t2.window._flutter_skwasmInstance != null;
              $async$goto = t2 ? 3 : 5;
              break;
            case 3:
              // then
              t2 = new B._Future($.Zone__current, type$._Future_JSObject);
              completer = new B._AsyncCompleter(t2, type$._AsyncCompleter_JSObject);
              request = A._httpClient();
              request.open("GET", t1, true);
              request.responseType = "arraybuffer";
              request.addEventListener("load", B._functionToJS1(new A.NetworkImage__loadAsync_closure(request, completer, resolved)));
              request.addEventListener("error", B._functionToJS1(new A.NetworkImage__loadAsync_closure0(completer)));
              request.send();
              $async$goto = 6;
              return B._asyncAwait(t2, $async$__network_image_web$_loadAsync$3);
            case 6:
              // returning from await.
              t1 = request.response;
              t1.toString;
              bytes = B.NativeUint8List_NativeUint8List$view(type$.NativeByteBuffer._as(t1), 0, null);
              if (bytes.byteLength === 0)
                throw B.wrapException(A.NetworkImageLoadException$(B.getProperty(request, "status"), resolved));
              $async$temp1 = decode;
              $async$goto = 7;
              return B._asyncAwait(B.ImmutableBuffer_fromUint8List(bytes), $async$__network_image_web$_loadAsync$3);
            case 7:
              // returning from await.
              $async$returnValue = $async$temp1.call$1($async$result);
              // goto return
              $async$goto = 1;
              break;
              // goto join
              $async$goto = 4;
              break;
            case 5:
              // else
              $async$returnValue = $.$get$_renderer().instantiateImageCodecFromUrl$2$chunkCallback(resolved, new A.NetworkImage__loadAsync_closure1(chunkEvents));
              // goto return
              $async$goto = 1;
              break;
            case 4:
              // join
            case 1:
              // return
              return B._asyncReturn($async$returnValue, $async$completer);
          }
      });
      return B._asyncStartSync($async$__network_image_web$_loadAsync$3, $async$completer);
    },
    $eq(_, other) {
      if (other == null)
        return false;
      if (J.get$runtimeType$(other) !== B.getRuntimeTypeOfDartObject(this))
        return false;
      return other instanceof A.NetworkImage && other.url === this.url && other.scale === this.scale;
    },
    get$hashCode(_) {
      return B.Object_hash(this.url, this.scale, C.C_SentinelValue, C.C_SentinelValue, C.C_SentinelValue, C.C_SentinelValue, C.C_SentinelValue, C.C_SentinelValue, C.C_SentinelValue, C.C_SentinelValue, C.C_SentinelValue, C.C_SentinelValue, C.C_SentinelValue, C.C_SentinelValue, C.C_SentinelValue, C.C_SentinelValue, C.C_SentinelValue, C.C_SentinelValue, C.C_SentinelValue, C.C_SentinelValue);
    },
    toString$0(_) {
      return 'NetworkImage("' + this.url + '", scale: ' + C.JSInt_methods.toStringAsFixed$1(this.scale, 1) + ")";
    }
  };
  A.NetworkImageLoadException.prototype = {
    toString$0(_) {
      return this._image_provider$_message;
    },
    $isException: 1
  };
  A.ImageChunkEvent.prototype = {};
  A._ImageChunkEvent_Object_Diagnosticable.prototype = {};
  A.SvgNetworkLoader.prototype = {
    prepareMessage$1(context) {
      return A.httpGet(this.url, this.headers);
    },
    provideSvg$1(message) {
      message.toString;
      return C.C_Utf8Codec.decode$2$allowMalformed(0, message, true);
    },
    get$hashCode(_) {
      var _this = this;
      return B.Object_hash(_this.url, _this.headers, _this.theme, _this.colorMapper, C.C_SentinelValue, C.C_SentinelValue, C.C_SentinelValue, C.C_SentinelValue, C.C_SentinelValue, C.C_SentinelValue, C.C_SentinelValue, C.C_SentinelValue, C.C_SentinelValue, C.C_SentinelValue, C.C_SentinelValue, C.C_SentinelValue, C.C_SentinelValue, C.C_SentinelValue, C.C_SentinelValue, C.C_SentinelValue);
    },
    $eq(_, other) {
      var t1;
      if (other == null)
        return false;
      if (other instanceof A.SvgNetworkLoader)
        t1 = other.url === this.url;
      else
        t1 = false;
      return t1;
    },
    toString$0(_) {
      return "SvgNetworkLoader(" + this.url + ")";
    }
  };
  A.ApplicationLogoWidthTextWidget.prototype = {
    build$1(context) {
      var _null = null,
        value = $.$get$dotenv().maybeGet$2$fallback("PLATFORM", "other"),
        t1 = value.toLowerCase() === "saas" ? "assets/images/ic_logo_with_text_beta.svg" : "assets/images/ic_logo_with_text.svg";
      return B.TMailButtonWidget_TMailButtonWidget$fromIcon(C.Color_0, 20, C.Color_0, t1, _null, 33, _null, this.margin, 1 / 0, _null, this.onTapAction, C.EdgeInsets_0_0_0_0, _null);
    }
  };
  A.ApplicationVersionWidget.prototype = {
    createState$0() {
      $.$get$Get();
      var t1 = $.GetInstance__getInstance;
      if (t1 == null)
        t1 = $.GetInstance__getInstance = C.C_GetInstance;
      return new A._ApplicationVersionWidgetState(t1.find$1$1$tag(0, null, type$.ApplicationManager));
    }
  };
  A._ApplicationVersionWidgetState.prototype = {
    initState$0() {
      this.super$State$initState();
      this._versionStream = this._application_version_widget$_applicationManager.getVersion$0();
    },
    build$1(context) {
      return B.FutureBuilder$(new A._ApplicationVersionWidgetState_build_closure(this), this._versionStream, type$.String);
    },
    dispose$0() {
      this._versionStream = null;
      this.super$State$dispose();
    }
  };
  var typesOffset = hunkHelpers.updateTypes([]);
  A.ImageLoaderMixin_buildImage_closure.prototype = {
    call$1(_) {
      return C.CupertinoActivityIndicator_null_true_1_null;
    },
    $signature: 1846
  };
  A.ImageLoaderMixin_buildImage_closure0.prototype = {
    call$3(_, child, loadingProgress) {
      if (loadingProgress != null && loadingProgress.cumulativeBytesLoaded !== loadingProgress.expectedTotalBytes)
        return D.Center_IFX;
      return child;
    },
    "call*": "call$3",
    $requiredArgCount: 3,
    $signature: 1847
  };
  A.ImageLoaderMixin_buildImage_closure1.prototype = {
    call$3(context, error, stackTrace) {
      var t1, _null = null;
      B.log("ImageLoaderMixin::buildImage:Exception = " + B.S(error), C.Level_1);
      t1 = this.imageSize;
      return B.Container$(C.Alignment_0_0, D.Icon_MYE, C.Clip_0, _null, _null, _null, _null, t1, _null, _null, _null, _null, _null, t1);
    },
    $signature: 1848
  };
  A.NetworkImage__loadAsync_closure.prototype = {
    call$1(e) {
      var t1 = this.request,
        $status = t1.status,
        accepted = $status >= 200 && $status < 300,
        unknownRedirect = $status > 307 && $status < 400,
        success = accepted || $status === 0 || $status === 304 || unknownRedirect,
        t2 = this.completer;
      if (success)
        t2.complete$1(0, t1);
      else {
        t2.completeError$1(e);
        throw B.wrapException(A.NetworkImageLoadException$($status, this.resolved));
      }
    },
    $signature: 191
  };
  A.NetworkImage__loadAsync_closure0.prototype = {
    call$1(e) {
      return this.completer.completeError$1(e);
    },
    $signature: 96
  };
  A.NetworkImage__loadAsync_closure1.prototype = {
    call$2(bytes, total) {
      this.chunkEvents.add$1(0, new A.ImageChunkEvent(bytes, total));
    },
    $signature: 249
  };
  A._ApplicationVersionWidgetState_build_closure.prototype = {
    call$2(context, snapshot) {
      var t2, t3, t4, _null = null,
        t1 = snapshot.data;
      if (t1 != null) {
        t2 = this.$this;
        t3 = t2._widget;
        t4 = t3.padding;
        if (t4 == null)
          t4 = C.EdgeInsets_0_8_0_0;
        t3 = t3.title;
        if (t3 == null)
          t3 = "v.";
        t1 = B.S(t1);
        t2._widget.toString;
        t2 = B.Theme_of(context).textTheme.bodySmall;
        t2 = t2 == null ? _null : t2.copyWith$1$color(C.Color_4286680217);
        return new B.Padding(t4, B.Text$(t3 + t1, _null, _null, _null, _null, _null, _null, _null, _null, t2, C.TextAlign_2, _null, _null, _null, _null), _null);
      } else
        return C.SizedBox_0_0_null_null;
    },
    $signature: 1849
  };
  (function inheritance() {
    var _mixin = hunkHelpers.mixin,
      _inheritMany = hunkHelpers.inheritMany,
      _inherit = hunkHelpers.inherit;
    _inheritMany(B.Object, [A.ImageLoaderMixin, A.NetworkImageLoadException, A._ImageChunkEvent_Object_Diagnosticable]);
    _inheritMany(B.Closure, [A.ImageLoaderMixin_buildImage_closure, A.ImageLoaderMixin_buildImage_closure0, A.ImageLoaderMixin_buildImage_closure1, A.NetworkImage__loadAsync_closure, A.NetworkImage__loadAsync_closure0]);
    _inherit(A.NetworkImage, B.ImageProvider);
    _inheritMany(B.Closure2Args, [A.NetworkImage__loadAsync_closure1, A._ApplicationVersionWidgetState_build_closure]);
    _inherit(A.ImageChunkEvent, A._ImageChunkEvent_Object_Diagnosticable);
    _inherit(A.SvgNetworkLoader, B.SvgLoader);
    _inherit(A.ApplicationLogoWidthTextWidget, B.StatelessWidget);
    _inherit(A.ApplicationVersionWidget, B.StatefulWidget);
    _inherit(A._ApplicationVersionWidgetState, B.State0);
    _mixin(A._ImageChunkEvent_Object_Diagnosticable, B.Diagnosticable);
  })();
  B._Universe_addRules(init.typeUniverse, JSON.parse('{"NetworkImage":{"ImageProvider":["NetworkImage0"],"ImageProvider.T":"NetworkImage0"},"NetworkImage0":{"ImageProvider":["NetworkImage0"]},"NetworkImageLoadException":{"Exception":[]},"SvgNetworkLoader":{"SvgLoader":["Uint8List"],"BytesLoader":[],"SvgLoader.T":"Uint8List"},"ApplicationLogoWidthTextWidget":{"StatelessWidget":[],"Widget":[],"DiagnosticableTree":[]},"ApplicationVersionWidget":{"StatefulWidget":[],"Widget":[],"DiagnosticableTree":[]},"_ApplicationVersionWidgetState":{"State0":["ApplicationVersionWidget"]}}'));
  var type$ = (function rtii() {
    var findType = B.findType;
    return {
      ApplicationManager: findType("ApplicationManager"),
      Codec: findType("Codec"),
      ImageChunkEvent: findType("ImageChunkEvent"),
      ImagePaths: findType("ImagePaths"),
      NativeByteBuffer: findType("NativeByteBuffer"),
      String: findType("String"),
      SynchronousFuture_NetworkImage: findType("SynchronousFuture<NetworkImage>"),
      Uint8List: findType("Uint8List"),
      _AsyncCompleter_JSObject: findType("_AsyncCompleter<JSObject>"),
      _Future_JSObject: findType("_Future<JSObject>")
    };
  })();
  (function constants() {
    D.Center_IFX = new B.Center(C.Alignment_0_0, null, null, C.CupertinoActivityIndicator_null_true_1_null, null);
    D.EdgeInsetsDirectional_16_16_16_0 = new B.EdgeInsetsDirectional(16, 16, 16, 0);
    D.Icon_MYE = new B.Icon(C.IconData_57912_false, null, null, null, null);
    D.TextStyle_OkG0 = new B.TextStyle(true, C.Color_4278221567, null, null, null, null, 14, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null);
  })();
};
;
((d, h) => {
  d[h] = d.current;
  d.eventLog.push({p: "main.dart.js_2", e: "endPart", h: h});
})($__dart_deferred_initializers__, "IrbkkFZf8uJmzZgTvgzpPSmCVlk=");
;