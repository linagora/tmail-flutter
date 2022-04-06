import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:developer' as developer;

class HtmlContentViewer extends StatefulWidget {

  final String contentHtml;
  final double widthContent;
  final Widget? loadingWidget;

  /// Register this callback if you want a reference to the [WebViewController].
  final void Function(WebViewController controller)? onCreated;

  /// Handler for mailto: links
  final Future Function(Uri mailto)? mailtoDelegate;

  /// Handler for any non-media URLs that the user taps on the website.
  ///
  /// Returns `true` when the given `url` was handled.
  final Future<bool> Function(String url)? urlLauncherDelegate;

  const HtmlContentViewer({
    Key? key,
    required this.contentHtml,
    required this.widthContent,
    this.loadingWidget,
    this.onCreated,
    this.urlLauncherDelegate,
    this.mailtoDelegate,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HtmlContentViewState();
}

class _HtmlContentViewState extends State<HtmlContentViewer> {

  double? _webViewHeight = 1.0;
  double? _webViewWidth = 1.0;
  int minHeight = 100;
  String? _htmlData;
  late WebViewController _webViewController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _webViewWidth = widget.widthContent;
    _htmlData = _generateHtmlDocument(widget.contentHtml);
  }

  String _generateHtmlDocument(String content) {
    final htmlTemplate = '''
      <!DOCTYPE html>
      <html>
      <head>
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
      <style>
        #editor {
          outline: 0px solid transparent;
          min-height: ${minHeight}px;
          min-width: 300px;
          color: #182952;
          font-family: verdana;
        }
        table {
          width: 100%;
          max-width: 100%;
        }
        td {
          padding: 13px;
          margin: 0px;
        }
        th {
          padding: 13px;
          margin: 0px;
        }
      </style>
      <script>
        var documentHeight;

        function onLoaded() {
          documentHeight = document.body.scrollHeight;
          document.execCommand("styleWithCSS", false, true);
        }
      </script>
      </head>
      <body onload="onLoaded();">
      <div id="editor">$content</div>
      </body>
      </html> 
    ''';
    return htmlTemplate;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: _webViewHeight,
          width: _webViewWidth,
          child: _buildWebView(),
        ),
        if (_isLoading) Align(alignment: Alignment.center, child: _buildLoadingView())
      ],
    );
  }

  Widget _buildLoadingView() {
    if (widget.loadingWidget != null) {
      return widget.loadingWidget!;
    } else {
      return Padding(
        padding: EdgeInsets.all(16),
        child: SizedBox(
          width: 30,
          height: 30,
          child: CircularProgressIndicator(color: AppColor.primaryColor)));
    }
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
              _webViewHeight = scrollHeightWithBuffer;
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
      navigationDelegate: _onNavigation,
      gestureRecognizers: {
        Factory<LongPressGestureRecognizer>(() => LongPressGestureRecognizer()),
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
      final handled = await urlDelegate(url);
      if (handled) {
        return NavigationDecision.prevent;
      }
    }
    await launcher.launch(url);
    return NavigationDecision.prevent;
  }
}