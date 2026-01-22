import 'dart:async';

import 'package:core/utils/app_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

Future<void> runWithZoneAndErrorHandling(Future<void> Function() runner) async {
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Handling Flutter UI and Build Errors
    FlutterError.onError = (details) async {
      logError(
        'FlutterError: ${details.exception}',
        exception: details.exception,
        stackTrace: details.stack,
      );
      FlutterError.presentError(details);
    };

    // Handling Uncaught and Platform-Specific Errors
    PlatformDispatcher.instance.onError = (error, stack) {
      logError(
        'PlatformDispatcher: Error: $error',
        exception: error,
        stackTrace: stack,
      );
      return true;
    };

    await runner();
  }, (error, stack) {
    logError(
      'Uncaught zone error: $error',
      exception: error,
      stackTrace: stack,
    );
  });
}
