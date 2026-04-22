import 'package:core/utils/logging/log_level.dart';

/// Immutable data class representing a single log event.
///
/// [webConsoleEnabled] allows individual log calls to force output to the
/// browser console regardless of build mode — useful for diagnostics that
/// must be visible in release/profile builds on web.
class LogRecord {
  final Level level;
  final String rawMessage;
  final Object? exception;
  final StackTrace? stackTrace;
  final Map<String, dynamic>? extras;
  final bool webConsoleEnabled;

  const LogRecord({
    required this.level,
    required this.rawMessage,
    this.exception,
    this.stackTrace,
    this.extras,
    this.webConsoleEnabled = false,
  });
}
