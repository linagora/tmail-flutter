import 'dart:async';

import 'package:core/data/constants/constant.dart';
import 'package:core/presentation/constants/constants_ui.dart';
import 'package:core/presentation/views/loading/cupertino_loading_widget.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/html/html_interaction.dart';
import 'package:core/utils/html/html_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;
import 'package:url_launcher/url_launcher_string.dart';

typedef OnScrollHorizontalEndAction = Function(bool leftDirection);
typedef OnLoadWidthHtmlViewerAction = Function(bool isScrollPageViewActivated);
typedef OnMailtoDelegateAction = Future<void> Function(Uri? uri);
typedef OnPreviewEMLDelegateAction = Future<void> Function(Uri? uri);
typedef OnDownloadAttachmentDelegateAction = Future<void> Function(Uri? uri);
typedef OnHtmlContentClippedAction = Function(bool isClipped);

class HtmlContentViewer extends StatefulWidget {

  final String contentHtml;
  final double? initialWidth;
  final TextDirection? direction;
  final bool keepWidthWhileLoading;
  final double? contentPadding;
  final bool useDefaultFont;
  final double? maxHtmlContentHeight;
  final double minHtmlContentHeight;
  final double offsetHtmlContentHeight;

  final OnLoadWidthHtmlViewerAction? onLoadWidthHtmlViewer;
  final OnMailtoDelegateAction? onMailtoDelegateAction;
  final OnScrollHorizontalEndAction? onScrollHorizontalEnd;
  final OnPreviewEMLDelegateAction? onPreviewEMLDelegateAction;
  final OnDownloadAttachmentDelegateAction? onDownloadAttachmentDelegateAction;
  final OnHtmlContentClippedAction? onHtmlContentClippedAction;

