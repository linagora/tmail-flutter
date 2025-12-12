import 'dart:async';
import 'package:universal_html/html.dart' as html;
import 'package:core/utils/build_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';

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
  bool webConsoleEnabled = false,
}) {
  final rawMessage = _buildRawMessage(message, exception, extras, stackTrace);
  final formattedMessage = _formatMessage(level, rawMessage);

  if (webConsoleEnabled && PlatformInfo.isWeb) {
    _printWebConsole(level, formattedMessage);
  } else {
    _debugPrint(formattedMessage);
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

void _debugPrint(String formatted) {
  if (!BuildUtils.isDebugMode) return;

  // ignore: avoid_print
  print('$appLogName $formatted');
}

void _printWebConsole(Level level, String value) {
  switch (level) {
    case Level.error:
    case Level.wtf:
      html.window.console.error('$appLogName $value');
      break;
    case Level.warning:
      html.window.console.warn('$appLogName $value');
      break;
    case Level.info:
      html.window.console.info('$appLogName $value');
      break;
    case Level.debug:
    case Level.verbose:
      html.window.console.debug('$appLogName $value');
      break;
  }
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

void logWTF(
  String? message, {
  Object? exception,
  StackTrace? stackTrace,
  Map<String, dynamic>? extras,
  bool webConsoleEnabled = false,
}) {
  _internalLog(
    message,
    level: Level.wtf,
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

void logVerbose(
  String? message, {
  bool webConsoleEnabled = false,
}) {
  _internalLog(
    message,
    level: Level.verbose,
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
  wtf,
  error,
  warning,
  info,
  debug,
  verbose,
}

// Take from: https://flutter.dev/docs/testing/errors
void initLogger(VoidCallback runApp) {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    FlutterError.onError = (details) {
      FlutterError.dumpErrorToConsole(details);
      logWarning('AppLogger::initLogger::runZonedGuarded:FlutterError.onError: ${details.stack.toString()}');
    };
    runApp.call();
  }, (error, stack) {
    logWarning('AppLogger::initLogger::runZonedGuarded:onError: $error | stack: $stack');
  });
}
