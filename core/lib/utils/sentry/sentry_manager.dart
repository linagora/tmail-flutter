import 'dart:async';

import 'package:core/utils/app_logger.dart';
import 'package:core/utils/sentry/sentry_config.dart';
import 'package:core/utils/sentry/sentry_initializer.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Controls Sentry initialization and error reporting.
class SentryManager {
  SentryManager._();

  static final SentryManager instance = SentryManager._();

  bool _isSentryAvailable = false;

  bool get isSentryAvailable => _isSentryAvailable;

  /// Initialize Sentry. App still runs if init fails.
  Future<void> initialize({
    required FutureOr<void> Function() appRunner,
    required FutureOr<void> Function() fallBackRunner,
  }) async {
    try {
      if (_isSentryAvailable) {
        log('[SentryManager] Already initialized, skipping');
        await appRunner();
        return;
      }
      _isSentryAvailable = await SentryInitializer.init(appRunner: appRunner);

      if (_isSentryAvailable) {
        log('[SentryManager] Sentry is active.');
      } else {
        log('[SentryManager] Sentry is not active.');
        await fallBackRunner();
      }
    } catch (e) {
      logWarning('[SentryManager] Init failed. Exception $e');
      await fallBackRunner();
    }
  }

  Future<void> initializeWithSentryConfig(SentryConfig sentryConfig) async {
    try {
      if (_isSentryAvailable) {
        log('[SentryManager] Already initialized, skipping');
        return;
      }
      _isSentryAvailable = await SentryInitializer.init(
        sentryConfig: sentryConfig,
      );
      if (_isSentryAvailable) {
        log('[SentryManager] Sentry is active.');
      } else {
        log('[SentryManager] Sentry is not active.');
      }
    } catch (e) {
      logWarning('[SentryManager] Init failed, Exception $e');
    }
  }

  /// Capture an exception. Metadata is attached as breadcrumbs.
  Future<void> captureException(
    dynamic exception, {
    StackTrace? stackTrace,
    String? message,
    Map<String, dynamic>? extras,
  }) async {
    if (!_isSentryAvailable) return;

    await Sentry.captureException(
      exception,
      stackTrace: stackTrace,
      withScope: (scope) {
        scope.addBreadcrumb(
          Breadcrumb(
            message: message ?? exception.toString(),
            data: extras,
            level: SentryLevel.error,
          ),
        );
      },
    );
  }

  /// Capture a text message. Metadata also goes into breadcrumbs.
  Future<void> captureMessage(
    String message, {
    SentryLevel level = SentryLevel.info,
    Map<String, dynamic>? extras,
  }) async {
    if (!_isSentryAvailable) return;

    await Sentry.captureMessage(
      message,
      level: level,
      withScope: (scope) {
        scope.addBreadcrumb(
          Breadcrumb(
            message: message,
            data: extras,
            level: level,
          ),
        );
      },
    );
  }

  Future<void> setUser(SentryUser user) async {
    if (!_isSentryAvailable) return;

    try {
      await Sentry.configureScope((scope) => scope.setUser(user));
      log('[SentryManager] User set: ${user.email}');
    } catch (e) {
      logWarning('[SentryManager] Set user failed. Exception: $e');
    }
  }

  Future<void> clearUser() async {
    if (!_isSentryAvailable) return;

    try {
      await Sentry.configureScope((scope) => scope.setUser(null));
      log('[SentryManager] User cleared');
    } catch (e) {
      logWarning('[SentryManager] Clear user failed. Exception: $e');
    }
  }
}
