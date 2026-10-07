import 'dart:async';

import 'package:core/data/constants/constant.dart';
import 'package:core/presentation/views/html_viewer/html_content_viewer_widget.dart';
import 'package:core/presentation/views/html_viewer/html_viewer_document_builder.dart';
import 'package:core/utils/external_link_policy.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;
import 'package:url_launcher/url_launcher_string.dart';

class IosHtmlContentViewerWidget extends StatefulWidget {

  final String contentHtml;
  final TextDirection? direction;
  final bool useDefaultFontStyle;
  final OnMailtoDelegateAction? onMailtoDelegateAction;
  final OnPreviewEMLDelegateAction? onPreviewEMLDelegateAction;
  final OnDownloadAttachmentDelegateAction? onDownloadAttachmentDelegateAction;
  final OnBlockedLinkAction? onBlockedLinkAction;

  const IosHtmlContentViewerWidget({
    Key? key,
    required this.contentHtml,
    this.direction,
    this.useDefaultFontStyle = true,
    this.onMailtoDelegateAction,
    this.onPreviewEMLDelegateAction,
    this.onDownloadAttachmentDelegateAction,
    this.onBlockedLinkAction,
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
    await controller.loadData(data: HtmlViewerDocumentBuilder.buildIosDocument(
      content: widget.contentHtml,
      direction: widget.direction,
      useDefaultFontStyle: widget.useDefaultFontStyle,
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

    await _launchExternalUrl(requestUri);

    return NavigationActionPolicy.CANCEL;
  }

  Future<void> _launchExternalUrl(Uri requestUri) async {
    if (!ExternalLinkPolicy.canLaunchFromContent(requestUri)) {
      widget.onBlockedLinkAction?.call(requestUri);
      return;
    }
    if (!await launcher.canLaunchUrl(requestUri)) {
      widget.onBlockedLinkAction?.call(requestUri);
      return;
    }

    await launcher.launchUrl(
      requestUri,
      mode: LaunchMode.externalApplication
    );
  }
}