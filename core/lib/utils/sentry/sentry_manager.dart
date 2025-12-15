import 'dart:async';

import 'package:core/utils/app_logger.dart';
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
      _isSentryAvailable = await SentryInitializer.init(appRunner);
      log('[SentryManager] Sentry initialized: $_isSentryAvailable');
    } catch (e, st) {
      logError('[SentryManager] Init failed', exception: e, stackTrace: st);
      await fallBackRunner();
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
    } catch (e, st) {
      logError('[SentryManager] Set user failed', exception: e, stackTrace: st);
    }
  }

  Future<void> clearUser() async {
    if (!_isSentryAvailable) return;

    try {
      await Sentry.configureScope((scope) => scope.setUser(null));
      log('[SentryManager] User cleared');
    } catch (e, st) {
      logError(
        '[SentryManager] Clear user failed',
        exception: e,
        stackTrace: st,
      );
    }
  }
}
