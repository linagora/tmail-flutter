import 'package:core/utils/app_logger.dart';
import 'package:workplace/domain/entity/drive_document.dart';
import 'package:workplace/domain/message/workplace_intent_message.dart';
import 'package:flutter/material.dart';

mixin DriveIntentMessageHandlerMixin<T extends StatefulWidget> on State<T> {
  late String _intentId;
  late String _intentOrigin;

  void initMessageHandler({required String intentId, required String intentOrigin}) {
    _intentId = intentId;
    _intentOrigin = intentOrigin;
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
    _dispatchMessage(msg);
  }

  bool _isValidOrigin(String? origin) => origin != null && origin == _intentOrigin;

  void _dispatchMessage(WorkplaceIntentMessage msg) {
    switch (msg) {
      case WorkplaceIntentReadyMessage():
        sendAck();
        break;
      case WorkplaceIntentDoneMessage():
        closeModal(msg.documents);
        break;
      case WorkplaceIntentErrorMessage():
      case WorkplaceIntentCancelMessage():
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
