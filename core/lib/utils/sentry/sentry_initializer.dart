import 'dart:async';
import 'dart:io';

import 'package:core/utils/app_logger.dart';
import 'package:core/utils/sentry/sentry_config.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class SentryInitializer {
  static const _blockedHeaderPatterns = [
    'authorization',
    'cookie',
    'set-cookie',
    'x-auth',
    'x-token',
    'api-key',
    'x-api-key',
    'apikey',
    'secret',
    'bearer',
    'session',
    'password',
    'token',
  ];

  /// Initializes Sentry.
  /// Returns [true] if Sentry started successfully and handled the app execution.
  /// Returns [false] if Sentry is disabled or failed to start.
  static Future<bool> init({
    FutureOr<void> Function()? appRunner,
    SentryConfig? sentryConfig,
  }) async {
    try {
      final config = sentryConfig ?? await SentryConfig.load();

      // Return false if config is missing or Sentry is disabled via Env.
      if (config == null || !config.isAvailable) {
        return false;
      }

      await SentryFlutter.init(
        (options) => _setUpSentryOptions(options, config),
        // Sentry will execute this runner if initialization succeeds.
        appRunner: appRunner,
      );

      return true;
    } catch (e) {
      // In case of any error during init, return false so main() can fallback.
      logWarning('[SentryInitializer] Init failed: $e');
      return false;
    }
  }

  static FutureOr<void> _setUpSentryOptions(
    SentryFlutterOptions options,
    SentryConfig config,
  ) async {
    options.dsn = config.dsn;
    options.environment = config.environment;
    options.release = config.release;
    options.dist = config.dist;
    options.tracesSampleRate = config.tracesSampleRate;
    options.profilesSampleRate = config.profilesSampleRate;
    options.replay.sessionSampleRate = config.sessionSampleRate;
    options.replay.onErrorSampleRate = config.onErrorSampleRate;
    options.enableLogs = config.enableLogs;
    options.enableFramesTracking = config.enableFramesTracking;
    options.debug = config.isDebug;
    options.attachScreenshot = config.attachScreenshot;
    options.maxRequestBodySize = MaxRequestBodySize.small;

    // Automatically enable breadcrumbs that are appropriate for the current platform
    options.enableBreadcrumbTrackingForCurrentPlatform();

    // Second line of defence: drop expected network exception types at the SDK
    // level, even if a call site accidentally reports them as logError.
    // Primary defence is call-site routing to logWarning (see ADR-0076).
    options.ignoredExceptionsForType.add(SocketException);

    // Assign the callback to process events before sending them to Sentry
    options.beforeSend = _beforeSendHandler;
  }

  /// Handler executed before sending an event to Sentry.
  /// Sanitizes request headers to remove sensitive data.
  static Future<SentryEvent?> _beforeSendHandler(
    SentryEvent event,
    Hint? hint,
  ) async {
    event.request = _sanitizeRequest(event.request);
    return event;
  }

  static SentryRequest? _sanitizeRequest(SentryRequest? req) {
    if (req == null) return null;

    return SentryRequest(
      url: req.url,
      method: req.method,
      headers: _sanitizeHeaders(req.headers),
      queryString: req.queryString,
      cookies: null,
      data: null,
    );
  }

  static Map<String, String> _sanitizeHeaders(Map<String, String> headers) {
    return Map<String, String>.from(headers)
      ..removeWhere(
        (key, _) => _blockedHeaderPatterns.any(
          (pattern) => key.toLowerCase().contains(pattern),
        ),
      );
  }

}
