import 'package:core/presentation/utils/html_transformer/html_transform.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

class _HtmlGenerationArguments {
  final String message;
  final bool blockExternalImages;

  const _HtmlGenerationArguments(
    this.message,
    this.blockExternalImages,
  );
}

class _HtmlGenerationResult {
  final String? html;
  final String? errorDetails;

  const _HtmlGenerationResult.success(this.html) : errorDetails = null;

  const _HtmlGenerationResult.error(this.errorDetails) : this.html = null;
}

class HtmlContentViewer extends StatefulWidget {

  final String message;
  final bool blockExternalImages;

  /// Is notified about any errors that might occur
  final void Function(Object? exception, StackTrace? stackTrace)? onError;

  /// Register this callback if you want a reference to the [InAppWebViewController].
  final void Function(InAppWebViewController controller)? onWebViewCreated;

  final void Function(InAppWebViewController controller, Uri? uri)? onWebViewLoadStart;

  final void Function(InAppWebViewController controller, Uri? uri)? onWebViewLoadStop;

  /// Handler for mailto: links
  final Future Function(Uri mailto)? mailtoDelegate;

  const HtmlContentViewer({
    Key? key,
    required this.message,
    this.blockExternalImages = false,
    this.onError,
    this.onWebViewCreated,
    this.onWebViewLoadStart,
    this.onWebViewLoadStop,
    this.mailtoDelegate,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HtmlContentViewState();
}

class _HtmlContentViewState extends State<HtmlContentViewer> {

  String? _htmlData;
  bool? _wereExternalImagesBlocked;
  bool _isGenerating = false;
  double? _webViewContentHeight = 1.0;

  @override
  void initState() {
    _generateHtml(widget.blockExternalImages);
    super.initState();
  }

  void _generateHtml(bool blockExternalImages) async {
    _wereExternalImagesBlocked = blockExternalImages;
    _isGenerating = true;
    final args = _HtmlGenerationArguments(
      widget.message,
      blockExternalImages,
    );
    final result = await compute(_generateHtmlImpl, args);
    _htmlData = result.html;
    if (_htmlData == null) {
      final onError = widget.onError;
      if (onError != null) {
        onError(result.errorDetails, null);
      }
    }
    if (mounted) {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  static _HtmlGenerationResult _generateHtmlImpl(_HtmlGenerationArguments args) {
    try {
      final htmlTransform = HtmlTransform(args.message);
      final html = htmlTransform.transformToHtml(
        blockExternalImages: args.blockExternalImages,
      );
      return _HtmlGenerationResult.success(html);
    } catch (e, s) {
      String errorDetails = e.toString() + '\n\n' + s.toString();
      return _HtmlGenerationResult.error(errorDetails);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isGenerating) {
      return SizedBox.shrink();
    }
    if (widget.blockExternalImages != _wereExternalImagesBlocked) {
      _generateHtml(widget.blockExternalImages);
    }

    final size = MediaQuery.of(context).size;
    return SizedBox(
      height: _webViewContentHeight,
      width: size.width,
      child: Padding(
        padding: EdgeInsets.only(top: 16),
        child: _buildWebView(),
      ),
    );
  }

  Widget _buildWebView() {
    if (_htmlData == null) {
      return Container();
    }

    return InAppWebView(
      key: ValueKey(_htmlData),
      initialData: InAppWebViewInitialData(data: _htmlData!),
      initialOptions: InAppWebViewGroupOptions(
        crossPlatform: InAppWebViewOptions(
          useShouldOverrideUrlLoading: true,
          verticalScrollBarEnabled: false,
          disableVerticalScroll: true,
          transparentBackground: true,
        ),
        android: AndroidInAppWebViewOptions(
          useHybridComposition: true,
        ),
        ios: IOSInAppWebViewOptions(
          allowsInlineMediaPlayback: true,
          enableViewportScale: true,
          allowsLinkPreview: false
        )
      ),
      onLoadStart: (controller, uri) {
        if (widget.onWebViewLoadStart != null) {
          widget.onWebViewLoadStart!(controller, uri);
        }
      },
      onWebViewCreated: widget.onWebViewCreated,
      onLoadStop: (controller, uri) async {
        var scrollHeight = (await controller.evaluateJavascript(source: 'document.body.scrollHeight'));
        if (scrollHeight != null) {
          final scrollWidth = (await controller.evaluateJavascript(source: 'document.body.scrollWidth'));
          final size = MediaQuery.of(context).size;
          final containerWidth = size.width - 60.0;
          if (scrollWidth > containerWidth) {
            var scale = (containerWidth / scrollWidth);
            if (scale < 0.2) {
              scale = 0.2;
            }
            await controller.zoomBy(zoomFactor: scale, iosAnimated: true);
            scrollHeight = (scrollHeight * scale).ceil();
          }
          setState(() {
            _webViewContentHeight = double.tryParse('${scrollHeight + 24}');
          });
        }

        if (widget.onWebViewLoadStop != null) {
          widget.onWebViewLoadStop!(controller, uri);
        }
      },
      shouldOverrideUrlLoading: _shouldOverrideUrlLoading,
      gestureRecognizers: {
        Factory<LongPressGestureRecognizer>(() => LongPressGestureRecognizer()),
      },
    );
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