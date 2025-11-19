import 'dart:async';

import 'package:core/utils/app_logger.dart';
import 'package:core/utils/sentry/sentry_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:tmail_ui_user/main.dart';
import 'package:tmail_ui_user/main/main_entry.dart';

/// Runs the app inside a guarded zone with logger + Sentry enabled.
Future<void> runAppWithMonitoring(Future<void> Function() runTmail) async {
  // Handling Asynchronous Errors
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Handling Flutter UI and Build Errors
    FlutterError.onError = (details) async {
      logWarning('FlutterError: ${details.exception} | stack: ${details.stack}');
      FlutterError.presentError(details);
    };

    // Handling Uncaught and Platform-Specific Errors
    PlatformDispatcher.instance.onError = (error, stack) {
      logWarning('PlatformDispatcher: Error: $error | stack: $stack');
      return true; // Prevent app from crashing
    };

    await SentryManager.instance.initialize(
      appRunner: () async {
        await runTmailPreload(); // Prepare before UI starts
        runApp(SentryWidget(child: const TMailApp()));
      },
      fallBackRunner: runTmail,
    );
  }, (error, stack) async {
    logWarning('Uncaught zone error: $error\n$stack');
  });
}
