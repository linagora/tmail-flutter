import 'package:core/utils/logging/log_handler.dart';
import 'package:core/utils/logging/log_level.dart';
import 'package:core/utils/logging/log_record.dart';
import 'package:flutter/material.dart';

/// Dispatch orchestrator for the logger handler pipeline.
///
/// Holds a list of [LogHandler]s and routes each [LogRecord] to every
/// handler whose [LogHandler.handles] returns true.
///
/// Uses a static singleton (not GetX) because the logger must be
/// available before GetX initialises.
///
/// **Idempotency:** [registerHandler] deduplicates by [LogHandler.handlerKey].
/// By default the key is [runtimeType.toString()], so registering the same
/// concrete class twice replaces the first instance. Override [handlerKey]
/// on a handler to allow multiple instances of the same class to coexist.
class AppLoggerRegistry {
  AppLoggerRegistry._();

  static final AppLoggerRegistry instance = AppLoggerRegistry._();

  final List<LogHandler> _handlers = [];

  /// Registers [handler], replacing any existing handler with the same [LogHandler.handlerKey].
  ///
  /// This ensures that re-registering with a new configuration (e.g. a different
  /// [LogFormatter]) takes effect rather than silently keeping the stale instance.
  /// To allow multiple instances of the same concrete class, override [LogHandler.handlerKey]
  /// with a distinct value per instance.
  void registerHandler(LogHandler handler) {
    final existingIndex = _handlers.indexWhere(
      (h) => h.handlerKey == handler.handlerKey,
    );

    if (existingIndex == -1) {
      _handlers.add(handler);
    } else {
      _handlers[existingIndex] = handler;
    }
  }

  /// Dispatches [record] to all handlers that accept its level.
  ///
  /// Handler exceptions are swallowed so that a broken destination cannot
  /// crash callers or prevent other handlers from receiving the record.
  /// Avoid logging inside the catch block to prevent recursive dispatch loops.
  void dispatch(LogRecord record) {
    for (final handler in _handlers) {
      try {
        if (handler.handles(record.level)) {
          handler.handle(record);
        }
      } catch (_) {
        // Logging must not break the application flow.
        // Avoid logging here to prevent recursive dispatch loops.
      }
    }
  }

  /// Clears all registered handlers.
  ///
  /// **For test isolation only.** Must never be called in production code.
  @visibleForTesting
  void resetForTesting() {
    _handlers.clear();
  }

  /// Returns the number of currently registered handlers.
  ///
  /// Exposed for testing purposes only.
  int get handlerCount => _handlers.length;
}

/// Builds a [LogRecord] from the given log call parameters.
LogRecord buildLogRecord({
  required Level level,
  String? message,
  Object? exception,
  StackTrace? stackTrace,
  Map<String, dynamic>? extras,
  bool webConsoleEnabled = false,
}) {
  final rawMessage = _buildRawMessage(message, exception, extras, stackTrace);
  return LogRecord(
    level: level,
    rawMessage: rawMessage,
    exception: exception,
    stackTrace: stackTrace,
    extras: extras,
    webConsoleEnabled: webConsoleEnabled,
  );
}

String _buildRawMessage(
  String? message,
  Object? exception,
  Map<String, dynamic>? extras,
  StackTrace? stackTrace,
) {
  final parts = <String>[];
  if (message?.isNotEmpty == true) parts.add(message!);
  if (exception != null) parts.add('exception: $exception');
  if (extras != null && extras.isNotEmpty) parts.add('extras: $extras');
  if (stackTrace != null) parts.add('stackTrace: $stackTrace');
  return parts.join(' | ');
}
