import 'dart:async';

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

  static Future<bool> init(FutureOr<void> Function() appRunner) async {
    final config = await SentryConfig.load();

    if (config == null) return false;

    await SentryFlutter.init(
      (options) {
        options.dsn = config.dsn;
        options.environment = config.environment;
        options.release = config.release;
        options.dist = config.dist;
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
    event.request = _sanitizeRequest(event.request);
    event.exceptions = _deminifyExceptions(event.exceptions);

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
}
