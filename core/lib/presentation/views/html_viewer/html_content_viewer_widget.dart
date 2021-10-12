import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

class HtmlContentViewer extends StatefulWidget {

  final String contentHtml;
  final int minHeight;

  /// Register this callback if you want a reference to the [InAppWebViewController].
  final void Function(InAppWebViewController controller)? onCreated;

  final void Function(InAppWebViewController controller, Uri? uri)? onLoadStart;

  final void Function(InAppWebViewController controller, Uri? uri)? onLoadStop;

  /// Handler for mailto: links
  final Future Function(Uri mailto)? mailtoDelegate;

  const HtmlContentViewer({
    Key? key,
    required this.contentHtml,
    this.minHeight = 100,
    this.onCreated,
    this.onLoadStart,
    this.onLoadStop,
    this.mailtoDelegate,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HtmlContentViewState();
}

class _HtmlContentViewState extends State<HtmlContentViewer> {

  double? _documentHeight = 1.0;
  double? _documentWidth = 1.0;
  String? _initialPageContent;
  late InAppWebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    _initialPageContent = _generateHtmlDocument(widget.contentHtml);
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
          min-height: ${widget.minHeight}px;
          min-width: 300px;
          color: #182952;
          font-family: verdana;
        }
        blockquote {
          font: normal helvetica, verdana;
          margin-top: 10px;
          margin-bottom: 10px;
          margin-left: 20px;
          padding-left: 15px;
          border-left: 5px solid #eee;
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
    final size = MediaQuery.of(context).size;
    _documentWidth = size.width - 30;
    return SizedBox(
      height: _documentHeight,
      width: _documentWidth,
      child: _buildWebView(),
    );
  }

  Widget _buildWebView() {
    if (_initialPageContent == null || _initialPageContent?.isEmpty == true) {
      return Container();
    }
    return InAppWebView(
      key: ValueKey(_initialPageContent),
      initialData: InAppWebViewInitialData(data: _initialPageContent!),
      initialOptions: InAppWebViewGroupOptions(
        crossPlatform: InAppWebViewOptions(
          useShouldOverrideUrlLoading: true,
          verticalScrollBarEnabled: false,
          disableVerticalScroll: false,
          disableHorizontalScroll: false,
          supportZoom: true,
        ),
        android: AndroidInAppWebViewOptions(
          useWideViewPort: false,
          loadWithOverviewMode: true,
          useHybridComposition: true,
        ),
        ios: IOSInAppWebViewOptions(
          enableViewportScale: false,
          allowsLinkPreview: false
        ),
      ),
      onLoadStart: (controller, uri) {
        if (widget.onLoadStart != null) {
          widget.onLoadStart!(controller, uri);
        }
      },
      onWebViewCreated: _onWebViewCreated,
      onLoadStop: (controller, uri) async {
        final scrollHeight = await _webViewController.evaluateJavascript(source: 'document.body.scrollHeight');
        if ((scrollHeight != null) && mounted && (scrollHeight + 30.0 > widget.minHeight)) {
          setState(() {
            _documentHeight = (scrollHeight + 30.0);
          });
        }
        if (widget.onLoadStop != null) {
          widget.onLoadStop!(controller, uri);
        }
      },
      onScrollChanged: (controller, x, y) {
        if (y != 0) {
          controller.scrollTo(x: 0, y: 0);
        }
      },
      shouldOverrideUrlLoading: _shouldOverrideUrlLoading,
      gestureRecognizers: {
        Factory<LongPressGestureRecognizer>(() => LongPressGestureRecognizer()),
      },
    );
  }

  void _onWebViewCreated(InAppWebViewController controller) {
    _webViewController = controller;
    if (widget.onCreated != null) {
      widget.onCreated!(_webViewController);
    }
  }

  Future<NavigationActionPolicy> _shouldOverrideUrlLoading(
      InAppWebViewController controller,
      NavigationAction request
  ) async {
    final requestUri = request.request.url!;
    final mailtoHandler = widget.mailtoDelegate;
    if (mailtoHandler != null && requestUri.isScheme('mailto')) {
      await mailtoHandler(requestUri);
      return NavigationActionPolicy.CANCEL;
    }
    final url = requestUri.toString();
    if (await launcher.canLaunch(url)) {
      await launcher.launch(url);
      return NavigationActionPolicy.CANCEL;
    } else {
      return NavigationActionPolicy.ALLOW;
    }
  }
}