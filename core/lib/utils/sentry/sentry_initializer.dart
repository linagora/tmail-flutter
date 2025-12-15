import 'dart:async';

import 'package:core/utils/sentry/sentry_config.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class SentryInitializer {
  static Future<bool> init(FutureOr<void> Function() appRunner) async {
    final config = await SentryConfig.load();

    await SentryFlutter.init(
      (options) {
        options.dsn = config.dsn;
        options.environment = config.environment;
        options.release = config.release;
        options.tracesSampleRate = config.tracesSampleRate;
        options.profilesSampleRate = config.profilesSampleRate;
        options.enableLogs = config.enableLogs;
        options.debug = config.isDebug;
        options.attachScreenshot = config.attachScreenshot;
        options.maxRequestBodySize = MaxRequestBodySize.small;

        // Automatically enable breadcrumbs that are appropriate for the current platform
        options.enableBreadcrumbTrackingForCurrentPlatform();

        // Assign the callback to process events before sending them to Sentry
        options.beforeSend = _beforeSendHandler;
      },
      appRunner: appRunner,
    );

    return config.isAvailable;
  }

  /// Handler executed before sending an event to Sentry
  static Future<SentryEvent?> _beforeSendHandler(
    SentryEvent event,
    Hint? hint,
  ) async {
    // Ignore AssertionError events
    if (event.throwable is AssertionError) {
      return null;
    }
    return event;
  }
}
