import 'package:core/utils/logging/log_handler.dart';
import 'package:core/utils/logging/log_level.dart';
import 'package:core/utils/logging/log_record.dart';
import 'package:flutter/foundation.dart';

/// Dispatch orchestrator for the logger handler pipeline.
///
/// Holds a list of [LogHandler]s and routes each [LogRecord] to every
/// handler whose [LogHandler.canHandle] returns true.
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

  /// Returns true if at least one registered handler may accept records at [level].
  ///
  /// This is a fast pre-screen based on [LogHandler.acceptsLevel] — it avoids
  /// building a full [LogRecord] when no handler is interested in the level.
  bool hasHandlerFor(Level level) =>
      _handlers.any((h) => h.acceptsLevel(level));

  /// Dispatches [record] to all handlers that accept it.
  ///
  /// Handler exceptions are swallowed so that a broken destination cannot
  /// crash callers or prevent other handlers from receiving the record.
  /// Avoid logging inside the catch block to prevent recursive dispatch loops.
  void dispatch(LogRecord record) {
    for (final handler in _handlers) {
      try {
        if (handler.canHandle(record)) {
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
  @visibleForTesting
  int get handlerCount => _handlers.length;
}
