import 'dart:developer';
import 'dart:ui';

import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/html_transformer/html_template.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_windows/webview_windows.dart';

class HtmlContentViewerForWindows extends StatefulWidget {
  final String contentHtml;
  final double heightContent;

  final void Function(WebviewController controller)? onCreated;

  final Future Function(Uri mailto)? mailtoDelegate;

  /// Handler for any non-media URLs that the user taps on the website.
  ///
  /// Returns `true` when the given `url` was handled.
  final Future<bool> Function(Uri url)? urlLauncherDelegate;

  const HtmlContentViewerForWindows({
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

class _HtmlContentViewState extends State<HtmlContentViewerForWindows> {
  
  late double actualHeight;
  double minHeight = 100;
  double minWidth = 300;
  late double maxHeightForWindows;
  late WebviewController _webviewController;
  bool _isLoading = true;
  late final ValueNotifier<String> _htmlDataNotifier;

    @override
  void initState() {
    super.initState();
    actualHeight = widget.heightContent;
    maxHeightForWindows = window.physicalSize.height;
    log('_HtmlContentViewState::initState(): maxHeightForWindows: $maxHeightForWindows');
    _htmlDataNotifier = ValueNotifier(widget.contentHtml);
    _webviewController = WebviewController();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    try {
      await _webviewController.initialize();
      await _webviewController.setBackgroundColor(Colors.white);
      await  _webviewController.loadStringContent("");

      if (!mounted) return;
      setState(() {});
    } on PlatformException catch (e) {
      log(e.code);
      if(e.message != null) {
        log(e.message!);
      }
    }
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
            child: ValueListenableBuilder<String>(
              valueListenable: _htmlDataNotifier,
              builder: ((context, contentHtml, child) {
                final htmlTemplate = _generateHtmlDocument(contentHtml);
                if(!_webviewController.value.isInitialized) {
                  return _buildLoadingView();
                }
                _webviewController.loadStringContent(htmlTemplate);
                return child!;
              }),
              child: Webview(_webviewController),
            ),
            ),
          if (_isLoading) Align(alignment: Alignment.center, child: _buildLoadingView())
        ],
      );
    });
  }

  Widget _buildLoadingView() {
    return const Padding(
        padding: EdgeInsets.all(16),
        child: SizedBox(
          width: 30,
          height: 30,
          child: CupertinoActivityIndicator(color: AppColor.colorLoading)));
  }

}