import 'dart:async';
import 'dart:io';

import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/html_transformer/html_event_action.dart';
import 'package:core/presentation/utils/html_transformer/html_template.dart';
import 'package:core/presentation/utils/html_transformer/html_utils.dart';
import 'package:core/utils/app_logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;
import 'package:url_launcher/url_launcher_string.dart';

typedef OnScrollHorizontalEnd = Function(bool leftDirection);
typedef OnWebViewLoaded = Function(bool isScrollPageViewActivated);

class HtmlContentViewer extends StatefulWidget {

  final String contentHtml;
  final double heightContent;
  final OnScrollHorizontalEnd? onScrollHorizontalEnd;
  final OnWebViewLoaded? onWebViewLoaded;
  final TextDirection? direction;

  /// Register this callback if you want a reference to the [InAppWebViewController].
  final void Function(InAppWebViewController controller)? onCreated;

  /// Handler for mailto: links
  final Future Function(Uri mailto)? mailtoDelegate;

  /// Handler for any non-media URLs that the user taps on the website.
  ///
  /// Returns `true` when the given `url` was handled.
  final Future<bool> Function(Uri url)? urlLauncherDelegate;

  const HtmlContentViewer({
    Key? key,
    required this.contentHtml,
    required this.heightContent,
    this.onCreated,
    this.onWebViewLoaded,
    this.onScrollHorizontalEnd,
    this.urlLauncherDelegate,
    this.mailtoDelegate,
    this.direction,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HtmlContentViewState();
}

class _HtmlContentViewState extends State<HtmlContentViewer> {

  late double actualHeight;
  double minHeight = 100;
  double minWidth = 300;
  String? _htmlData;
  late InAppWebViewController _webViewController;
  bool _isLoading = true;
  bool horizontalGestureActivated = false;

  @override
  void initState() {
    super.initState();
    actualHeight = widget.heightContent;
    _htmlData = generateHtml(
      widget.contentHtml,
      direction: widget.direction,
      javaScripts: HtmlUtils.scriptLazyLoadImage
    );
  }

  @override
  void didUpdateWidget(covariant HtmlContentViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    log('_HtmlContentViewState::didUpdateWidget():Old-Direction: ${oldWidget.direction} | Current-Direction: ${widget.direction}');
    if (widget.contentHtml != oldWidget.contentHtml ||
        widget.direction != oldWidget.direction) {
      _htmlData = generateHtml(
        widget.contentHtml,
        direction: widget.direction,
        javaScripts: HtmlUtils.scriptLazyLoadImage
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Stack(
        children: [
          if (_htmlData?.isNotEmpty == false)
            const SizedBox.shrink()
          else
            SizedBox(
              height: actualHeight,
              width: constraints.maxWidth,
              child: InAppWebView(
                key: ValueKey(_htmlData),
                initialSettings: InAppWebViewSettings(
                  transparentBackground: true,
                ),
                onWebViewCreated: (controller) async {
                  _webViewController = controller;
                  await controller.loadData(data: _htmlData ?? '');
                  widget.onCreated?.call(controller);
                },
                onLoadStop: _onLoadStop,
                shouldOverrideUrlLoading: _shouldOverrideUrlLoading,
                gestureRecognizers: {
                  Factory<LongPressGestureRecognizer>(() => LongPressGestureRecognizer()),
                  if (Platform.isIOS && horizontalGestureActivated)
                    Factory<HorizontalDragGestureRecognizer>(() => HorizontalDragGestureRecognizer()),
                  if (Platform.isAndroid)
                    Factory<ScaleGestureRecognizer>(() => ScaleGestureRecognizer()),
                },
                onScrollChanged: (controller, x, y) => controller.scrollTo(x: 0, y: 0)
              ),
            ),
          if (_isLoading)
            const Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 30,
                  height: 30,
                  child: CupertinoActivityIndicator(
                    color: AppColor.colorLoading
                  )
                )
              )
            )
        ],
      );
    });
  }

  void _onLoadStop(InAppWebViewController controller, WebUri? webUri) async {
    await Future.wait([
      _setActualHeightView(),
      _setActualWidthView(),
    ]);

    _hideLoadingProgress();

    controller.addJavaScriptHandler(
      handlerName: HtmlUtils.scrollEventJSChannelName,
      callback: _onHandleScrollEvent
    );
  }

  void _onHandleScrollEvent(List<dynamic> parameters) {
    log('_HtmlContentViewState::_onHandleScrollRightEvent():parameters: $parameters');
    final message = parameters.first;
    log('_HtmlContentViewState::_onHandleScrollRightEvent():message: $message');
    if (message == HtmlEventAction.scrollLeftEndAction) {
      widget.onScrollHorizontalEnd?.call(true);
    } else if (message == HtmlEventAction.scrollRightEndAction) {
      widget.onScrollHorizontalEnd?.call(false);
    }
  }

  Future<void> _setActualHeightView() async {
    final scrollHeight = await _webViewController.evaluateJavascript(source: 'document.body.scrollHeight');
    if (scrollHeight != null && mounted) {
      final scrollHeightWithBuffer = scrollHeight + 30.0;
      if (scrollHeightWithBuffer > minHeight) {
        setState(() {
          actualHeight = scrollHeightWithBuffer;
          _isLoading = false;
        });
      } else {
        actualHeight = minHeight;
      }
    }
  }

  Future<void> _setActualWidthView() async {
    final result = await Future.wait([
      _webViewController.evaluateJavascript(source: 'document.getElementsByClassName("tmail-content")[0].scrollWidth'),
      _webViewController.evaluateJavascript(source: 'document.getElementsByClassName("tmail-content")[0].offsetWidth')
    ]);

    if (result.length == 2) {
      final scrollWidth = result[0];
      final offsetWidth = result[1];
      if (scrollWidth != null && offsetWidth != null && mounted) {
        final isScrollActivated = scrollWidth.round() == offsetWidth.round();
        if (isScrollActivated) {
          setState(() {
            horizontalGestureActivated = false;
          });
        } else {
          setState(() {
            horizontalGestureActivated = true;
          });

          await _webViewController.evaluateJavascript(source: HtmlUtils.runScriptsHandleScrollEvent);
        }

        widget.onWebViewLoaded?.call(isScrollActivated);
      }
    }
  }

  void _hideLoadingProgress() {
    if (mounted && _isLoading) {
      setState(() {
        _isLoading = false;
      });
    }
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
    final mailtoHandler = widget.mailtoDelegate;
    if (mailtoHandler != null && requestUri.isScheme('mailto')) {
      await mailtoHandler(requestUri);
      return NavigationActionPolicy.CANCEL;
    }

    final urlDelegate = widget.urlLauncherDelegate;
    if (urlDelegate != null) {
      await urlDelegate(Uri.parse(url));
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
}