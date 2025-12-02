import 'dart:async';
import 'package:core/utils/build_utils.dart';
import 'package:universal_html/html.dart' as html;
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';

void log(String value, {Level level = Level.info, bool webConsole = false}) {
  final isWeb = PlatformInfo.isWeb;

  if (webConsole && isWeb) {
    switch (level) {
      case Level.error:
      case Level.wtf:
        html.window.console.error('[TwakeMail] $value');
        break;
      case Level.warning:
        html.window.console.warn('[TwakeMail] $value');
        break;
      case Level.info:
        html.window.console.info('[TwakeMail] $value');
        break;
      case Level.debug:
      case Level.verbose:
        html.window.console.debug('[TwakeMail] $value');
        break;
    }
    return;
  }

  if (!BuildUtils.isDebugMode) return;

  String formatted = value;

  if (isWeb) {
    switch (level) {
      case Level.wtf:
        formatted = '\x1B[31m!!!CRITICAL!!! $formatted\x1B[0m';
        break;
      case Level.error:
        formatted = '\x1B[31m$formatted\x1B[0m';
        break;
      case Level.warning:
        formatted = '\x1B[33m$formatted\x1B[0m';
        break;
      case Level.info:
        formatted = '\x1B[32m$formatted\x1B[0m';
        break;
      case Level.debug:
        formatted = '\x1B[34m$formatted\x1B[0m';
        break;
      case Level.verbose:
        break;
    }
  } else {
    if (level == Level.error) {
      formatted = '[ERROR] $formatted';
    }
  }
  // ignore: avoid_print
  print('[TwakeMail] $formatted');
}

void logError(String value, {bool webConsole = false}) => log(
      value,
      level: Level.error,
      webConsole: webConsole,
    );

// Take from: https://flutter.dev/docs/testing/errors
void initLogger(VoidCallback runApp) {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    FlutterError.onError = (details) {
      FlutterError.dumpErrorToConsole(details);
      logError('AppLogger::initLogger::runZonedGuarded:FlutterError.onError: ${details.stack.toString()}');
    };
    runApp.call();
  }, (error, stack) {
    logError('AppLogger::initLogger::runZonedGuarded:onError: $error | stack: $stack');
  });
}


enum Level {
  wtf,
  error,
  warning,
  info,
  debug,
  verbose,
}