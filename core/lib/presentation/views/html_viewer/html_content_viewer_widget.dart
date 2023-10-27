import 'dart:async';
import 'dart:math' as math;

import 'package:core/core.dart';
import 'package:core/presentation/utils/html_transformer/html_event_action.dart';
import 'package:core/presentation/utils/html_transformer/html_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;
import 'package:url_launcher/url_launcher_string.dart';

typedef OnScrollHorizontalEndAction = Function(bool leftDirection);
typedef OnLoadWidthHtmlViewerAction = Function(bool isScrollPageViewActivated);
typedef OnMailtoDelegateAction = Future<void> Function(Uri? uri);

class HtmlContentViewer extends StatefulWidget {

  final String contentHtml;
  final double? initialWidth;
  final TextDirection? direction;

  final OnLoadWidthHtmlViewerAction? onLoadWidthHtmlViewer;
  final OnMailtoDelegateAction? onMailtoDelegateAction;
  final OnScrollHorizontalEndAction? onScrollHorizontalEnd;

  const HtmlContentViewer({
    Key? key,
    required this.contentHtml,
    this.initialWidth,
    this.direction,
    this.onLoadWidthHtmlViewer,
    this.onMailtoDelegateAction,
    this.onScrollHorizontalEnd
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HtmlContentViewState();
}

class _HtmlContentViewState extends State<HtmlContentViewer> {

  static const double _minHeight = 100.0;
  static const double _offsetHeight = 30.0;

  late InAppWebViewController _webViewController;
  late double _actualHeight;
  late Set<Factory<OneSequenceGestureRecognizer>> _gestureRecognizers;

  final _loadingBarNotifier = ValueNotifier(true);

  String? _htmlData;

  final _webViewSetting = InAppWebViewSettings(
    transparentBackground: true,
    verticalScrollBarEnabled: false,
  );

  @override
  void initState() {
    super.initState();
    _actualHeight = _minHeight;
    if (PlatformInfo.isAndroid) {
      _gestureRecognizers = {
        Factory<LongPressGestureRecognizer>(() => LongPressGestureRecognizer()),
        Factory<ScaleGestureRecognizer>(() => ScaleGestureRecognizer()),
      };
    } else {
      _gestureRecognizers = {
        Factory<LongPressGestureRecognizer>(() => LongPressGestureRecognizer()),
      };
    }
    _htmlData = generateHtml(
      widget.contentHtml,
      direction: widget.direction,
      javaScripts: PlatformInfo.isAndroid
        ? HtmlUtils.scriptsHandleContentSizeChanged
        : null
    );
  }

  @override
  void didUpdateWidget(covariant HtmlContentViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    log('_HtmlContentViewState::didUpdateWidget():Old-Direction: ${oldWidget.direction} | Current-Direction: ${widget.direction}');
    if (widget.contentHtml != oldWidget.contentHtml ||
        widget.direction != oldWidget.direction) {
      _actualHeight = _minHeight;
      _htmlData = generateHtml(
        widget.contentHtml,
        direction: widget.direction,
        javaScripts: PlatformInfo.isAndroid
          ? HtmlUtils.scriptsHandleContentSizeChanged
          : null
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
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
  }

  void _onWebViewCreated(InAppWebViewController controller) async {
    log('_HtmlContentViewState::_onWebViewCreated:');
    _webViewController = controller;

    await controller.loadData(data: _htmlData ?? '');

    controller.addJavaScriptHandler(
      handlerName: HtmlUtils.scrollEventJSChannelName,
      callback: _onHandleScrollEvent
    );

    if (PlatformInfo.isAndroid) {
      controller.addJavaScriptHandler(
        handlerName: HtmlUtils.contentSizeChangedEventJSChannelName,
        callback: _onHandleContentSizeChangedEvent
      );
    }
  }

  void _onLoadStop(InAppWebViewController controller, WebUri? webUri) async {
    log('_HtmlContentViewState::_onLoadStop:');
    await _getActualSizeHtmlViewer();
    _loadingBarNotifier.value = false;
  }

  void _onContentSizeChanged(
    InAppWebViewController controller,
    Size oldContentSize,
    Size newContentSize
  ) async {
    final maxContentHeight = math.max(oldContentSize.height, newContentSize.height);
    log('_HtmlContentViewState::_onContentSizeChanged:maxContentHeight: $maxContentHeight');
    if (maxContentHeight > _actualHeight && !_loadingBarNotifier.value && mounted) {
      log('_HtmlContentViewState::_onContentSizeChanged:HEIGHT_UPDATED: $maxContentHeight');
      setState(() {
        _actualHeight = maxContentHeight + _offsetHeight;
      });
    }
  }

  void _onHandleScrollEvent(List<dynamic> parameters) {
    log('_HtmlContentViewState::_onHandleScrollEvent():parameters: $parameters');
    final message = parameters.first;
    if (message == HtmlEventAction.scrollLeftEndAction) {
      widget.onScrollHorizontalEnd?.call(true);
    } else if (message == HtmlEventAction.scrollRightEndAction) {
      widget.onScrollHorizontalEnd?.call(false);
    }
  }

  void _onHandleContentSizeChangedEvent(List<dynamic> parameters) async {
    final maxContentHeight = await _webViewController.evaluateJavascript(source: 'document.body.scrollHeight');
    log('_HtmlContentViewState::_onHandleContentSizeChangedEvent:maxContentHeight: $maxContentHeight');
    if (maxContentHeight is num && maxContentHeight > _actualHeight && !_loadingBarNotifier.value && mounted) {
      log('_HtmlContentViewState::_onHandleContentSizeChangedEvent:HEIGHT_UPDATED: $maxContentHeight');
      setState(() {
        _actualHeight = maxContentHeight + _offsetHeight;
      });
    }
  }

  Future<void> _getActualSizeHtmlViewer() async {
    final listSize = await Future.wait([
      _webViewController.evaluateJavascript(source: 'document.getElementsByClassName("tmail-content")[0].scrollWidth'),
      _webViewController.evaluateJavascript(source: 'document.getElementsByClassName("tmail-content")[0].offsetWidth'),
      _webViewController.evaluateJavascript(source: 'document.body.scrollHeight'),
    ]);
    log('_HtmlContentViewState::_getActualSizeHtmlViewer():listSize: $listSize');
    Set<Factory<OneSequenceGestureRecognizer>>? newGestureRecognizers;
    bool isScrollActivated = false;

    if (listSize[0] is num && listSize[1] is num) {
      final scrollWidth = listSize[0] as num;
      final offsetWidth = listSize[1] as num;
      isScrollActivated = scrollWidth.round() == offsetWidth.round();

      if (!isScrollActivated && PlatformInfo.isIOS) {
        newGestureRecognizers = {
          Factory<LongPressGestureRecognizer>(() => LongPressGestureRecognizer()),
          Factory<HorizontalDragGestureRecognizer>(() => HorizontalDragGestureRecognizer())
        };
      }
    }

    if (listSize[2] is num) {
      final scrollHeight = listSize[2] as num;
      if (mounted && scrollHeight > 0) {
        setState(() {
          _actualHeight = scrollHeight + _offsetHeight;
          if (newGestureRecognizers != null) {
            _gestureRecognizers = newGestureRecognizers;
          }
        });
      }
    } else {
      if (mounted && newGestureRecognizers != null) {
        setState(() {
          _gestureRecognizers = newGestureRecognizers!;
        });
      }
    }

    if (!isScrollActivated) {
      await _webViewController.evaluateJavascript(source: HtmlUtils.runScriptsHandleScrollEvent);
    }
    widget.onLoadWidthHtmlViewer?.call(isScrollActivated);
  }

  Future<NavigationActionPolicy?> _shouldOverrideUrlLoading(
    InAppWebViewController controller,
    NavigationAction navigationAction
  ) async {
    final url = navigationAction.request.url?.toString();

    if (url == null) {
      return NavigationActionPolicy.CANCEL;
    }

    if (navigationAction.isForMainFrame && url == 'about:blank') {
      return NavigationActionPolicy.ALLOW;
    }

    final requestUri = Uri.parse(url);
    final mailtoHandler = widget.onMailtoDelegateAction;
    if (mailtoHandler != null && requestUri.isScheme('mailto')) {
      await mailtoHandler(requestUri);
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

  @override
  void dispose() {
    _loadingBarNotifier.dispose();
    super.dispose();
  }
}