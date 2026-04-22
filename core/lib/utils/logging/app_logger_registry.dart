import 'package:core/utils/logging/log_handler.dart';
import 'package:core/utils/logging/log_level.dart';
import 'package:core/utils/logging/log_record.dart';

/// Dispatch orchestrator for the logger handler pipeline.
///
/// Holds a list of [LogHandler]s and routes each [LogRecord] to every
/// handler whose [LogHandler.handles] returns true.
///
/// Uses a static singleton (not GetX) because the logger must be
/// available before GetX initialises.
///
/// **Idempotency:** [registerHandler] checks by [runtimeType] before adding.
/// Registering the same handler type twice is a no-op — prevents duplicate
/// output on hot restart or repeated bootstrap calls.
class AppLoggerRegistry {
  AppLoggerRegistry._();

  static final AppLoggerRegistry instance = AppLoggerRegistry._();

  final List<LogHandler> _handlers = [];

  /// Registers [handler] if no handler of the same [runtimeType] exists.
  void registerHandler(LogHandler handler) {
    final alreadyRegistered = _handlers.any(
      (h) => h.runtimeType == handler.runtimeType,
    );
    if (!alreadyRegistered) {
      _handlers.add(handler);
    }
  }

  /// Dispatches [record] to all handlers that accept its level.
  void dispatch(LogRecord record) {
    for (final handler in _handlers) {
      if (handler.handles(record.level)) {
        handler.handle(record);
      }
    }
  }

  /// Clears all registered handlers.
  ///
  /// **For test isolation only.** Must never be called in production code.
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
}) {
  final rawMessage = _buildRawMessage(message, exception, extras, stackTrace);
  return LogRecord(
    level: level,
    rawMessage: rawMessage,
    exception: exception,
    stackTrace: stackTrace,
    extras: extras,
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
