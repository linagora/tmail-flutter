import 'dart:collection';
import 'dart:convert';

import '../mixin/drive_intent_message_handler_mixin.dart';
import '../mixin/drive_intent_shims.dart';
import '../model/drive_intent_image_assets.dart';
import 'drive_intent_fake_page.dart';
import 'drive_intent_skeleton_loader.dart';
import 'drive_intent_web_view_modal_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:workplace/data/model/workplace_intent_request.dart';
import 'package:workplace/domain/entity/workplace_intent.dart';

class DriveIntentWebViewModal extends StatefulWidget {
  final Future<WorkplaceIntent> intentFuture;
  final WorkplaceFilePickerConfigRequest filePickerConfig;
  final DriveIntentImageAssets imageAssets;
  // Ignored on mobile — only used by the web variant (ADR-93).
  final OnRegisterExternalHandler? onRegisterExternalHandler;

  const DriveIntentWebViewModal({
    super.key,
    required this.intentFuture,
    required this.filePickerConfig,
    required this.imageAssets,
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
    startLoading(widget.intentFuture);
  }

  @override
  void loadIntent(WorkplaceIntent intent) {
    if (intent.intentUrl.scheme == 'data') {
      _webViewController!.loadData(
        data: DriveIntentFakePage.buildHtml(intent.intentId),
      );
    } else {
      _webViewController!.loadUrl(
        urlRequest: URLRequest(url: WebUri.uri(intent.intentUrl)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      left: false,
      right: false,
      bottom: false,
      child: DriveIntentWebViewModalShell(
        insetPadding: EdgeInsets.zero,
        constraints: const BoxConstraints.expand(),
        shape: const RoundedRectangleBorder(),
        closeIconPath: widget.imageAssets.closeIcon,
        onClose: cancel,
        onBarrierTap: () {
          if (!showSkeleton) cancel();
        },
        loadingWidget: showSkeleton
            ? (closeButton) => DriveIntentSkeletonLoader.list(
                imageAssets: widget.imageAssets,
                closeButton: closeButton,
              )
            : null,
        child: InAppWebView(
          key: const ValueKey('drive-intent-webview'),
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
            notifyPlatformViewReady();
          },
        ),
      ),
    );
  }

  @override
  void sendAck() {
    // Embedded unquoted: JSON object syntax is valid JS object-literal syntax,
    // so `event.data` in the page ends up a real object, not a JSON string —
    // Drive's getFilePickerConfig never calls JSON.parse on it.
    final payload = jsonEncode(widget.filePickerConfig.toJson());
    _webViewController?.evaluateJavascript(source: '''
      window.dispatchEvent(new MessageEvent('message', {
        data: $payload,
        origin: '$intentOrigin',
        source: window
      }));
    ''');
  }
}
