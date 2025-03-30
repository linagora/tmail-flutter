import 'dart:async';

import 'package:core/data/constants/constant.dart';
import 'package:core/presentation/views/html_viewer/html_content_viewer_widget.dart';
import 'package:core/utils/html/html_interaction.dart';
import 'package:core/utils/html/html_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;
import 'package:url_launcher/url_launcher_string.dart';

class IosHtmlContentViewerWidget extends StatefulWidget {

  final String contentHtml;
  final TextDirection? direction;
  final bool useDefaultFont;
  final OnMailtoDelegateAction? onMailtoDelegateAction;
  final OnPreviewEMLDelegateAction? onPreviewEMLDelegateAction;
  final OnDownloadAttachmentDelegateAction? onDownloadAttachmentDelegateAction;

  const IosHtmlContentViewerWidget({
    Key? key,
    required this.contentHtml,
    this.direction,
    this.useDefaultFont = false,
    this.onMailtoDelegateAction,
    this.onPreviewEMLDelegateAction,
    this.onDownloadAttachmentDelegateAction,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _IosHtmlContentViewerWidgetState();
}

class _IosHtmlContentViewerWidgetState extends State<IosHtmlContentViewerWidget> {

  @override
  Widget build(BuildContext context) {
    return InAppWebView(
      initialSettings: InAppWebViewSettings(transparentBackground: true),
      onWebViewCreated: _onWebViewCreated,
      shouldOverrideUrlLoading: _shouldOverrideUrlLoading,
      gestureRecognizers: {
        Factory<LongPressGestureRecognizer>(() => LongPressGestureRecognizer()),
      },
    );
  }

  Future<void> _onWebViewCreated(InAppWebViewController controller) async {
    await controller.loadData(data: HtmlUtils.generateHtmlDocument(
      content: widget.contentHtml,
      direction: widget.direction,
      javaScripts: HtmlInteraction.scriptsHandleLazyLoadingBackgroundImage,
      useDefaultFont: widget.useDefaultFont,
    ));
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
}