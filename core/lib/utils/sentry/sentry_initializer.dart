import 'dart:async';
import 'dart:io';

import 'package:core/utils/app_logger.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:core/utils/sentry/sentry_config.dart';
import 'package:core/utils/sentry/sentry_manager.dart';
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
    'content-location',
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
        (options) => setUpSentryOptions(options, config),
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

  @visibleForTesting
  static void setUpSentryOptions(
    SentryFlutterOptions options,
    SentryConfig config,
  ) {
    options.dsn = config.dsn;
    options.environment = config.environment;
    options.release = config.release;
    options.dist = config.dist;
    options.tracesSampleRate = config.tracesSampleRate;
    options.profilesSampleRate = config.profilesSampleRate;
    // Session Replay bypasses beforeSend and sentry_flutter 9.8.0 has no
    // supported API to stop recording and discard its buffer when a user opts
    // out. Consent is mutable per account, so Replay must stay disabled for
    // the lifetime of this SDK instance, including when consent is unknown or
    // was granted before initialization.
    options.replay.sessionSampleRate = null;
    options.replay.onErrorSampleRate = null;
    options.enableLogs = config.enableLogs;
    options.enableFramesTracking = config.enableFramesTracking;
    options.debug = config.isDebug;
    options.attachScreenshot = config.attachScreenshot;
    options.maxRequestBodySize = MaxRequestBodySize.small;

    // Automatically enable breadcrumbs that are appropriate for the current platform
    options.enableBreadcrumbTrackingForCurrentPlatform();

    // Consent can change while this SDK instance remains alive. Native crash,
    // session, performance and client-report envelopes do not pass through the
    // Dart beforeSend callbacks, so keep those autonomous senders disabled.
    options.enableAutoSessionTracking = false;
    options.enableNativeCrashHandling = false;
    options.anrEnabled = false;
    options.enableAppHangTracking = false;
    options.enableWatchdogTerminationTracking = false;
    options.enableAutoPerformanceTracing = false;
    options.enableAutoNativeBreadcrumbs = false;
    options.sendClientReports = false;

    // Second line of defence: drop expected network exception types at the SDK
    // level, even if a call site accidentally reports them as logError.
    // Primary defence is call-site routing to logWarning (see ADR-0076).
    options.ignoredExceptionsForType.add(SocketException);

    // Assign the callback to process events before sending them to Sentry
    options.beforeSend = beforeSendHandler;
    options.beforeSendTransaction = beforeSendTransactionHandler;
    options.beforeBreadcrumb = beforeBreadcrumbHandler;
    options.beforeSendLog = beforeSendLogHandler;
    options.beforeMetricCallback = beforeMetricHandler;
  }

  /// Handler executed before sending an event to Sentry.
  ///
  /// - Sanitizes request headers to remove sensitive data.
  /// - Deminifies exception stack traces for readability.
  /// - Drops everything while the user has reporting turned off. Applied here
  ///   as well as in [SentryManager] because the SDK captures uncaught Dart
  ///   errors on its own, without going through it.
  @visibleForTesting
  static Future<SentryEvent?> beforeSendHandler(
    SentryEvent event,
    Hint? hint,
  ) async {
    if (!SentryManager.instance.isSentryReportingReady) return null;

    event.request = _sanitizeRequest(event.request);
    event.exceptions = _deminifyExceptions(event.exceptions);
    return event;
  }

  @visibleForTesting
  static SentryTransaction? beforeSendTransactionHandler(
    SentryTransaction transaction,
    Hint hint,
  ) {
    return SentryManager.instance.isSentryReportingReady ? transaction : null;
  }

  @visibleForTesting
  static Breadcrumb? beforeBreadcrumbHandler(
    Breadcrumb? breadcrumb,
    Hint hint,
  ) {
    return SentryManager.instance.isSentryReportingReady ? breadcrumb : null;
  }

  @visibleForTesting
  static SentryLog? beforeSendLogHandler(SentryLog log) {
    return SentryManager.instance.isSentryReportingReady ? log : null;
  }

  @visibleForTesting
  static bool beforeMetricHandler(
    String key, {
    Map<String, String>? tags,
  }) {
    return SentryManager.instance.isSentryReportingReady;
  }

  static List<SentryException>? _deminifyExceptions(
    List<SentryException>? exceptions,
  ) {
    if (exceptions == null) return null;

    return exceptions.map((e) {
      if (e.type?.startsWith('minified:') == true) {
        final rawValue = e.value?.trim() ?? '';
        final extractedType = RegExp(r'^([A-Za-z_][A-Za-z0-9_]*)\s*:')
                .firstMatch(rawValue)
                ?.group(1) ??
            RegExp(r"Instance of '([^']+)'").firstMatch(rawValue)?.group(1);
        if (extractedType != null &&
            extractedType.isNotEmpty &&
            extractedType != 'minified' &&
            !extractedType.startsWith('minified:')) {
          e.type = extractedType;
        }
      }
      return e;
    }).toList();
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
