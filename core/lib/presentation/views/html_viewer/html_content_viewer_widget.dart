import 'package:core/core.dart';
import 'package:core/presentation/utils/html_transformer/html_transform.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

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

  const HtmlContentViewer({
    Key? key,
    required this.message,
    this.blockExternalImages = false,
    this.onError,
    this.onWebViewCreated,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HtmlContentViewState();
}

class _HtmlContentViewState extends State<HtmlContentViewer> {

  String? _htmlData;
  bool? _wereExternalImagesBlocked;
  bool _isGenerating = false;
  double? _webViewContentHeight;

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
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SizedBox(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(color: AppColor.primaryColor)),
        ),
      );
    }
    if (widget.blockExternalImages != _wereExternalImagesBlocked) {
      _generateHtml(widget.blockExternalImages);
    }

    final size = MediaQuery.of(context).size;
    return SizedBox(
      height: _webViewContentHeight ?? size.height,
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
        ),
        android: AndroidInAppWebViewOptions(
          useHybridComposition: true,
        ),
        ios: IOSInAppWebViewOptions(
          allowsInlineMediaPlayback: true,
          enableViewportScale: true,
        )
      ),
      onWebViewCreated: widget.onWebViewCreated,
      onLoadStop: (controller, uri) async {
        var scrollHeight = (await controller.evaluateJavascript(source: 'document.body.scrollHeight'));
        if (scrollHeight != null) {
          final scrollWidth = (await controller.evaluateJavascript(source: 'document.body.scrollWidth'));
          final size = MediaQuery.of(context).size;
          if (scrollWidth > size.width) {
            var scale = (size.width / scrollWidth);
            if (scale < 0.2) {
              scale = 0.2;
            }
            await controller.zoomBy(zoomFactor: scale, iosAnimated: true);
            scrollHeight = (scrollHeight * scale).ceil();
          }
          setState(() {
            _webViewContentHeight = double.tryParse('${scrollHeight + 10.0}');
          });
        }
      },
      gestureRecognizers: {
        Factory<LongPressGestureRecognizer>(() => LongPressGestureRecognizer()),
      },
    );
  }
}