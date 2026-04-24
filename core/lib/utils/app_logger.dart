import 'package:core/utils/logging/app_logger_registry.dart';
import 'package:core/utils/logging/log_level.dart';
import 'package:core/utils/logging/log_record.dart';

export 'package:core/utils/logging/log_level.dart' show Level;

/// Public logging API. All log calls delegate to [AppLoggerRegistry].
///
/// [webConsoleEnabled] forces output to the browser console regardless of
/// build mode — useful for diagnostics that must be visible in release/profile
/// builds on web. Defaults to false (web console output follows debug mode).

void logError(
  String? message, {
  Object? exception,
  StackTrace? stackTrace,
  Map<String, dynamic>? extras,
  bool webConsoleEnabled = false,
}) {
  _dispatch(
    message,
    level: Level.error,
    exception: exception,
    stackTrace: stackTrace,
    extras: extras,
    webConsoleEnabled: webConsoleEnabled,
  );
}

void logCritical(
  String? message, {
  Object? exception,
  StackTrace? stackTrace,
  Map<String, dynamic>? extras,
  bool webConsoleEnabled = false,
}) {
  _dispatch(
    message,
    level: Level.critical,
    exception: exception,
    stackTrace: stackTrace,
    extras: extras,
    webConsoleEnabled: webConsoleEnabled,
  );
}

void logWarning(
  String? message, {
  bool webConsoleEnabled = false,
}) {
  _dispatch(message, level: Level.warning, webConsoleEnabled: webConsoleEnabled);
}

void logInfo(
  String? message, {
  bool webConsoleEnabled = false,
}) {
  _dispatch(message, level: Level.info, webConsoleEnabled: webConsoleEnabled);
}

void logDebug(
  String? message, {
  bool webConsoleEnabled = false,
}) {
  _dispatch(message, level: Level.debug, webConsoleEnabled: webConsoleEnabled);
}

void logTrace(
  String? message, {
  bool webConsoleEnabled = false,
  Map<String, dynamic>? extras,
}) {
  _dispatch(
    message,
    level: Level.trace,
    extras: extras,
    webConsoleEnabled: webConsoleEnabled,
  );
}

void log(
  String? message, {
  bool webConsoleEnabled = false,
}) =>
    logInfo(message, webConsoleEnabled: webConsoleEnabled);

void _dispatch(
  String? message, {
  required Level level,
  Object? exception,
  StackTrace? stackTrace,
  Map<String, dynamic>? extras,
  bool webConsoleEnabled = false,
}) {
  if (!AppLoggerRegistry.instance.hasHandlerFor(level)) return;
  final record = LogRecord.build(
    level: level,
    message: message,
    exception: exception,
    stackTrace: stackTrace,
    extras: extras,
    webConsoleEnabled: webConsoleEnabled,
  );
  AppLoggerRegistry.instance.dispatch(record);
}
