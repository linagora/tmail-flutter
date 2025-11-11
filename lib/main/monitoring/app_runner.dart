import 'dart:async';

import 'package:core/utils/app_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/main/monitoring/sentry/sentry_manager.dart';

/// Runs the app inside a guarded zone with logger + Sentry enabled.
Future<void> runAppWithMonitoring(Future<void> Function() runTmail) async {
  // Handling Asynchronous Errors
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Handling Flutter UI and Build Errors
    FlutterError.onError = (details) async {
      logError('FlutterError: ${details.exception} | stack: ${details.stack}');
      await SentryManager.instance.reportError(
        details.exception,
        details.stack,
      );
      FlutterError.presentError(details);
    };

    // Handling Uncaught and Platform-Specific Errors
    PlatformDispatcher.instance.onError = (error, stack) {
      logError('PlatformDispatcher: Error: $error | stack: $stack');
      SentryManager.instance.reportError(error, stack);
      return true; // Prevent app from crashing
    };

    await SentryManager.instance.initialize(runTmail);
  }, (error, stack) async {
    logError('Uncaught zone error: $error\n$stack');
    await SentryManager.instance.reportError(error, stack);
  });
}
