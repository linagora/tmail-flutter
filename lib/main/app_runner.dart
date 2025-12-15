import 'dart:async';

import 'package:core/utils/app_logger.dart';
import 'package:core/utils/sentry/sentry_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:tmail_ui_user/main.dart';
import 'package:tmail_ui_user/main/main_entry.dart';

Future<void> runAppWithMonitoring(Future<void> Function() runTmail) async {
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

    await SentryManager.instance.initialize(
      appRunner: () async {
        await runTmailPreload();
        runApp(SentryWidget(child: const TMailApp()));
      },
      fallBackRunner: runTmail,
    );
  }, (error, stack) async {
    logError(
      'Uncaught zone error: $error',
      exception: error,
      stackTrace: stack,
    );
  });
}
