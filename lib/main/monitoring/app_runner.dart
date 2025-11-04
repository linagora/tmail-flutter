import 'dart:async';

import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/main/monitoring/sentry/sentry_manager.dart';

/// Runs the app inside a guarded zone with logger + Sentry enabled.
Future<void> runAppWithMonitoring(Future<void> Function() runTmail) async {
  // Handling Asynchronous Errors
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Handling Flutter UI and Build Errors
    FlutterError.onError = (details) {
      logError('FlutterError: ${details.exception} | stack: ${details.stack}');
      FlutterError.presentError(details);
    };

    // Handling Uncaught and Platform-Specific Errors
    PlatformDispatcher.instance.onError = (error, stack) {
      logError('PlatformDispatcher: Error: $error | stack: $stack');
      return true; // Prevent app from crashing
    };

    if (PlatformInfo.isWeb) {
      // Initialize Sentry
      await SentryManager.instance.initialize(runTmail);
    } else {
      await runTmail();
    }
  }, (error, stack) {
    logError('Uncaught zone error: $error\n$stack');
  });
}
