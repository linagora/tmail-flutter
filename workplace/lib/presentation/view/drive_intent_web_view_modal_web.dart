import 'dart:convert';

import 'package:core/presentation/views/html_viewer/html_iframe_widget.dart';
import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;
import 'package:workplace/domain/entity/workplace_intent.dart';
import 'package:workplace/presentation/mixin/drive_intent_message_handler_mixin.dart';
import 'package:workplace/presentation/mixin/web_window_message_mixin.dart';
import 'package:workplace/presentation/view/drive_intent_skeleton_loader.dart';
import 'package:workplace/presentation/view/drive_intent_web_view_modal_shell.dart';

class DriveIntentWebViewModal extends StatefulWidget {
  final Future<WorkplaceIntent> intentFuture;
  // ADR-93: composer registers the window listener at composer-init time and
  // forwards messages here, so the handler is ready before the iframe loads.
  final OnRegisterExternalHandler? onRegisterExternalHandler;

  const DriveIntentWebViewModal({
    super.key,
    required this.intentFuture,
    this.onRegisterExternalHandler,
  });

  @override
  State<DriveIntentWebViewModal> createState() =>
      _DriveIntentWebViewModalState();
}

class _DriveIntentWebViewModalState extends State<DriveIntentWebViewModal>
    with DriveIntentMessageHandlerMixin, WebWindowMessageMixin<DriveIntentWebViewModal> {
  html.IFrameElement? _iframeElement;

  @override
  void initState() {
    super.initState();
    if (widget.onRegisterExternalHandler != null) {
      // ADR-93: composer registered window listener at composer-init; it
      // forwards raw messages here so we don't need our own window listener.
      widget.onRegisterExternalHandler!(_forwardMessage);
    } else {
      // Fallback: modal owns its own window listener (e.g. when used outside
      // the composer context).
      startWindowMessageListener(_forwardMessage);
    }
    startLoading(widget.intentFuture);
  }

  @override
  void loadIntent(WorkplaceIntent intent) {
    _iframeElement!.src = intent.intentUrl.toString();
  }

  void _forwardMessage(String raw, String? origin) =>
      onMessage(raw: raw, origin: origin);

  @override
  void onCleanup() {
    stopWindowMessageListener();
  }

  @override
  void dispose() {
    // Guard against routes popped without going through the mixin's finish
    // path (system back, parent nav, etc.) — onCleanup is idempotent so
    // double-call is safe.
    onCleanup();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => DriveIntentWebViewModalShell(
    insetPadding: const EdgeInsets.all(24),
    constraints: const BoxConstraints(maxWidth: 800, maxHeight: 677),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(6)),
    ),
    haveCloseButton: false,
    onClose: () {
      if (!showSkeleton) cancel();
    },
    child: Stack(
      children: [
        HtmlIframeWidget(
          key: const ValueKey('drive-intent-webview'),
          onIframeCreated: (iframe) {
            _iframeElement = iframe;
            notifyPlatformViewReady();
          },
        ),
        if (showSkeleton)
          const Positioned.fill(child: DriveIntentSkeletonLoader.table()),
      ],
    ),
  );

  @override
  void sendAck() {
    // data: URIs have opaque 'null' origin — postMessage requires '*' for those.
    final targetOrigin = intentOrigin == 'null' ? '*' : intentOrigin;
    _iframeElement?.contentWindow?.postMessage(jsonEncode({}), targetOrigin);
  }
}
