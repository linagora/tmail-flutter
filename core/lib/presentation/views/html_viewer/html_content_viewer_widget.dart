import 'dart:async';

import 'package:core/data/constants/constant.dart';
import 'package:core/presentation/views/html_viewer/html_content_viewer_configuration.dart';
import 'package:core/presentation/views/loading/cupertino_loading_widget.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/html/html_interaction.dart';
import 'package:core/utils/html/html_template.dart';
import 'package:core/utils/html/html_utils.dart';
import 'package:core/utils/html/mobile_email_responsive_layout_script.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;
import 'package:url_launcher/url_launcher_string.dart';

export 'html_content_viewer_configuration.dart';

class _HtmlContentMetrics {

  final double? scrollWidth;
  final double? offsetWidth;
  final double? scrollHeight;

  const _HtmlContentMetrics({
    this.scrollWidth,
    this.offsetWidth,
    this.scrollHeight,
  });

  factory _HtmlContentMetrics.fromJavaScriptResults(List<dynamic> results) {
    return _HtmlContentMetrics(
      scrollWidth: _javascriptResultAsDouble(results[0]),
      offsetWidth: _javascriptResultAsDouble(results[1]),
      scrollHeight: _javascriptResultAsDouble(results[2]),
    );
  }

  bool get isContentFullyVisible {
    if (scrollWidth == null) return false;
    if (offsetWidth == null) return false;

    return scrollWidth!.round() == offsetWidth!.round();
  }
}

enum _IOSScrollingState {
  disabled,
  enabled,
}

class _HtmlContentSizing {

  final _HtmlContentMetrics contentMetrics;
  final _IOSScrollingState iOSScrollingState;

  const _HtmlContentSizing({
    required this.contentMetrics,
    required this.iOSScrollingState,
  });

  bool get isIOSScrollingEnabled =>
      iOSScrollingState == _IOSScrollingState.enabled;
}

double? _javascriptResultAsDouble(dynamic result) =>
    result is num ? result.toDouble() : null;

class HtmlContentViewer extends StatefulWidget {

  final HtmlContentViewerConfiguration configuration;

  const HtmlContentViewer({
    Key? key,
    required this.configuration,
  }) : super(key: key);

  String get contentHtml => configuration.content.html;

  double? get initialWidth => configuration.layout.viewport.width;

  TextDirection? get direction => configuration.content.direction;

  bool get keepWidthWhileLoading => configuration.behavior.has(
    HtmlContentViewerFeature.keepWidthWhileLoading,
  );

  double? get contentPadding => configuration.layout.contentPadding?.value;

  bool get useDefaultFontStyle => configuration.typography.usesDefaultFontStyle;

  double get fontSize => configuration.typography.fontSize;

  double? get maxHtmlContentHeight =>
      configuration.layout.height.maxContentHeight;

  double get htmlContentMinHeight =>
      configuration.layout.height.minContentHeight;

  double get offsetHtmlContentHeight =>
      configuration.layout.height.offset.value;

  bool get keepAlive => configuration.behavior.has(
    HtmlContentViewerFeature.keepAlive,
  );

  bool get enableQuoteToggle => configuration.behavior.has(
    HtmlContentViewerFeature.quoteToggle,
  );

  bool get disableScrolling => configuration.behavior.has(
    HtmlContentViewerFeature.disableScrolling,
  );

  bool get enableMobileResponsiveLayout => configuration.behavior.has(
    HtmlContentViewerFeature.mobileResponsiveLayout,
  );

  double? get maxViewHeight => configuration.layout.height.maxViewHeight;

  OnLoadWidthHtmlViewerAction? get onLoadWidthHtmlViewer =>
      configuration.callbacks.onLoadWidth;

  OnMailtoDelegateAction? get onMailtoDelegateAction =>
      configuration.callbacks.onMailto;

  OnScrollHorizontalEndAction? get onScrollHorizontalEnd =>
      configuration.callbacks.onScrollHorizontalEnd;

