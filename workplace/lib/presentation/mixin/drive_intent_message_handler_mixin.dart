import 'package:core/utils/app_logger.dart';
import 'package:workplace/domain/entity/drive_document.dart';
import 'package:workplace/domain/message/workplace_intent_message.dart';
import 'package:flutter/material.dart';

mixin DriveIntentMessageHandlerMixin<T extends StatefulWidget> on State<T> {
  late String _intentId;
  late String _intentOrigin;
  bool _modalClosed = false;

  void initMessageHandler({required String intentId, required String intentOrigin}) {
    _intentId = intentId;
    _intentOrigin = intentOrigin;
    _modalClosed = false;
  }

  void onMessage({required String raw, required String? origin}) {
    if (!_isValidOrigin(origin)) {
      log('driveIntent: dropped message from unexpected origin: $origin');
      return;
    }
    final WorkplaceIntentMessage msg;
    try {
      msg = WorkplaceIntentMessage.parse(_intentId, raw);
    } catch (_) {
      log('driveIntent: failed to parse message: $raw');
      return;
    }
    _handleWorkplaceMessage(msg);
  }

  bool _isValidOrigin(String? origin) {
    if (origin == null) return false;
    if (origin == _intentOrigin) return true;
    // On mobile the JS shim forwards targetOrigin as the origin arg. Data URIs
    // have opaque 'null' origin but the shim receives '*' from postMessage.
    return _intentOrigin == 'null' && origin == '*';
  }

  void _handleWorkplaceMessage(WorkplaceIntentMessage msg) {
    switch (msg) {
      case WorkplaceIntentReadyMessage():
        log('driveIntent: ready received, sending ack');
        sendAck();
        break;
      case WorkplaceIntentDoneMessage():
        if (_modalClosed) break;
        _modalClosed = true;
        log('driveIntent: done received, docs: ${msg.documents.map((d) => '{id:${d.id}, name:${d.name}, size:${d.size}, mimeType:${d.mimeType}').join(', ')}');
        closeModal(msg.documents);
        break;
      case WorkplaceIntentErrorMessage():
        if (_modalClosed) break;
        _modalClosed = true;
        log('driveIntent: error received, closing modal');
        closeModal(null);
        break;
      case WorkplaceIntentCancelMessage():
        if (_modalClosed) break;
        _modalClosed = true;
        log('driveIntent: cancel received, closing modal');
        closeModal(null);
        break;
      case WorkplaceIntentUnknownMessage():
        log('driveIntent: unknown message type ${msg.type}, discarded');
        break;
    }
  }

  void closeModal(List<DriveDocument>? result) {
    onCleanup();
    if (mounted) Navigator.of(context).pop(result);
  }

  void sendAck();

  void onCleanup() {}
}
