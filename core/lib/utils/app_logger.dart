import 'dart:async';

import 'package:core/utils/build_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:core/utils/sentry/sentry_manager.dart';
import 'package:universal_html/html.dart' as html;

/// ANSI escape colors (Web only)
const ansiReset = '\x1B[0m';
const ansiRed = '\x1B[31m';
const ansiYellow = '\x1B[33m';
const ansiGreen = '\x1B[32m';
const ansiBlue = '\x1B[34m';
const ansiBold = '\x1B[1m';

const appLogName = '[TwakeMail]';

String _applyWebColor(Level level, String text) {
  switch (level) {
    case Level.critical:
      return '$ansiRed$ansiBold!!!CRITICAL!!! $text$ansiReset';
    case Level.error:
      return '$ansiRed$text$ansiReset';
    case Level.warning:
      return '$ansiYellow$text$ansiReset';
    case Level.info:
      return '$ansiGreen$text$ansiReset';
    case Level.debug:
      return '$ansiBlue$text$ansiReset';
    case Level.trace:
      return text;
  }
}

String _applyMobileFormat(Level level, String text) {
  switch (level) {
    case Level.critical:
      return '🔥 CRITICAL: $text';
    case Level.error:
      return '❌ ERROR: $text';
    case Level.warning:
      return '⚠️ WARNING: $text';
    case Level.info:
      return 'ℹ️ INFO: $text';
    case Level.debug:
      return '🐛 DEBUG: $text';
    case Level.trace:
      return '🔍 VERBOSE: $text';
  }
}

void _internalLog(
  String? message, {
  required Level level,
  Object? exception,
  StackTrace? stackTrace,
  Map<String, dynamic>? extras,
  bool webConsoleEnabled = false,
}) {
  final shouldPrint = webConsoleEnabled
      ? PlatformInfo.isWeb
      : BuildUtils.isDebugMode;

  final shouldSentry = _shouldReportToSentry(level);

  if (!shouldPrint && !shouldSentry) {
    return;
  }

  final rawMessage = _buildRawMessage(message, exception, extras, stackTrace);

  if (shouldPrint) {
    final formattedMessage = _formatMessage(level, rawMessage);

    if (webConsoleEnabled && PlatformInfo.isWeb) {
      _printWebConsole(level, formattedMessage);
    } else {
      // ignore: avoid_print
      print('$appLogName $formattedMessage');
    }
  }

  if (shouldSentry) {
    unawaited(
      SentryManager.instance.captureException(
        exception ?? rawMessage,
        stackTrace: stackTrace,
        message: rawMessage,
        extras: extras,
      ),
    );
  }
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

String _formatMessage(Level level, String raw) {
  return PlatformInfo.isWeb
      ? _applyWebColor(level, raw)
      : _applyMobileFormat(level, raw);
}

void _printWebConsole(Level level, String value) {
  switch (level) {
    case Level.error:
    case Level.critical:
      html.window.console.error('$appLogName $value');
      break;
    case Level.warning:
      html.window.console.warn('$appLogName $value');
      break;
    case Level.info:
      html.window.console.info('$appLogName $value');
      break;
    case Level.debug:
    case Level.trace:
      html.window.console.debug('$appLogName $value');
      break;
  }
}

bool _shouldReportToSentry(Level level) {
  return level == Level.error || level == Level.critical;
}

void logError(
  String? message, {
  Object? exception,
  StackTrace? stackTrace,
  Map<String, dynamic>? extras,
  bool webConsoleEnabled = false,
}) {
  _internalLog(
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
  _internalLog(
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
  _internalLog(message,
      level: Level.warning, webConsoleEnabled: webConsoleEnabled);
}

void logInfo(
  String? message, {
  bool webConsoleEnabled = false,
}) {
  _internalLog(
    message,
    level: Level.info,
    webConsoleEnabled: webConsoleEnabled,
  );
}

void logDebug(
  String? message, {
  bool webConsoleEnabled = false,
}) {
  _internalLog(
    message,
    level: Level.debug,
    webConsoleEnabled: webConsoleEnabled,
  );
}

void logTrace(
  String? message, {
  bool webConsoleEnabled = false,
}) {
  _internalLog(
    message,
    level: Level.trace,
    webConsoleEnabled: webConsoleEnabled,
  );
}

void log(
  String? message, {
  bool webConsoleEnabled = false,
}) =>
    logInfo(
      message,
      webConsoleEnabled: webConsoleEnabled,
    );

enum Level {
  critical,
  error,
  warning,
  info,
  debug,
  trace,
}