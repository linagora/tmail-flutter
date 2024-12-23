
import 'dart:async';
import 'dart:collection';

import 'package:core/utils/app_logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/websocket/web_socket_message.dart';

typedef ProcessMessageCallback = Future<void> Function(WebSocketMessage message);
typedef OnErrorCallback = void Function(dynamic error, StackTrace stackTrace);

class WebSocketQueueHandler {
  static const int _maxQueueSize = 128;
  static const int _maxProcessedIdsSize = 128;

  final Queue<WebSocketMessage> _messageQueue = Queue<WebSocketMessage>();
  final Queue<String> _processedMessageIds = Queue<String>();

  Completer<void>? _processingLock;

  final _queueController = StreamController<WebSocketMessage>.broadcast();

  final ProcessMessageCallback processMessageCallback;
  final OnErrorCallback? onErrorCallback;

  WebSocketQueueHandler({
    required this.processMessageCallback,
    this.onErrorCallback,
  }) {
    _queueController.stream.listen((_) {
      _processQueue();
    });
  }

  void enqueue(WebSocketMessage message) {
    if (isMessageProcessed(message.id)) {
      log('WebSocketQueueHandler::enqueue:Message ${message.id} already processed, skipping');
      return;
    }

    if (queueSize >= _maxQueueSize) {
      log('WebSocketQueueHandler::enqueue:Queue full, removing oldest message');
      _messageQueue.removeFirst();
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
      while (queueSize > 0) {
        final message = _messageQueue.removeFirst();

        try {
          await processMessageCallback(message);
        } catch (e, stackTrace) {
          logError('WebSocketQueueHandler::_processQueue:Error processing message ${message.id}: $e');
          onErrorCallback?.call(e, stackTrace);
        } finally {
          _addToProcessedMessages(message.id);
        }
      }
    } finally {
      _processingLock?.complete();
      _processingLock = null;

      if (queueSize > 0) {
        scheduleMicrotask(() => _queueController.add(_messageQueue.first));
      }
    }
  }

  void _addToProcessedMessages(String messageId) {
    if (_processedMessageIds.length >= _maxProcessedIdsSize) {
      _processedMessageIds.removeFirst();
    }
    _processedMessageIds.add(messageId);
  }

  void removeMessagesUpToCurrent(String messageId) {
    final isCurrentStateExist = _messageQueue
        .any((message) => message.id == messageId);

    if (!isCurrentStateExist) {
      log('WebSocketQueueHandler::removeMessagesUpToCurrent:Current state $messageId not found in the queue.');
      return;
    }
    while (queueSize > 0) {
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
    _messageQueue.clear();
    _processedMessageIds.clear();
    _queueController.close();
    _processingLock = null;
  }
}