  const HtmlContentViewer({
    Key? key,
    required this.contentHtml,
    this.initialWidth,
    this.direction,
    this.minHtmlContentHeight = ConstantsUI.htmlContentMinHeight,
    this.offsetHtmlContentHeight = ConstantsUI.htmlContentOffsetHeight,
    this.keepWidthWhileLoading = false,
    this.contentPadding,
    this.useDefaultFont = false,
    this.maxHtmlContentHeight,
    this.onLoadWidthHtmlViewer,
    this.onMailtoDelegateAction,
    this.onScrollHorizontalEnd,
    this.onPreviewEMLDelegateAction,
    this.onDownloadAttachmentDelegateAction,
    this.onHtmlContentClippedAction,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => HtmlContentViewState();
}

class HtmlContentViewState extends State<HtmlContentViewer> {

  late InAppWebViewController _webViewController;
  late double _actualHeight;
  late Set<Factory<OneSequenceGestureRecognizer>> _gestureRecognizers;
  late StringBuffer _customScriptsBuilder;

  final _loadingBarNotifier = ValueNotifier(true);

  String? _htmlData;

  final _webViewSetting = InAppWebViewSettings(
    transparentBackground: true,
    verticalScrollBarEnabled: false,
    supportZoom: false,
  );

  @visibleForTesting
  InAppWebViewController get webViewController => _webViewController;

  @override
  void initState() {
    super.initState();
    if (PlatformInfo.isAndroid) {
      _gestureRecognizers = {
        Factory<LongPressGestureRecognizer>(() => LongPressGestureRecognizer()),
        Factory<ScaleGestureRecognizer>(() => ScaleGestureRecognizer()),
      };
    } else {
      _gestureRecognizers = {
        Factory<LongPressGestureRecognizer>(() => LongPressGestureRecognizer(duration: _longPressGestureDurationIOS)),
      };
    }
    _customScriptsBuilder = StringBuffer();
    _customScriptsBuilder.write(HtmlInteraction.scriptsHandleLazyLoadingBackgroundImage);
    if (widget.initialWidth != null) {
      _customScriptsBuilder.write(HtmlInteraction.generateNormalizeImageScript(widget.initialWidth!));
    }
    if (PlatformInfo.isAndroid) {
      _customScriptsBuilder.write(HtmlInteraction.scriptsHandleContentSizeChanged);
    }
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
    _actualHeight = widget.minHtmlContentHeight;
    _htmlData = HtmlUtils.generateHtmlDocument(
      content: widget.contentHtml,
      direction: widget.direction,
      javaScripts: _customScriptsBuilder.toString(),
      contentPadding: widget.contentPadding,
      useDefaultFont: widget.useDefaultFont,
    );
  }

  @override
  Widget build(BuildContext context) {
    final child = Stack(children: [
      if (_htmlData == null)
        const SizedBox.shrink()
      else
        SizedBox(
          height: _actualHeight,
          width: widget.initialWidth,
          child: InAppWebView(
            key: ValueKey(_htmlData),
            initialSettings: _webViewSetting,
            onWebViewCreated: _onWebViewCreated,
            onLoadStop: _onLoadStop,
            onContentSizeChanged: _onContentSizeChanged,
            shouldOverrideUrlLoading: _shouldOverrideUrlLoading,
            gestureRecognizers: _gestureRecognizers,
            onScrollChanged: (controller, x, y) => controller.scrollTo(x: 0, y: 0)
          )
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

    if (!widget.keepWidthWhileLoading) return child;
    return SizedBox(
      width: widget.initialWidth,
      child: child,
    );
  }

  void _onWebViewCreated(InAppWebViewController controller) async {
    log('_HtmlContentViewState::_onWebViewCreated:');
    _webViewController = controller;

    await controller.loadData(data: _htmlData ?? '');

    controller.addJavaScriptHandler(
      handlerName: HtmlInteraction.scrollEventJSChannelName,
      callback: _onHandleScrollEvent
    );

    if (PlatformInfo.isAndroid) {
      controller.addJavaScriptHandler(
        handlerName: HtmlInteraction.contentSizeChangedEventJSChannelName,
        callback: (_) => _handleContentSizeChanged(),
      );
    }
  }

  void _onLoadStop(InAppWebViewController controller, WebUri? webUri) async {
    await _getActualSizeHtmlViewer();
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
      widget.onScrollHorizontalEnd?.call(true);
    } else if (message == HtmlInteraction.scrollRightEndAction) {
      widget.onScrollHorizontalEnd?.call(false);
    }
  }

  void _handleContentSizeChanged() async {
    if (!mounted || _loadingBarNotifier.value) return;

    final dynamic result = await _webViewController.evaluateJavascript(source: 'document.body.scrollHeight');
    if (result is! num) return;

    final double maxContentHeight = result.toDouble();
    if (maxContentHeight <= _actualHeight) return;

    double currentHeight = maxContentHeight + widget.offsetHtmlContentHeight;

    if (PlatformInfo.isIOS && widget.maxHtmlContentHeight != null) {
      final bool isClipped = currentHeight > widget.maxHtmlContentHeight!;
      if (isClipped) {
        widget.onHtmlContentClippedAction?.call(true);
      }
      currentHeight = currentHeight.clamp(
        widget.minHtmlContentHeight,
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
    if (!mounted) return;

    final List<dynamic> listSize = await Future.wait([
      _webViewController.evaluateJavascript(source: 'document.getElementsByClassName("tmail-content")[0]?.scrollWidth'),
      _webViewController.evaluateJavascript(source: 'document.getElementsByClassName("tmail-content")[0]?.offsetWidth'),
      _webViewController.evaluateJavascript(source: 'document.body?.scrollHeight'),
    ]);

    log('_HtmlContentViewState::_getActualSizeHtmlViewer(): listSize: $listSize');

    bool isScrollActivated = false;
    Set<Factory<OneSequenceGestureRecognizer>>? newGestureRecognizers;

    final double? scrollWidth = listSize[0] is num ? (listSize[0] as num).toDouble() : null;
    final double? offsetWidth = listSize[1] is num ? (listSize[1] as num).toDouble() : null;
    final double? scrollHeight = listSize[2] is num ? (listSize[2] as num).toDouble() : null;

    if (scrollWidth != null && offsetWidth != null) {
      isScrollActivated = scrollWidth.round() == offsetWidth.round();
      if (!isScrollActivated && PlatformInfo.isIOS) {
        newGestureRecognizers = {
          Factory<LongPressGestureRecognizer>(() => LongPressGestureRecognizer(duration: _longPressGestureDurationIOS)),
          Factory<HorizontalDragGestureRecognizer>(() => HorizontalDragGestureRecognizer()),
        };
      }
    }

    if (scrollHeight != null && scrollHeight > 0) {
      double currentHeight = scrollHeight + widget.offsetHtmlContentHeight;

      if (PlatformInfo.isIOS && widget.maxHtmlContentHeight != null) {
        final bool isClipped = currentHeight > widget.maxHtmlContentHeight!;
        if (isClipped) {
          widget.onHtmlContentClippedAction?.call(true);
        }
        currentHeight = currentHeight.clamp(
          widget.minHtmlContentHeight,
          widget.maxHtmlContentHeight!,
        );
      }

      if (_actualHeight != currentHeight || newGestureRecognizers != null) {
        log('_HtmlContentViewState::_getActualSizeHtmlViewer: currentHeight = $currentHeight');
        setState(() {
          _actualHeight = currentHeight;
          if (newGestureRecognizers != null) {
            _gestureRecognizers = newGestureRecognizers;
          }
        });
      }
    } else if (newGestureRecognizers != null) {
      setState(() {
        _gestureRecognizers = newGestureRecognizers!;
      });
    }

    if (!isScrollActivated) {
      await _webViewController.evaluateJavascript(source: HtmlInteraction.runScriptsHandleScrollEvent);
    }
    widget.onLoadWidthHtmlViewer?.call(isScrollActivated);
  }

  Future<NavigationActionPolicy?> _shouldOverrideUrlLoading(
    InAppWebViewController controller,
    NavigationAction navigationAction
  ) async {
    final url = navigationAction.request.url?.toString();
    log('_HtmlContentViewState::_shouldOverrideUrlLoading: URL = $url');
    if (url == null) {
      return NavigationActionPolicy.CANCEL;
    }

    if (navigationAction.isForMainFrame && url == 'about:blank') {
      return NavigationActionPolicy.ALLOW;
    }

    final requestUri = Uri.parse(url);
    if (widget.onMailtoDelegateAction != null &&
        requestUri.isScheme(Constant.mailtoScheme)) {
      await widget.onMailtoDelegateAction?.call(requestUri);
      return NavigationActionPolicy.CANCEL;
    }

    if (widget.onPreviewEMLDelegateAction != null &&
        requestUri.isScheme(Constant.emlPreviewerScheme)) {
      await widget.onPreviewEMLDelegateAction?.call(requestUri);
      return NavigationActionPolicy.CANCEL;
    }

    if (widget.onDownloadAttachmentDelegateAction != null &&
        requestUri.isScheme(Constant.attachmentScheme)) {
      await widget.onDownloadAttachmentDelegateAction?.call(requestUri);
      return NavigationActionPolicy.CANCEL;
    }

    if (await launcher.canLaunchUrl(Uri.parse(url))) {
      await launcher.launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication
      );
    }

    return NavigationActionPolicy.CANCEL;
  }

  Duration? get _longPressGestureDurationIOS => const Duration(milliseconds: 100);

  @override
  void dispose() {
    _loadingBarNotifier.dispose();
    _htmlData = null;
    super.dispose();
  }
}