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
    ResizeImage_resizeIfNeeded(cacheWidth, cacheHeight, provider) {
      return provider;
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
    DisposableBuildContext: function DisposableBuildContext(t0, t1) {
      this._disposable_build_context$_state = t0;
      this.$ti = t1;
    },
    Image: function Image(t0, t1, t2, t3, t4, t5, t6) {
      var _ = this;
      _.image = t0;
      _.loadingBuilder = t1;
      _.errorBuilder = t2;
      _.width = t3;
      _.height = t4;
      _.fit = t5;
      _.key = t6;
    },
    _ImageState: function _ImageState() {
      var _ = this;
      _._loadingProgress = _._imageInfo = _._imageStream = null;
      _._isListeningToStream = false;
      _.___ImageState__invertColors_A = $;
      _._frameNumber = null;
      _._wasSynchronouslyLoaded = false;
      _.___ImageState__scrollAwareContext_A = $;
      _._framework$_element = _._widget = _._imageStreamListener = _._completerHandle = _._lastStack = _._lastException = null;
    },
    _ImageState__getListener_closure: function _ImageState__getListener_closure(t0) {
      this.$this = t0;
    },
    _ImageState__getListener__closure: function _ImageState__getListener__closure(t0, t1, t2) {
      this.$this = t0;
      this.error = t1;
      this.stackTrace = t2;
    },
    _ImageState__handleImageFrame_closure: function _ImageState__handleImageFrame_closure(t0, t1, t2) {
      this.$this = t0;
      this.imageInfo = t1;
      this.synchronousCall = t2;
    },
    _ImageState__handleImageChunk_closure: function _ImageState__handleImageChunk_closure(t0, t1) {
      this.$this = t0;
      this.event = t1;
    },
    _ImageState__replaceImage_closure: function _ImageState__replaceImage_closure(t0) {
      this.oldImageInfo = t0;
    },
    _ImageState__updateSourceStream_closure: function _ImageState__updateSourceStream_closure(t0) {
      this.$this = t0;
    },
    _ImageState__updateSourceStream_closure0: function _ImageState__updateSourceStream_closure0(t0) {
      this.$this = t0;
    },
    __ImageState_State_WidgetsBindingObserver: function __ImageState_State_WidgetsBindingObserver() {
    },
    ScrollAwareImageProvider: function ScrollAwareImageProvider(t0, t1, t2) {
      this.context = t0;
      this.imageProvider = t1;
      this.$ti = t2;
    },
    ScrollAwareImageProvider_resolveStreamForKey_closure: function ScrollAwareImageProvider_resolveStreamForKey_closure(t0, t1, t2, t3, t4) {
      var _ = this;
      _.$this = t0;
      _.configuration = t1;
      _.stream = t2;
      _.key = t3;
      _.handleError = t4;
    },
    ScrollAwareImageProvider_resolveStreamForKey__closure: function ScrollAwareImageProvider_resolveStreamForKey__closure(t0, t1, t2, t3, t4) {
      var _ = this;
      _.$this = t0;
      _.configuration = t1;
      _.stream = t2;
      _.key = t3;
      _.handleError = t4;
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
    ApplicationVersionWidget: function ApplicationVersionWidget(t0, t1, t2, t3) {
      var _ = this;
      _.padding = t0;
      _.title = t1;
      _.textStyle = t2;
      _.key = t3;
    },
    _ApplicationVersionWidgetState: function _ApplicationVersionWidgetState(t0) {
      var _ = this;
      _._application_version_widget$_applicationManager = t0;
      _._framework$_element = _._widget = _._versionStream = null;
    },
    _ApplicationVersionWidgetState_build_closure: function _ApplicationVersionWidgetState_build_closure(t0) {
      this.$this = t0;
    },
    Scrollable_recommendDeferredLoadingForContext(context) {
      var t1, t2,
        widget = context.getInheritedWidgetOfExactType$1$0(type$._ScrollableScope);
      for (t1 = widget != null; t1;) {
        t2 = widget.position;
        t2 = t2.physics.recommendDeferredLoading$3(t2._activity.get$velocity() + t2._impliedVelocity, t2.copyWith$0(), context);
        return t2;
      }
      return false;
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
  D = holdersList[16];
  A.ImageLoaderMixin.prototype = {
    buildImage$2$imagePath$imageSize(imagePath, imageSize) {
      var _null = null;
      if (this.isImageNetworkLink$1(imagePath) && C.JSString_methods.endsWith$1(imagePath, "svg"))
        return new B.SvgPicture(imageSize, imageSize, C.BoxFit_0, C.Alignment_0_0, new A.SvgNetworkLoader(imagePath, _null, _null, _null), new A.ImageLoaderMixin_buildImage_closure(), _null, _null);
      else if (this.isImageNetworkLink$1(imagePath))
        return new A.Image(A.ResizeImage_resizeIfNeeded(_null, _null, new A.NetworkImage(imagePath, 1, _null)), new A.ImageLoaderMixin_buildImage_closure0(), new A.ImageLoaderMixin_buildImage_closure1(imageSize), imageSize, imageSize, C.BoxFit_0, _null);
      else if (C.JSString_methods.endsWith$1(imagePath, "svg"))
        return B.SvgPicture$asset(imagePath, C.Alignment_0_0, _null, C.BoxFit_1, imageSize, _null, _null, imageSize);
      else
        return new A.Image(A.ResizeImage_resizeIfNeeded(_null, _null, new B.AssetImage(imagePath, _null, _null)), _null, _null, imageSize, imageSize, C.BoxFit_0, _null);
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
  A.DisposableBuildContext.prototype = {
    get$context(_) {
      var t1 = this._disposable_build_context$_state;
      if (t1 == null)
        t1 = null;
      else {
        t1 = t1._framework$_element;
        t1.toString;
      }
      return t1;
    }
  };
  A.Image.prototype = {
    createState$0() {
      return new A._ImageState();
    }
  };
  A._ImageState.prototype = {
    initState$0() {
      var _this = this;
      _this.super$State$initState();
      $.WidgetsBinding__instance.WidgetsBinding__observers.push(_this);
      _this.___ImageState__scrollAwareContext_A = new A.DisposableBuildContext(_this, type$.DisposableBuildContext_State_Image);
    },
    dispose$0() {
      var t1, _this = this;
      $.WidgetsBinding__instance.removeObserver$1(_this);
      _this._stopListeningToStream$0();
      t1 = _this._completerHandle;
      if (t1 != null)
        t1.dispose$0();
      t1 = _this.___ImageState__scrollAwareContext_A;
      t1 === $ && B.throwUnnamedLateFieldNI();
      t1._disposable_build_context$_state = null;
      _this._replaceImage$1$info(null);
      _this.super$State$dispose();
    },
    didChangeDependencies$0() {
      var t1, _this = this;
      _this._updateInvertColors$0();
      _this._resolveImage$0();
      t1 = _this._framework$_element;
      t1.toString;
      if (B.TickerMode_of(t1))
        _this._image0$_listenToStream$0();
      else
        _this._stopListeningToStream$1$keepStreamAlive(true);
      _this.super$State$didChangeDependencies();
    },
    didUpdateWidget$1(oldWidget) {
      var oldListener, t1, _this = this;
      _this.super$State$didUpdateWidget(oldWidget);
      if (_this._isListeningToStream && _this._widget.loadingBuilder == null !== (oldWidget.loadingBuilder == null)) {
        oldListener = _this._getListener$0();
        t1 = _this._imageStream;
        t1.toString;
        t1.addListener$1(0, _this._getListener$1$recreateListener(true));
        _this._imageStream.removeListener$1(0, oldListener);
      }
      if (!_this._widget.image.$eq(0, oldWidget.image))
        _this._resolveImage$0();
    },
    reassemble$0() {
      this._resolveImage$0();
      this.super$State$reassemble();
    },
    _updateInvertColors$0() {
      var t1 = this._framework$_element;
      t1.toString;
      t1 = B.MediaQuery__maybeOf(t1, C._MediaQueryAspect_12);
      t1 = t1 == null ? null : t1.invertColors;
      if (t1 == null) {
        t1 = $.SemanticsBinding__instance.SemanticsBinding___SemanticsBinding__accessibilityFeatures_A;
        t1 === $ && B.throwUnnamedLateFieldNI();
        t1 = (t1.__engine$_index & 2) !== 0;
      }
      this.___ImageState__invertColors_A = t1;
    },
    _resolveImage$0() {
      var t2, t3, t4, t5, _this = this,
        t1 = _this.___ImageState__scrollAwareContext_A;
      t1 === $ && B.throwUnnamedLateFieldNI();
      t2 = _this._widget;
      t3 = t2.image;
      t4 = _this._framework$_element;
      t4.toString;
      t5 = t2.width;
      t2 = t2.height;
      _this._updateSourceStream$1(new A.ScrollAwareImageProvider(t1, t3, type$.ScrollAwareImageProvider_Object).resolve$1(B.createLocalImageConfiguration(t4, new B.Size(t5, t2))));
    },
    _getListener$1$recreateListener(recreateListener) {
      var t2, _this = this,
        t1 = _this._imageStreamListener;
      if (t1 == null || recreateListener) {
        _this._lastStack = _this._lastException = null;
        t1 = _this._widget;
        t2 = t1.loadingBuilder == null ? null : _this.get$_handleImageChunk();
        t1 = t1.errorBuilder;
        t1 = t1 != null ? new A._ImageState__getListener_closure(_this) : null;
        t1 = _this._imageStreamListener = new B.ImageStreamListener(_this.get$_handleImageFrame(), t2, t1);
      }
      t1.toString;
      return t1;
    },
    _getListener$0() {
      return this._getListener$1$recreateListener(false);
    },
    _handleImageFrame$2(imageInfo, synchronousCall) {
      this.setState$1(new A._ImageState__handleImageFrame_closure(this, imageInfo, synchronousCall));
    },
    _handleImageChunk$1($event) {
      this.setState$1(new A._ImageState__handleImageChunk_closure(this, $event));
    },
    _replaceImage$1$info(info) {
      var oldImageInfo = this._imageInfo;
      $.SchedulerBinding__instance.SchedulerBinding__postFrameCallbacks.push(new A._ImageState__replaceImage_closure(oldImageInfo));
      this._imageInfo = info;
    },
    _updateSourceStream$1(newStream) {
      var t2, t3, _this = this,
        t1 = _this._imageStream;
      if (t1 == null)
        t2 = null;
      else {
        t2 = t1._completer;
        if (t2 == null)
          t2 = t1;
      }
      t3 = newStream._completer;
      if (t2 === (t3 == null ? newStream : t3))
        return;
      if (_this._isListeningToStream) {
        t1.toString;
        t1.removeListener$1(0, _this._getListener$0());
      }
      _this._widget.toString;
      _this.setState$1(new A._ImageState__updateSourceStream_closure(_this));
      _this.setState$1(new A._ImageState__updateSourceStream_closure0(_this));
      _this._imageStream = newStream;
      if (_this._isListeningToStream)
        newStream.addListener$1(0, _this._getListener$0());
    },
    _image0$_listenToStream$0() {
      var t1, _this = this;
      if (_this._isListeningToStream)
        return;
      t1 = _this._imageStream;
      t1.toString;
      t1.addListener$1(0, _this._getListener$0());
      t1 = _this._completerHandle;
      if (t1 != null)
        t1.dispose$0();
      _this._completerHandle = null;
      _this._isListeningToStream = true;
    },
    _stopListeningToStream$1$keepStreamAlive(keepStreamAlive) {
      var t1, t2, _this = this;
      if (!_this._isListeningToStream)
        return;
      t1 = false;
      if (keepStreamAlive)
        if (_this._completerHandle == null) {
          t1 = _this._imageStream;
          t1 = (t1 == null ? null : t1._completer) != null;
        }
      if (t1) {
        t1 = _this._imageStream._completer;
        if (t1._image_stream$_disposed)
          B.throwExpression(B.StateError$("Stream has been disposed.\nAn ImageStream is considered disposed once at least one listener has been added and subsequently all listeners have been removed and no handles are outstanding from the keepAlive method.\nTo resolve this error, maintain at least one listener on the stream, or create an ImageStreamCompleterHandle from the keepAlive method, or create a new stream for the image."));
        t2 = new B.ImageStreamCompleterHandle(t1);
        t2.ImageStreamCompleterHandle$_$1(t1);
        _this._completerHandle = t2;
      }
      t1 = _this._imageStream;
      t1.toString;
      t1.removeListener$1(0, _this._getListener$0());
      _this._isListeningToStream = false;
    },
    _stopListeningToStream$0() {
      return this._stopListeningToStream$1$keepStreamAlive(false);
    },
    build$1(context) {
      var t2, t3, t4, t5, t6, t7, t8, result, _this = this, _null = null,
        t1 = _this._lastException;
      if (t1 != null) {
        t2 = _this._widget.errorBuilder;
        if (t2 != null)
          return t2.call$3(context, t1, _this._lastStack);
      }
      t1 = _this._imageInfo;
      t2 = t1 == null;
      t3 = t2 ? _null : t1.image;
      t4 = t2 ? _null : t1.debugLabel;
      t5 = _this._widget;
      t6 = t5.width;
      t7 = t5.height;
      t1 = t2 ? _null : t1.scale;
      if (t1 == null)
        t1 = 1;
      t2 = t5.fit;
      t8 = _this.___ImageState__invertColors_A;
      t8 === $ && B.throwUnnamedLateFieldNI();
      result = B.RawImage$(C.Alignment_0_0, _null, _null, _null, t4, C.FilterQuality_2, t2, t7, t3, t8, false, false, _null, C.ImageRepeat_3, t1, t6);
      result = new B.Semantics(B.SemanticsProperties$(_null, _null, _null, _null, _null, _null, _null, _null, _null, _null, _null, _null, _null, _null, _null, _null, _null, _null, _null, _null, true, _null, _null, _null, "", _null, _null, _null, _null, _null, _null, _null, _null, _null, _null, _null, _null, _null, _null, _null, _null, _null, _null, _null, _null, _null, _null, _null, _null, _null, _null, _null, _null, _null, _null, _null, _null, _null, _null, _null, _null, _null), false, false, false, false, result, _null);
      t1 = t5.loadingBuilder;
      return t1 != null ? t1.call$3(context, result, _this._loadingProgress) : result;
    }
  };
  A.__ImageState_State_WidgetsBindingObserver.prototype = {};
  A.ScrollAwareImageProvider.prototype = {
    resolveStreamForKey$4(configuration, stream, key, handleError) {
      var t1, _this = this;
      if (stream._completer == null) {
        t1 = $.PaintingBinding__instance.PaintingBinding___PaintingBinding__imageCache_A;
        t1 === $ && B.throwUnnamedLateFieldNI();
        t1 = t1.containsKey$1(0, key);
      } else
        t1 = true;
      if (t1) {
        _this.imageProvider.resolveStreamForKey$4(configuration, stream, key, handleError);
        return;
      }
      t1 = _this.context;
      if (t1.get$context(0) == null)
        return;
      t1 = t1.get$context(0);
      t1.toString;
      if (A.Scrollable_recommendDeferredLoadingForContext(t1)) {
        $.SchedulerBinding__instance.scheduleFrameCallback$1(new A.ScrollAwareImageProvider_resolveStreamForKey_closure(_this, configuration, stream, key, handleError));
        return;
      }
      _this.imageProvider.resolveStreamForKey$4(configuration, stream, key, handleError);
    },
    loadBuffer$2(key, decode) {
      return this.imageProvider.loadBuffer$2(key, decode);
    },
    loadImage$2(key, decode) {
      return this.imageProvider.loadImage$2(key, decode);
    },
    obtainKey$1(configuration) {
      return this.imageProvider.obtainKey$1(configuration);
    }
  };
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
  var typesOffset = hunkHelpers.updateTypes(["~(ImageInfo,bool)", "~(ImageChunkEvent)"]);
  A.ImageLoaderMixin_buildImage_closure.prototype = {
    call$1(_) {
      return C.CupertinoActivityIndicator_null_true_1_null;
    },
    $signature: 1802
  };
  A.ImageLoaderMixin_buildImage_closure0.prototype = {
    call$3(_, child, loadingProgress) {
      if (loadingProgress != null && loadingProgress.cumulativeBytesLoaded !== loadingProgress.expectedTotalBytes)
        return D.Center_IFX;
      return child;
    },
    "call*": "call$3",
    $requiredArgCount: 3,
    $signature: 1803
  };
  A.ImageLoaderMixin_buildImage_closure1.prototype = {
    call$3(context, error, stackTrace) {
      var t1, _null = null;
      B.log("ImageLoaderMixin::buildImage:Exception = " + B.S(error), C.Level_1);
      t1 = this.imageSize;
      return B.Container$(C.Alignment_0_0, D.Icon_MYE, C.Clip_0, _null, _null, _null, _null, t1, _null, _null, _null, _null, _null, t1);
    },
    $signature: 1804
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
    $signature: 208
  };
  A.NetworkImage__loadAsync_closure0.prototype = {
    call$1(e) {
      return this.completer.completeError$1(e);
    },
    $signature: 86
  };
  A.NetworkImage__loadAsync_closure1.prototype = {
    call$2(bytes, total) {
      this.chunkEvents.add$1(0, new A.ImageChunkEvent(bytes, total));
    },
    $signature: 225
  };
  A._ImageState__getListener_closure.prototype = {
    call$2(error, stackTrace) {
      var t1 = this.$this;
      t1.setState$1(new A._ImageState__getListener__closure(t1, error, stackTrace));
    },
    $signature: 369
  };
  A._ImageState__getListener__closure.prototype = {
    call$0() {
      var t1 = this.$this;
      t1._lastException = this.error;
      t1._lastStack = this.stackTrace;
    },
    $signature: 0
  };
  A._ImageState__handleImageFrame_closure.prototype = {
    call$0() {
      var t2,
        t1 = this.$this;
      t1._replaceImage$1$info(this.imageInfo);
      t1._lastStack = t1._lastException = t1._loadingProgress = null;
      t2 = t1._frameNumber;
      t1._frameNumber = t2 == null ? 0 : t2 + 1;
      t1._wasSynchronouslyLoaded = C.JSBool_methods.$or(t1._wasSynchronouslyLoaded, this.synchronousCall);
    },
    $signature: 0
  };
  A._ImageState__handleImageChunk_closure.prototype = {
    call$0() {
      var t1 = this.$this;
      t1._loadingProgress = this.event;
      t1._lastStack = t1._lastException = null;
    },
    $signature: 0
  };
  A._ImageState__replaceImage_closure.prototype = {
    call$1(_) {
      var t1 = this.oldImageInfo;
      if (t1 != null)
        t1.image.dispose$0();
      return null;
    },
    $signature: 8
  };
  A._ImageState__updateSourceStream_closure.prototype = {
    call$0() {
      this.$this._replaceImage$1$info(null);
    },
    $signature: 0
  };
  A._ImageState__updateSourceStream_closure0.prototype = {
    call$0() {
      var t1 = this.$this;
      t1._frameNumber = t1._loadingProgress = null;
      t1._wasSynchronouslyLoaded = false;
    },
    $signature: 0
  };
  A.ScrollAwareImageProvider_resolveStreamForKey_closure.prototype = {
    call$1(_) {
      var _this = this;
      B.scheduleMicrotask(new A.ScrollAwareImageProvider_resolveStreamForKey__closure(_this.$this, _this.configuration, _this.stream, _this.key, _this.handleError));
    },
    $signature: 8
  };
  A.ScrollAwareImageProvider_resolveStreamForKey__closure.prototype = {
    call$0() {
      var _this = this;
      return _this.$this.resolveStreamForKey$4(_this.configuration, _this.stream, _this.key, _this.handleError);
    },
    $signature: 0
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
        t2 = t2._widget.textStyle;
        if (t2 == null) {
          t2 = B.Theme_of(context).textTheme.labelMedium;
          t2 = t2 == null ? _null : t2.copyWith$3$color$fontSize$fontWeight(C.Color_4285364357, 13, C.FontWeight_4_500);
        }
        return new B.Padding(t4, B.Text$(t3 + t1, _null, _null, _null, _null, _null, _null, _null, _null, t2, C.TextAlign_2, _null, _null, _null, _null), _null);
      } else
        return C.SizedBox_0_0_null_null;
    },
    $signature: 1805
  };
  (function installTearOffs() {
    var _instance_2_u = hunkHelpers._instance_2u,
      _instance_1_u = hunkHelpers._instance_1u;
    var _;
    _instance_2_u(_ = A._ImageState.prototype, "get$_handleImageFrame", "_handleImageFrame$2", 0);
    _instance_1_u(_, "get$_handleImageChunk", "_handleImageChunk$1", 1);
  })();
  (function inheritance() {
    var _mixin = hunkHelpers.mixin,
      _inheritMany = hunkHelpers.inheritMany,
      _inherit = hunkHelpers.inherit;
    _inheritMany(B.Object, [A.ImageLoaderMixin, A.NetworkImageLoadException, A._ImageChunkEvent_Object_Diagnosticable, A.DisposableBuildContext]);
    _inheritMany(B.Closure, [A.ImageLoaderMixin_buildImage_closure, A.ImageLoaderMixin_buildImage_closure0, A.ImageLoaderMixin_buildImage_closure1, A.NetworkImage__loadAsync_closure, A.NetworkImage__loadAsync_closure0, A._ImageState__replaceImage_closure, A.ScrollAwareImageProvider_resolveStreamForKey_closure]);
    _inheritMany(B.ImageProvider, [A.NetworkImage, A.ScrollAwareImageProvider]);
    _inheritMany(B.Closure2Args, [A.NetworkImage__loadAsync_closure1, A._ImageState__getListener_closure, A._ApplicationVersionWidgetState_build_closure]);
    _inherit(A.ImageChunkEvent, A._ImageChunkEvent_Object_Diagnosticable);
    _inheritMany(B.StatefulWidget, [A.Image, A.ApplicationVersionWidget]);
    _inheritMany(B.State0, [A.__ImageState_State_WidgetsBindingObserver, A._ApplicationVersionWidgetState]);
    _inherit(A._ImageState, A.__ImageState_State_WidgetsBindingObserver);
    _inheritMany(B.Closure0Args, [A._ImageState__getListener__closure, A._ImageState__handleImageFrame_closure, A._ImageState__handleImageChunk_closure, A._ImageState__updateSourceStream_closure, A._ImageState__updateSourceStream_closure0, A.ScrollAwareImageProvider_resolveStreamForKey__closure]);
    _inherit(A.SvgNetworkLoader, B.SvgLoader);
    _inherit(A.ApplicationLogoWidthTextWidget, B.StatelessWidget);
    _mixin(A._ImageChunkEvent_Object_Diagnosticable, B.Diagnosticable);
    _mixin(A.__ImageState_State_WidgetsBindingObserver, B.WidgetsBindingObserver);
  })();
  B._Universe_addRules(init.typeUniverse, JSON.parse('{"NetworkImage":{"ImageProvider":["NetworkImage0"],"ImageProvider.T":"NetworkImage0"},"NetworkImage0":{"ImageProvider":["NetworkImage0"]},"NetworkImageLoadException":{"Exception":[]},"Image":{"StatefulWidget":[],"Widget":[],"DiagnosticableTree":[]},"_ImageState":{"State0":["Image"],"WidgetsBindingObserver":[]},"ScrollAwareImageProvider":{"ImageProvider":["1"],"ImageProvider.T":"1"},"SvgNetworkLoader":{"SvgLoader":["Uint8List"],"BytesLoader":[],"SvgLoader.T":"Uint8List"},"ApplicationLogoWidthTextWidget":{"StatelessWidget":[],"Widget":[],"DiagnosticableTree":[]},"ApplicationVersionWidget":{"StatefulWidget":[],"Widget":[],"DiagnosticableTree":[]},"_ApplicationVersionWidgetState":{"State0":["ApplicationVersionWidget"]}}'));
  var type$ = (function rtii() {
    var findType = B.findType;
    return {
      ApplicationManager: findType("ApplicationManager"),
      Codec: findType("Codec"),
      DisposableBuildContext_State_Image: findType("DisposableBuildContext<State0<Image>>"),
      ImageChunkEvent: findType("ImageChunkEvent"),
      ImagePaths: findType("ImagePaths"),
      NativeByteBuffer: findType("NativeByteBuffer"),
      ScrollAwareImageProvider_Object: findType("ScrollAwareImageProvider<Object>"),
      String: findType("String"),
      SynchronousFuture_NetworkImage: findType("SynchronousFuture<NetworkImage>"),
      Uint8List: findType("Uint8List"),
      _AsyncCompleter_JSObject: findType("_AsyncCompleter<JSObject>"),
      _Future_JSObject: findType("_Future<JSObject>"),
      _ScrollableScope: findType("_ScrollableScope")
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
})($__dart_deferred_initializers__, "BQ/gwHan9mCYn6z+vzHnq0Kk0Hc=");
;