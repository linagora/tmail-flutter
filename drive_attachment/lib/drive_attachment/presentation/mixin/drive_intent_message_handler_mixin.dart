import 'dart:async';

import 'package:core/utils/app_logger.dart';
import 'package:drive_attachment/drive_attachment/domain/entity/drive_document.dart';
import 'package:drive_attachment/drive_attachment/domain/message/drive_intent_message.dart';
import 'package:flutter/material.dart';

mixin DriveIntentMessageHandlerMixin<T extends StatefulWidget> on State<T> {
  static const Duration _readyTimeout = Duration(seconds: 30);

  late String _intentId;
  late String _intentOrigin;
  Timer? _readyTimer;

  void initMessageHandler({required String intentId, required String intentOrigin}) {
    _intentId = intentId;
    _intentOrigin = intentOrigin;
  }

  void startReadyTimeout() {
    _readyTimer = Timer(_readyTimeout, () {
      log('driveIntent: ready timeout after ${_readyTimeout.inSeconds}s');
      closeModal(null);
    });
  }

  void onWebViewLoaded() => startReadyTimeout();

  void onMessage({required String raw, required String? origin}) {
    if (origin == null || origin != _intentOrigin) {
      log('driveIntent: dropped message from unexpected origin: $origin');
      return;
    }
    final DriveIntentMessage msg;
    try {
      msg = DriveIntentMessage.parse(_intentId, raw);
    } catch (_) {
      throw DriveIntentParseException(raw);
    }
    switch (msg) {
      case DriveIntentReadyMessage():
        _cancelTimeout();
        sendAck();
      case DriveIntentDoneMessage():
        closeModal(msg.documents);
      case DriveIntentErrorMessage():
        closeModal(null);
      case DriveIntentCancelMessage():
        closeModal(null);
      case DriveIntentUnknownMessage():
        log('driveIntent: unknown message type ${msg.type}, discarded');
    }
  }

  void _cancelTimeout() {
    _readyTimer?.cancel();
    _readyTimer = null;
  }

  void closeModal(List<DriveDocument>? result) {
    _cancelTimeout();
    onCleanup();
    if (mounted) Navigator.of(context).pop(result);
  }

  void sendAck();

  void onCleanup() {}
}