  OnPreviewEMLDelegateAction? get onPreviewEMLDelegateAction =>
      configuration.callbacks.onPreviewEML;

  OnDownloadAttachmentDelegateAction? get onDownloadAttachmentDelegateAction =>
      configuration.callbacks.onDownloadAttachment;

  OnHtmlContentClippedAction? get onHtmlContentClippedAction =>
      configuration.callbacks.onContentClipped;

  @visibleForTesting
  static bool shouldApplyMobileResponsiveLayout(
    HtmlContentViewerConfiguration configuration,
    HtmlContentViewerPlatform platform,
  ) => configuration.behavior.has(
        HtmlContentViewerFeature.mobileResponsiveLayout,
      ) &&
      platform == HtmlContentViewerPlatform.mobile &&
      configuration.layout.viewport.width != null &&
      !configuration.behavior.has(HtmlContentViewerFeature.disableScrolling);

  @override
  State<StatefulWidget> createState() => HtmlContentViewState();
}

class HtmlContentViewState extends State<HtmlContentViewer> with AutomaticKeepAliveClientMixin {

  late InAppWebViewController _webViewController;
  late double _actualHeight;
  late Set<Factory<OneSequenceGestureRecognizer>> _gestureRecognizers;
  late InAppWebViewSettings _webViewSetting;

  final _loadingBarNotifier = ValueNotifier(true);

  String? _htmlData;

  InAppWebViewController get webViewController => _webViewController;

  @override
  void initState() {
    super.initState();
    _webViewSetting = InAppWebViewSettings(
      transparentBackground: true,
      verticalScrollBarEnabled: false,
      supportZoom: false,
      disableHorizontalScroll: widget.disableScrolling,
      disableVerticalScroll: widget.disableScrolling,
      horizontalScrollBarEnabled: !widget.disableScrolling,
    );

    _gestureRecognizers = {
      Factory<LongPressGestureRecognizer>(
        () => LongPressGestureRecognizer(
          duration: PlatformInfo.isAndroid
            ? null
            : _longPressGestureDurationIOS,
        ),
      ),
      if (PlatformInfo.isAndroid && !widget.disableScrolling)
        Factory<ScaleGestureRecognizer>(() => ScaleGestureRecognizer()),
    };

    _initialData();
  }

  @override
  void didUpdateWidget(covariant HtmlContentViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    log('_HtmlContentViewState::didUpdateWidget():Old-Direction: ${oldWidget.direction} | Current-Direction: ${widget.direction}');
    if (widget.contentHtml != oldWidget.contentHtml ||
        widget.direction != oldWidget.direction) {
      _initialData();
    }
  }

  void _initialData() {
    _actualHeight = widget.htmlContentMinHeight;

    _htmlData = HtmlUtils.generateHtmlDocument(
      content: _processedContent,
      direction: widget.direction,
      javaScripts: _combinedScripts,
      styleCSS: _combinedCss,
      contentPadding: widget.contentPadding,
      useDefaultFontStyle: widget.useDefaultFontStyle,
      fontSize: widget.fontSize,
    );
  }

  String get _processedContent => widget.enableQuoteToggle
      ? HtmlUtils.addQuoteToggle(widget.contentHtml)
      : widget.contentHtml;

  String get _combinedCss => [
    if (widget.enableQuoteToggle) HtmlUtils.quoteToggleStyle,
    if (widget.disableScrolling) HtmlTemplate.disableScrollingStyleCSS,
  ].join();

  String get _combinedScripts => [
    HtmlInteraction.scriptsHandleLazyLoadingBackgroundImage,
    if (widget.enableQuoteToggle) HtmlUtils.quoteToggleScript,
    if (widget.initialWidth != null)
      HtmlInteraction.generateNormalizeImageScript(widget.initialWidth!),
    if (_shouldApplyMobileResponsiveStyle)
      MobileEmailResponsiveLayoutScript.generate(
        contentSizeChangedEventJSChannelName:
            HtmlInteraction.contentSizeChangedEventJSChannelName,
      ),
    if (PlatformInfo.isAndroid)
      HtmlInteraction.scriptsHandleContentSizeChanged,
  ].join();

