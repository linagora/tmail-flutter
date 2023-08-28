import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

final logHistory = _Dispatcher('');

void log(String? value, {Level level = Level.info}) {
  if (!kDebugMode) return;

  String logsStr = value ?? '';
  logHistory.value = '$logsStr\n${logHistory.value}';

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
  // ignore: avoid_print
  print('[TeamMail] $logsStr');
}

void logError(String? value) => log(value, level: Level.error);

// Take from: https://flutter.dev/docs/testing/errors
void initLogger(VoidCallback runApp) {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.dumpErrorToConsole(details);
      logError(details.stack.toString());
    };
    runApp.call();
  }, (Object error, StackTrace stack) {
    logError(stack.toString());
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