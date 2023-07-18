import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

final logHistory = _Dispatcher("");

void log(String? value) {
  if (kDebugMode) {
    String v = value ?? "";
    logHistory.value = "$v\n${logHistory.value}";
    print(v);
  }
}

void logError(String? value) => log("[ERROR] ${value ?? ""}");

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