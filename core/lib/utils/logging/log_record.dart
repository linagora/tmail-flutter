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

  /// Creates a [LogRecord] from raw log call parameters.
  ///
  /// Assembles [rawMessage] by joining [message], [exception], [extras], and
  /// [stackTrace] with ' | ' separators, omitting null/empty parts.
  factory LogRecord.build({
    required Level level,
    String? message,
    Object? exception,
    StackTrace? stackTrace,
    Map<String, dynamic>? extras,
    bool webConsoleEnabled = false,
  }) {
    return LogRecord(
      level: level,
      rawMessage: _buildRawMessage(message, exception, extras, stackTrace),
      exception: exception,
      stackTrace: stackTrace,
      extras: extras,
      webConsoleEnabled: webConsoleEnabled,
    );
  }

  static String _buildRawMessage(
    String? message,
    Object? exception,
    Map<String, dynamic>? extras,
    StackTrace? stackTrace,
  ) {
    // Fast path: most log calls carry only a message — avoid list allocation.
    if (exception == null && extras == null && stackTrace == null) {
      return message ?? '';
    }
    final parts = <String>[];
    if (message?.isNotEmpty == true) parts.add(message!);
    if (exception != null) parts.add('exception: $exception');
    if (extras != null && extras.isNotEmpty) parts.add('extras: $extras');
    if (stackTrace != null) parts.add('stackTrace: $stackTrace');
    return parts.join(' | ');
  }
}
