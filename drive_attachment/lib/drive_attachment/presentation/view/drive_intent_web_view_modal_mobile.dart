import 'dart:collection';
import 'dart:convert';

import 'package:drive_attachment/drive_attachment/presentation/mixin/drive_intent_message_handler_mixin.dart';
import 'package:drive_attachment/drive_attachment/presentation/mixin/drive_intent_shims.dart';
import 'package:drive_attachment/drive_attachment/presentation/view/drive_intent_web_view_modal_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class DriveIntentWebViewModal extends StatefulWidget {
  final Uri url;
  final String intentId;
  // Ignored on mobile — only used by the web variant (ADR-93).
  final void Function(void Function(String raw, String? origin))? onRegisterExternalHandler;

  const DriveIntentWebViewModal({
    super.key,
    required this.url,
    required this.intentId,
    this.onRegisterExternalHandler,
  });

  @override
  State<DriveIntentWebViewModal> createState() =>
      _DriveIntentWebViewModalState();
}

class _DriveIntentWebViewModalState extends State<DriveIntentWebViewModal>
    with DriveIntentMessageHandlerMixin {
  InAppWebViewController? _webViewController;

  @override
  void initState() {
    super.initState();
    initMessageHandler(
      intentId: widget.intentId,
      intentOrigin: widget.url.origin,
    );
  }

  @override
  Widget build(BuildContext context) => DriveIntentWebViewModalShell(
        onClose: () => closeModal(null),
        child: InAppWebView(
          key: ValueKey(widget.intentId),
          initialUrlRequest: URLRequest(url: WebUri.uri(widget.url)),
          initialSettings: InAppWebViewSettings(),
          initialUserScripts: UnmodifiableListView([
            UserScript(
              source: DriveIntentShims.parentPostMessageShim,
              injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
            ),
          ]),
          onWebViewCreated: (controller) {
            _webViewController = controller;
            controller.addJavaScriptHandler(
              handlerName: DriveIntentShims.handlerName,
              callback: (args) => onMessage(
                raw: args[0] as String,
                origin: args.length > 1 ? args[1] as String? : null,
              ),
            );
          },
          onLoadStop: (_, __) => onWebViewLoaded(),
        ),
      );

  @override
  void sendAck() {
    final payload = jsonEncode({});
    _webViewController?.evaluateJavascript(source: '''
      window.dispatchEvent(new MessageEvent('message', {
        data: '$payload',
        origin: '${widget.url.origin}',
        source: window
      }));
    ''');
  }
}