  bool get _shouldApplyMobileResponsiveStyle {
    return HtmlContentViewer.shouldApplyMobileResponsiveLayout(
      widget.configuration,
      PlatformInfo.isMobile
          ? HtmlContentViewerPlatform.mobile
          : HtmlContentViewerPlatform.desktop,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final child = Stack(children: [
      if (_htmlData?.trim().isNotEmpty == true)
        if (widget.maxViewHeight != null)
          Container(
            height: _actualHeight,
            width: widget.initialWidth,
            constraints: BoxConstraints(maxHeight: widget.maxViewHeight!),
            child: _buildWebView(),
          )
        else
          SizedBox(
            height: _actualHeight,
            width: widget.initialWidth,
            child: _buildWebView(),
          ),
      ValueListenableBuilder(
        valueListenable: _loadingBarNotifier,
        builder: (context, loading, child) {
          if (loading) {
            return const CupertinoLoadingWidget(isCenter: false);
          } else {
            return const SizedBox.shrink();
          }
        }
      ),
    ]);

    if (!widget.keepWidthWhileLoading) {
      return child;
    } else {
      return SizedBox(width: widget.initialWidth, child: child);
    }
  }

  Widget _buildWebView() {
    return InAppWebView(
      key: ValueKey(_htmlData),
      initialSettings: _webViewSetting,
      onWebViewCreated: _onWebViewCreated,
      onLoadStop: _onLoadStop,
      onContentSizeChanged: _onContentSizeChanged,
      shouldOverrideUrlLoading: _shouldOverrideUrlLoading,
      gestureRecognizers: _gestureRecognizers,
      onScrollChanged: widget.disableScrolling ? null : _onScrollChanged,
    );
  }

  void _onScrollChanged(InAppWebViewController controller, int x, int y) {
    controller.scrollTo(x: 0, y: 0);
  }

  void _onWebViewCreated(InAppWebViewController controller) async {
    log('_HtmlContentViewState::_onWebViewCreated:');
    _webViewController = controller;
    _registerJavaScriptHandlers(controller);
    await controller.loadData(data: _htmlData ?? '');
  }

  void _registerJavaScriptHandlers(InAppWebViewController controller) {
    if (!widget.disableScrolling) {
      controller.addJavaScriptHandler(
        handlerName: HtmlInteraction.scrollEventJSChannelName,
        callback: _onHandleScrollEvent,
      );
    }

    if (PlatformInfo.isAndroid || _shouldApplyMobileResponsiveStyle) {
      controller.addJavaScriptHandler(
        handlerName: HtmlInteraction.contentSizeChangedEventJSChannelName,
        callback: (_) => _handleContentSizeChanged(),
      );
    }
  }

  void _onLoadStop(InAppWebViewController controller, WebUri? webUri) async {
    await _getActualSizeHtmlViewer();
    // The WebView can finish measuring after this view has been disposed.
    if (!mounted) return;
    _loadingBarNotifier.value = false;
    log('_HtmlContentViewState::_onLoadStop: GestureRecognizers = $_gestureRecognizers');
  }

  void _onContentSizeChanged(
    InAppWebViewController controller,
    Size oldContentSize,
    Size newContentSize
  ) => _handleContentSizeChanged();

  void _onHandleScrollEvent(List<dynamic> parameters) {
    log('_HtmlContentViewState::_onHandleScrollEvent():parameters: $parameters');
    final message = parameters.first;
    if (message == HtmlInteraction.scrollLeftEndAction) {
      widget.onScrollHorizontalEnd?.call(
        HtmlContentViewerHorizontalDirection.left,
      );
    } else if (message == HtmlInteraction.scrollRightEndAction) {
      widget.onScrollHorizontalEnd?.call(
        HtmlContentViewerHorizontalDirection.right,
      );
    }
  }

  void _handleContentSizeChanged() async {
    if (!mounted || _loadingBarNotifier.value) return;

    final dynamic result = await _webViewController.evaluateJavascript(source: 'document.body.scrollHeight');
    // The WebView can finish this request after the email view has been disposed.
    if (!mounted) return;
    if (result is! num) return;

    final double maxContentHeight = result.toDouble();

    double currentHeight = maxContentHeight + widget.offsetHtmlContentHeight;

    if (PlatformInfo.isIOS && widget.maxHtmlContentHeight != null) {
      currentHeight = _reStandardizeHeight(
        currentHeight,
        widget.maxHtmlContentHeight!,
      );
    }

    if (_actualHeight != currentHeight) {
      log('_HtmlContentViewState::_onHandleContentSizeChangedEvent: currentHeight = $currentHeight');
      setState(() {
        _actualHeight = currentHeight;
      });
    }
  }

  Future<void> _getActualSizeHtmlViewer() async {
    final contentMetrics = await _getHtmlContentMetrics();
    if (contentMetrics == null) return;

    final isContentFullyVisible = contentMetrics.isContentFullyVisible;
    final isIOSScrollingEnabled = _shouldEnableIOSScrolling(contentMetrics);
    log('_HtmlContentViewState::_getActualSizeHtmlViewer: isIOSScrollingEnabled = $isIOSScrollingEnabled | isContentFullyVisible = $isContentFullyVisible');

    _updateHtmlContentSize(_HtmlContentSizing(
      contentMetrics: contentMetrics,
      iOSScrollingState: isIOSScrollingEnabled,
    ));
    await _handleHorizontalOverflow(contentMetrics);
  }

  Future<_HtmlContentMetrics?> _getHtmlContentMetrics() async {
    if (!mounted) return null;

    final List<dynamic> results = await Future.wait([
      _webViewController.evaluateJavascript(source: 'document.getElementsByClassName("tmail-content")[0]?.scrollWidth'),
      _webViewController.evaluateJavascript(source: 'document.getElementsByClassName("tmail-content")[0]?.offsetWidth'),
      _webViewController.evaluateJavascript(source: 'document.body?.scrollHeight'),
    ]);
    if (!mounted) return null;

    log('_HtmlContentViewState::_getHtmlContentMetrics(): results: $results');

    return _HtmlContentMetrics.fromJavaScriptResults(results);
  }

  _IOSScrollingState _shouldEnableIOSScrolling(
    _HtmlContentMetrics contentMetrics,
  ) {
    if (contentMetrics.isContentFullyVisible) {
      return _IOSScrollingState.disabled;
    }
    if (!PlatformInfo.isIOS) return _IOSScrollingState.disabled;

    return widget.disableScrolling
        ? _IOSScrollingState.disabled
        : _IOSScrollingState.enabled;
  }

  void _updateHtmlContentSize(_HtmlContentSizing sizing) {
    final currentHeight = _getHtmlContentHeight(sizing.contentMetrics);
    final isHeightChanged = _hasHtmlContentHeightChanged(currentHeight);
    if (!isHeightChanged) {
      if (!sizing.isIOSScrollingEnabled) return;
    }

    setState(() {
      if (currentHeight != null) {
        _actualHeight = currentHeight;
      }
      if (sizing.isIOSScrollingEnabled) {
        _gestureRecognizers = _iOSGestureRecognizersWithScrolling;
      }
    });
  }

  bool _hasHtmlContentHeightChanged(double? currentHeight) {
    if (currentHeight == null) return false;

    return _actualHeight != currentHeight;
  }

  double? _getHtmlContentHeight(_HtmlContentMetrics contentMetrics) {
    final scrollHeight = contentMetrics.scrollHeight;
    if (scrollHeight == null) return null;
    if (scrollHeight <= 0) return null;

    double currentHeight = scrollHeight + widget.offsetHtmlContentHeight;
    if (PlatformInfo.isIOS) {
      final maxHtmlContentHeight = widget.maxHtmlContentHeight;
      if (maxHtmlContentHeight != null) {
        currentHeight = _reStandardizeHeight(
          currentHeight,
          maxHtmlContentHeight,
        );
      }
    }
    log('_HtmlContentViewState::_getHtmlContentHeight: currentHeight = $currentHeight');

    return currentHeight;
  }

  Future<void> _handleHorizontalOverflow(
    _HtmlContentMetrics contentMetrics,
  ) async {
    if (contentMetrics.isContentFullyVisible) return;
    if (widget.disableScrolling) return;

    await _webViewController.evaluateJavascript(
      source: HtmlInteraction.runScriptsHandleScrollEvent,
    );
    if (!mounted) return;

    widget.onLoadWidthHtmlViewer?.call(
      HtmlContentViewerWidthState.overflowed,
    );
  }

  double _reStandardizeHeight(double currentHeight, double maxHtmlContentHeight) {
    final bool isClipped = currentHeight > maxHtmlContentHeight;
    if (isClipped) {
      widget.onHtmlContentClippedAction?.call(
        HtmlContentViewerContentClipping.clipped,
      );
    }

    return currentHeight.clamp(
      widget.htmlContentMinHeight,
      maxHtmlContentHeight,
    );
  }

  Set<Factory<OneSequenceGestureRecognizer>> get _iOSGestureRecognizersWithScrolling => {
    Factory<LongPressGestureRecognizer>(
      () => LongPressGestureRecognizer(
        duration: _longPressGestureDurationIOS,
      ),
    ),
    Factory<HorizontalDragGestureRecognizer>(
      () => HorizontalDragGestureRecognizer(),
    ),
  };

  Future<NavigationActionPolicy?> _shouldOverrideUrlLoading(
    InAppWebViewController controller,
    NavigationAction navigationAction
  ) async {
    final url = navigationAction.request.url?.toString();
    log('_HtmlContentViewState::_shouldOverrideUrlLoading: URL = $url');
    if (url == null) {
      return NavigationActionPolicy.CANCEL;
    }

    if (_shouldAllowInitialPage(navigationAction)) {
      return NavigationActionPolicy.ALLOW;
    }

    final requestUri = Uri.parse(url);
    if (await _handleInternalUrl(requestUri)) {
      return NavigationActionPolicy.CANCEL;
    }

    await _launchExternalUrl(requestUri);

    return NavigationActionPolicy.CANCEL;
  }

  bool _shouldAllowInitialPage(NavigationAction navigationAction) {
    if (!navigationAction.isForMainFrame) return false;

    return navigationAction.request.url?.toString() == 'about:blank';
  }

  Future<bool> _handleInternalUrl(Uri requestUri) async {
    final urlDelegate = _getInternalUrlDelegate(requestUri);
    if (urlDelegate == null) return false;

    await urlDelegate(requestUri);

    return true;
  }

  Future<void> Function(Uri?)? _getInternalUrlDelegate(Uri requestUri) {
    if (requestUri.isScheme(Constant.mailtoScheme)) {
      return widget.onMailtoDelegateAction;
    }
    if (requestUri.isScheme(Constant.emlPreviewerScheme)) {
      return widget.onPreviewEMLDelegateAction;
    }
    if (requestUri.isScheme(Constant.attachmentScheme)) {
      return widget.onDownloadAttachmentDelegateAction;
    }

    return null;
  }

  Future<void> _launchExternalUrl(Uri requestUri) async {
    if (!await launcher.canLaunchUrl(requestUri)) return;

    await launcher.launchUrl(
      requestUri,
      mode: LaunchMode.externalApplication
    );
  }

  Duration? get _longPressGestureDurationIOS => const Duration(milliseconds: 100);

  @override
  void dispose() {
    _loadingBarNotifier.dispose();
    _htmlData = null;
    if (kDebugMode) {
      try {
        _webViewController.dispose();
      } catch (e) {
        logWarning('_HtmlContentViewState:dispose:_webViewController.dispose: $e');
      }
    } else {
      _webViewController.dispose();
    }
    super.dispose();
  }
  
  @override
  bool get wantKeepAlive => widget.keepAlive;
}
