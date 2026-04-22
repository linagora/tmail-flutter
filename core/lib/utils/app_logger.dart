import 'package:core/utils/logging/app_logger_registry.dart';
import 'package:core/utils/logging/log_level.dart';

export 'package:core/utils/logging/log_level.dart' show Level;

/// Public logging API. All log calls delegate to [AppLoggerRegistry].
///
/// Call sites are unchanged — the public function signatures are stable
/// across all 188+ existing usages.
///
/// Note: [webConsoleEnabled] on every function is deprecated. Web console
/// output is now controlled globally by [ConsoleLogHandler] registered at
/// startup — per-call overrides are no longer supported. The parameter is
/// kept for source compatibility and will be removed in a future release.

void logError(
  String? message, {
  Object? exception,
  StackTrace? stackTrace,
  Map<String, dynamic>? extras,
  @Deprecated('Web console output is now controlled by ConsoleLogHandler at startup')
  bool webConsoleEnabled = false,
}) {
  _dispatch(
    message,
    level: Level.error,
    exception: exception,
    stackTrace: stackTrace,
    extras: extras,
  );
}

void logCritical(
  String? message, {
  Object? exception,
  StackTrace? stackTrace,
  Map<String, dynamic>? extras,
  @Deprecated('Web console output is now controlled by ConsoleLogHandler at startup')
  bool webConsoleEnabled = false,
}) {
  _dispatch(
    message,
    level: Level.critical,
    exception: exception,
    stackTrace: stackTrace,
    extras: extras,
  );
}

void logWarning(
  String? message, {
  @Deprecated('Web console output is now controlled by ConsoleLogHandler at startup')
  bool webConsoleEnabled = false,
}) {
  _dispatch(message, level: Level.warning);
}

void logInfo(
  String? message, {
  @Deprecated('Web console output is now controlled by ConsoleLogHandler at startup')
  bool webConsoleEnabled = false,
}) {
  _dispatch(message, level: Level.info);
}

void logDebug(
  String? message, {
  @Deprecated('Web console output is now controlled by ConsoleLogHandler at startup')
  bool webConsoleEnabled = false,
}) {
  _dispatch(message, level: Level.debug);
}

void logTrace(
  String? message, {
  @Deprecated('Web console output is now controlled by ConsoleLogHandler at startup')
  bool webConsoleEnabled = false,
  Map<String, dynamic>? extras,
}) {
  _dispatch(message, level: Level.trace, extras: extras);
}

void log(
  String? message, {
  @Deprecated('Web console output is now controlled by ConsoleLogHandler at startup')
  bool webConsoleEnabled = false,
}) =>
    logInfo(message);

void _dispatch(
  String? message, {
  required Level level,
  Object? exception,
  StackTrace? stackTrace,
  Map<String, dynamic>? extras,
}) {
  final record = buildLogRecord(
    level: level,
    message: message,
    exception: exception,
    stackTrace: stackTrace,
    extras: extras,
  );
  AppLoggerRegistry.instance.dispatch(record);
}
