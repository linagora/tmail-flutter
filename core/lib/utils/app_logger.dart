import 'package:core/utils/build_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:core/utils/sentry/sentry_manager.dart';

/// ANSI escape colors (Web only)
const ansiReset = '\x1B[0m';
const ansiRed = '\x1B[31m';
const ansiYellow = '\x1B[33m';
const ansiGreen = '\x1B[32m';
const ansiBlue = '\x1B[34m';
const ansiBold = '\x1B[1m';

String _applyWebColor(Level level, String text) {
  switch (level) {
    case Level.wtf:
      return '$ansiRed$ansiBold!!!CRITICAL!!! $text$ansiReset';
    case Level.error:
      return '$ansiRed$text$ansiReset';
    case Level.warning:
      return '$ansiYellow$text$ansiReset';
    case Level.info:
      return '$ansiGreen$text$ansiReset';
    case Level.debug:
      return '$ansiBlue$text$ansiReset';
    case Level.verbose:
      return text;
  }
}

String _applyMobileFormat(Level level, String text) {
  switch (level) {
    case Level.wtf:
      return '🔥 CRITICAL: $text';
    case Level.error:
      return '❌ ERROR: $text';
    case Level.warning:
      return '⚠️ WARNING: $text';
    case Level.info:
      return 'ℹ️ INFO: $text';
    case Level.debug:
      return '🐛 DEBUG: $text';
    case Level.verbose:
      return '🔍 VERBOSE: $text';
  }
}

void _internalLog(
  String? message, {
  required Level level,
  Object? exception,
  StackTrace? stackTrace,
  Map<String, dynamic>? extras,
}) {
  if (!BuildUtils.isDebugMode) return;

  final raw = message ?? '';
  final formatted = PlatformInfo.isWeb
      ? _applyWebColor(level, raw)
      : _applyMobileFormat(level, raw);

  // ignore: avoid_print
  print('[TwakeMail] $formatted');

  if (level == Level.error || level == Level.wtf) {
    SentryManager.instance.captureException(
      exception ?? raw,
      stackTrace: stackTrace,
      message: raw,
      extras: extras,
    );
  }
}

void logError(
  String? message, {
  Object? exception,
  StackTrace? stackTrace,
  Map<String, dynamic>? extras,
}) {
  _internalLog(
    message,
    level: Level.error,
    exception: exception,
    stackTrace: stackTrace,
    extras: extras,
  );
}

void logWTF(
  String? message, {
  Object? exception,
  StackTrace? stackTrace,
  Map<String, dynamic>? extras,
}) {
  _internalLog(
    message,
    level: Level.wtf,
    exception: exception,
    stackTrace: stackTrace,
    extras: extras,
  );
}

void logWarning(String? message) {
  _internalLog(message, level: Level.warning);
}

void logInfo(String? message) {
  _internalLog(message, level: Level.info);
}

void logDebug(String? message) {
  _internalLog(message, level: Level.debug);
}

void logVerbose(String? message) {
  _internalLog(message, level: Level.verbose);
}

void log(String? message) => logInfo(message);

enum Level {
  wtf,
  error,
  warning,
  info,
  debug,
  verbose,
}
