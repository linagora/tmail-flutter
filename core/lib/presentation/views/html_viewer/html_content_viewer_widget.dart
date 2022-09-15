import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:core/core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;
import 'package:url_launcher/url_launcher_string.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:developer' as developer;

class HtmlContentViewer extends StatefulWidget {

  final String contentHtml;
  final double heightContent;

  /// Register this callback if you want a reference to the [WebViewController].
  final void Function(WebViewController controller)? onCreated;

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
    this.urlLauncherDelegate,
    this.mailtoDelegate,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HtmlContentViewState();
}

class _HtmlContentViewState extends State<HtmlContentViewer> {

  late double actualHeight;
  double minHeight = 100;
  double minWidth = 300;
  late double maxHeightForAndroid;
  String? _htmlData;
  late WebViewController _webViewController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    actualHeight = widget.heightContent;
    maxHeightForAndroid = window.physicalSize.height;
    log('_HtmlContentViewState::initState(): maxHeightForAndroid: $maxHeightForAndroid');
    _htmlData = _generateHtmlDocument(widget.contentHtml);
  }

  String _generateHtmlDocument(String content) {
    final htmlTemplate = generateHtml(content);
    return htmlTemplate;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Stack(
        children: [
          SizedBox(
            height: actualHeight,
            width: constraints.maxWidth,
            child: _buildWebView()),
          if (_isLoading) Align(alignment: Alignment.center, child: _buildLoadingView())
        ],
      );
    });
  }

  Widget _buildLoadingView() {
    return Padding(
        padding: EdgeInsets.all(16),
        child: SizedBox(
          width: 30,
          height: 30,
          child: CupertinoActivityIndicator(color: AppColor.colorLoading)));
  }

  Widget _buildWebView() {
    final htmlData = _htmlData;
    if (htmlData == null || htmlData.isEmpty) {
      return Container();
    }
    return WebView(
      key: ValueKey(htmlData),
      javascriptMode: JavascriptMode.unrestricted,
      backgroundColor: Colors.white,
      onWebViewCreated: (controller) async {
        _webViewController = controller;
        await controller.loadHtmlString(htmlData, baseUrl: null);
        widget.onCreated?.call(controller);
      },
      onPageFinished: (url) async {
          final scrollHeightText = await _webViewController.runJavascriptReturningResult('document.body.scrollHeight');
          final scrollHeight = double.tryParse(scrollHeightText);
          developer.log('onPageFinished(): scrollHeightText: $scrollHeightText', name: 'HtmlContentViewer');
          if ((scrollHeight != null) && mounted) {
            final scrollHeightWithBuffer = scrollHeight + 30.0;
            if (scrollHeightWithBuffer > minHeight) {
              setState(() {
                //TODO: It hotfix for web_view crash on android device and waiting lib web_view update to fix this issue
                if (Platform.isAndroid && scrollHeightWithBuffer > maxHeightForAndroid){
                  actualHeight = maxHeightForAndroid;
                } else {
                  actualHeight = scrollHeightWithBuffer;
                }
                _isLoading = false;
              });
            }
          }
        if (mounted && _isLoading) {
          setState(() {
            _isLoading = false;
          });
        }
      },
      zoomEnabled: false,
      navigationDelegate: _onNavigation,
      gestureRecognizers: {
        Factory<LongPressGestureRecognizer>(() => LongPressGestureRecognizer()),
        if (Platform.isAndroid)
          Factory<ScaleGestureRecognizer>(() => ScaleGestureRecognizer()),
      },
    );
  }

  FutureOr<NavigationDecision> _onNavigation(NavigationRequest navigation) async {
    if (navigation.isForMainFrame && navigation.url == 'about:blank') {
      return NavigationDecision.navigate;
    }
    final requestUri = Uri.parse(navigation.url);
    final mailtoHandler = widget.mailtoDelegate;
    if (mailtoHandler != null && requestUri.isScheme('mailto')) {
      await mailtoHandler(requestUri);
      return NavigationDecision.prevent;
    }
    final url = navigation.url;
    final urlDelegate = widget.urlLauncherDelegate;
    if (urlDelegate != null) {
      await urlDelegate(Uri.parse(url));
      return NavigationDecision.prevent;
    }
    if (await launcher.canLaunchUrl(Uri.parse(url))) {
      await launcher.launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication
      );
    }
    return NavigationDecision.prevent;
  }
}