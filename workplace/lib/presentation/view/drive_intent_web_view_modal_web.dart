import 'dart:convert';

import 'package:core/presentation/views/html_viewer/html_iframe_widget.dart';
import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;
import 'package:workplace/presentation/mixin/drive_intent_message_handler_mixin.dart';
import 'package:workplace/presentation/view/drive_intent_web_view_modal_shell.dart';
import 'package:workplace/presentation/widget/drive_attachment_picker_button.dart';

class DriveIntentWebViewModal extends StatefulWidget {
  final Uri url;
  final String intentId;
  // ADR-93: composer registers the window listener at composer-init time and
  // forwards messages here, so the handler is ready before the iframe loads.
  final OnRegisterExternalHandler? onRegisterExternalHandler;

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
  html.IFrameElement? _iframeElement;
  // Used only when no external handler is provided (fallback path).
  OnWebWindowListener? _ownWindowListener;

  String get _intentOrigin =>
      widget.url.scheme == 'data' ? 'null' : widget.url.origin;

  @override
  void initState() {
    super.initState();
    initMessageHandler(intentId: widget.intentId, intentOrigin: _intentOrigin);
    if (widget.onRegisterExternalHandler != null) {
      // ADR-93: composer registered window listener at composer-init; it
      // forwards raw messages here so we don't need our own window listener.
      widget.onRegisterExternalHandler!(_forwardMessage);
    } else {
      // Fallback: modal owns its own window listener (e.g. when used outside
      // the composer context).
      _ownWindowListener = (html.Event event) {
        if (event is! html.MessageEvent) return;
        final data = event.data;
        if (data is! String) return;
        _forwardMessage(data, event.origin);
      };
      html.window.addEventListener('message', _ownWindowListener!);
    }
  }

  void _forwardMessage(String raw, String? origin) =>
      onMessage(raw: raw, origin: origin);

  @override
  void onCleanup() {
    if (_ownWindowListener != null) {
      html.window.removeEventListener('message', _ownWindowListener!);
      _ownWindowListener = null;
    }
  }

  @override
  void dispose() {
    // Guard against routes popped without going through closeModal (system back,
    // parent nav, etc.) — onCleanup is idempotent so double-call is safe.
    onCleanup();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => DriveIntentWebViewModalShell(
    onClose: () => closeModal(null),
    child: HtmlIframeWidget(
      key: ValueKey(widget.intentId),
      src: widget.url.toString(),
      onIframeCreated: (iframe) {
        _iframeElement = iframe;
      },
    ),
  );

  @override
  void sendAck() {
    // data: URIs have opaque 'null' origin — postMessage requires '*' for those.
    final targetOrigin = _intentOrigin == 'null' ? '*' : _intentOrigin;
    _iframeElement?.contentWindow?.postMessage(jsonEncode({}), targetOrigin);
  }
}
