import 'package:core/utils/logging/log_level.dart';

/// Immutable data class representing a single log event.
class LogRecord {
  final Level level;
  final String rawMessage;
  final Object? exception;
  final StackTrace? stackTrace;
  final Map<String, dynamic>? extras;

  const LogRecord({
    required this.level,
    required this.rawMessage,
    this.exception,
    this.stackTrace,
    this.extras,
  });
}
