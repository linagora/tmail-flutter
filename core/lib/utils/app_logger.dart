import 'dart:async';

import 'package:core/utils/platform_info.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

final logHistory = _Dispatcher('');

void log(String? value, {Level level = Level.info}) {
  // if (!kDebugMode) return;

  String logsStr = value ?? '';
  logHistory.value = '$logsStr\n${logHistory.value}';

  if (PlatformInfo.isWeb) {
    switch (level) {
      case Level.wtf:
        logsStr = '\x1B[31m!!!CRITICAL!!! $logsStr\x1B[0m';
        break;
      case Level.error:
        logsStr = '\x1B[31m$logsStr\x1B[0m';
        break;
      case Level.warning:
        logsStr = '\x1B[33m$logsStr\x1B[0m';
        break;
      case Level.info:
        logsStr = '\x1B[32m$logsStr\x1B[0m';
        break;
      case Level.debug:
        logsStr = '\x1B[34m$logsStr\x1B[0m';
        break;
      case Level.verbose:
        break;
    }
  } else {
    switch (level) {
      case Level.error:
        logsStr = '[ERROR] $logsStr';
        break;
      default:
        break;
    }
  }
  // ignore: avoid_print
  print('[TwakeMail] $logsStr');
}

void logError(String? value) => log(value, level: Level.error);

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

class _Dispatcher extends ValueNotifier<String> {
  _Dispatcher(String value) : super(value);
}


enum Level {
  wtf,
  error,
  warning,
  info,
  debug,
  verbose,
}