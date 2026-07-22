
import 'dart:async';
import 'dart:collection';

import 'package:core/utils/app_logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/websocket/web_socket_message.dart';

typedef ProcessMessageCallback = Future<void> Function(WebSocketMessage message);
typedef OnErrorCallback = void Function(dynamic error, StackTrace stackTrace);
/// Returns true when the failed message will be enqueued again.
typedef RetryMessageCallback = bool Function(
  WebSocketMessage message,
  dynamic error,
  StackTrace stackTrace,
);

class WebSocketQueueHandler {
  static const int _maxQueueSize = 128;
  static const int _maxProcessedIdsSize = 128;

  final Queue<WebSocketMessage> _messageQueue = Queue<WebSocketMessage>();
  final Queue<String> _processedMessageIds = Queue<String>();

  Completer<void>? _processingLock;

  final _queueController = StreamController<WebSocketMessage>.broadcast();
  late final StreamSubscription<WebSocketMessage> _queueSubscription;

  final ProcessMessageCallback processMessageCallback;
  final OnErrorCallback? onErrorCallback;
  final RetryMessageCallback? retryMessageCallback;
  bool _disposed = false;

  WebSocketQueueHandler({
    required this.processMessageCallback,
    this.onErrorCallback,
    this.retryMessageCallback,
  }) {
    _queueSubscription = _queueController.stream.listen((_) {
      _processQueue();
    });
  }

  void enqueue(WebSocketMessage message) {
    if (_disposed) return;
    if (isMessageProcessed(message.id)) {
      log('WebSocketQueueHandler::enqueue:Message ${message.id} already processed, skipping');
      return;
    }

    try {
      if (queueSize >= _maxQueueSize) {
        log('WebSocketQueueHandler::enqueue:Queue full, removing oldest message');
        _messageQueue.removeFirst();
      }
    } catch (e) {
      logWarning('WebSocketQueueHandler::enqueue:Exception = $e');
    }

    log('WebSocketQueueHandler::enqueue(): ${message.id}');
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
        await _processNextMessage();
      }
    } finally {
      _finishProcessing();
    }
  }

  Future<void> _processNextMessage() async {
    final message = _messageQueue.removeFirst();
    log('WebSocketQueueHandler::_processQueue(): processing message ${message.id}');

    var shouldRetry = false;
    try {
      shouldRetry = await _tryProcessMessage(message);
    } finally {
      if (!shouldRetry) _addToProcessedMessages(message.id);
    }
  }

  Future<bool> _tryProcessMessage(WebSocketMessage message) async {
    try {
      await processMessageCallback(message);
      return false;
    } catch (error, stackTrace) {
      logWarning(
        'WebSocketQueueHandler::_processQueue:Error processing message ${message.id}: $error',
      );
      onErrorCallback?.call(error, stackTrace);
      return _requestRetry(message, error, stackTrace);
    }
  }

  bool _requestRetry(
    WebSocketMessage message,
    dynamic error,
    StackTrace stackTrace,
  ) {
    try {
      return retryMessageCallback?.call(message, error, stackTrace) ?? false;
    } catch (retryError, retryStackTrace) {
      logWarning(
        'WebSocketQueueHandler::_processQueue:Error scheduling retry for ${message.id}: $retryError',
      );
      onErrorCallback?.call(retryError, retryStackTrace);
      return false;
    }
  }

  void _finishProcessing() {
    _processingLock?.complete();
    _processingLock = null;
    _scheduleRemainingMessages();
  }

  void _scheduleRemainingMessages() {
    if (_disposed || queueSize == 0) return;
    scheduleMicrotask(_notifyQueue);
  }

  void _notifyQueue() {
    if (_disposed || queueSize == 0) return;
    _queueController.add(_messageQueue.first);
  }

  void _addToProcessedMessages(String messageId) {
    if (_disposed) return;
    log('WebSocketQueueHandler::_addToProcessedMessages(): adding message $messageId to processed messages');
    try {
      if (_processedMessageIds.length >= _maxProcessedIdsSize) {
        _processedMessageIds.removeFirst();
      }
    } catch (e) {
      logWarning('WebSocketQueueHandler::_addToProcessedMessages:Exception = $e');
    }

    _processedMessageIds.add(messageId);
  }

  void removeMessagesUpToCurrent(String messageId) {
    try {
      log('WebSocketQueueHandler::removeMessagesUpToCurrent(): removing messages up to $messageId');
      final isCurrentStateExist = _messageQueue
          .any((message) => message.id == messageId);

      if (!isCurrentStateExist) {
        log('WebSocketQueueHandler::removeMessagesUpToCurrent:Current state $messageId not found in the queue.');
        return;
      }

      while (queueSize > 0) {
        final removedMessage = _messageQueue.removeFirst();
        log('WebSocketQueueHandler::removeMessagesUpToCurrent(): removing message ${removedMessage.id} up to $messageId');
        if (removedMessage.id == messageId) {
          break;
        }
      }
      log('WebSocketQueueHandler::removeMessagesUpToCurrent:Updated Queue: $queueSize');
    } catch (e) {
      logWarning('WebSocketQueueHandler::removeMessagesUpToCurrent:Exception = $e');
    }
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

  /// Reports whether a message is waiting in the queue.
  bool isMessageQueued(String messageId) =>
      _messageQueue.any((message) => message.id == messageId);

  bool isMessageProcessed(String messageId) => _processedMessageIds.contains(messageId);

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _messageQueue.clear();
    _processedMessageIds.clear();
    _queueController.close();
    _queueSubscription.cancel();
  }
}
