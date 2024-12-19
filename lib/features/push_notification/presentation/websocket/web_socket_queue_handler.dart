
import 'dart:async';
import 'dart:collection';

import 'package:core/utils/app_logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/websocket/web_socket_message.dart';

typedef ProcessMessageCallback = Future<void> Function(WebSocketMessage message);
typedef OnErrorCallback = void Function(dynamic error, StackTrace stackTrace);

class WebSocketQueueHandler {
  final Queue<WebSocketMessage> _messageQueue = Queue<WebSocketMessage>();
  final Set<String> _processedMessageIds = {};

  Completer<void>? _processingLock;

  final _queueController = StreamController<WebSocketMessage>.broadcast();

  final ProcessMessageCallback processMessageCallback;
  final OnErrorCallback? onErrorCallback;

  WebSocketQueueHandler({
    required this.processMessageCallback,
    this.onErrorCallback,
  }) {
    _queueController.stream.listen((message) {
      _processQueue();
    });
  }

  void enqueue(WebSocketMessage message) {
    if (isMessageProcessed(message.id)) {
      log('WebSocketQueueHandler::enqueue:Message ${message.id} already processed, skipping');
      return;
    }

    _messageQueue.add(message);
    _queueController.add(message);
  }

  Future<void> _processQueue() async {
    if (_processingLock != null) {
      return;
    }

    _processingLock = Completer<void>();

    try {
      while (_messageQueue.isNotEmpty) {
        final message = _messageQueue.first;

        try {
          await processMessageCallback(message);
          _processedMessageIds.add(message.id);
          _messageQueue.removeFirst();
        } catch (e, stackTrace) {
          logError('WebSocketQueueHandler::_processQueue:Error processing message ${message.id}: $e');
          onErrorCallback?.call(e, stackTrace);
          break;
        }
      }
    } finally {
      _processingLock?.complete();
      _processingLock = null;

      if (_messageQueue.isNotEmpty) {
        scheduleMicrotask(() => _queueController.add(_messageQueue.first));
      }
    }
  }

  void removeMessagesUpToCurrent(String messageId) {
    final isCurrentStateExist = _messageQueue
        .any((message) => message.id == messageId);

    if (!isCurrentStateExist) {
      log('WebSocketQueueHandler::removeMessagesUpToCurrent:Current state $messageId not found in the queue.');
      return;
    }
    while (_messageQueue.isNotEmpty) {
      final removedMessage = _messageQueue.removeFirst();
      if (removedMessage.id == messageId) {
        break;
      }
    }
    log('WebSocketQueueHandler::removeMessagesUpToCurrent:Updated Queue: $queueSize');
  }

  @visibleForTesting
  Future<void> waitForEmpty() async {
    while (_messageQueue.isNotEmpty || _processingLock != null) {
      if (_processingLock != null) {
        await _processingLock!.future;
      }
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  int get queueSize => _messageQueue.length;

  bool isMessageProcessed(String messageId) => _processedMessageIds.contains(messageId);

  void dispose() {
    _queueController.close();
  }
}
