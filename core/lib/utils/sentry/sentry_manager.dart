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

  /// Initialize Sentry.
  Future<void> initialize({
    required FutureOr<void> Function() appRunner,
    required FutureOr<void> Function() fallBackRunner,
  }) async {
    if (_isSentryAvailable) {
      log('[SentryManager] Already initialized.');
      await appRunner();
      return;
    }

    try {
      _isSentryAvailable = await SentryInitializer.init(appRunner: appRunner);

      if (!_isSentryAvailable) {
        logWarning('[SentryManager] Sentry failed to init, running fallback.');
        await fallBackRunner();
      } else {
        log('[SentryManager] Sentry active.');
      }
    } catch (e) {
      logWarning('[SentryManager] Init failed. Exception $e');
      await fallBackRunner();
    }
  }

  Future<void> initializeWithSentryConfig(SentryConfig sentryConfig) async {
    if (_isSentryAvailable) return;

    try {
      _isSentryAvailable = await SentryInitializer.init(
        sentryConfig: sentryConfig,
      );
      if (_isSentryAvailable) {
        log('[SentryManager] Sentry active.');
      }
    } catch (e) {
      logWarning('[SentryManager] Init exception: $e');
    }
  }

  /// Capture an exception.
  void captureException(
    dynamic exception, {
    StackTrace? stackTrace,
    String? message,
    Map<String, dynamic>? extras,
  }) {
    if (!_isSentryAvailable) return;

    // Use unawaited to prevent linter warnings about unawaited futures.
    // We do not want the UI to pause while Sentry writes the crash report.
    unawaited(
      _captureExceptionInternal(exception, stackTrace, message, extras),
    );
  }

  Future<void> _captureExceptionInternal(
    dynamic exception,
    StackTrace? stackTrace,
    String? message,
    Map<String, dynamic>? extras,
  ) async {
    try {
      final hasExtras = extras != null && extras.isNotEmpty;
      final hasMessage = message != null && message.isNotEmpty;

      if (hasExtras || hasMessage) {
        await Sentry.captureException(
          exception,
          stackTrace: stackTrace,
          withScope: (scope) {
            if (hasExtras) scope.setContexts('extras', extras);
            if (hasMessage) scope.setTag('message', message);
          },
        );
      } else {
        await Sentry.captureException(
          exception,
          stackTrace: stackTrace,
        );
      }
    } catch (e) {
      logWarning('[SentryManager] Capture exception failed: $e');
    }
  }

  /// Capture a text message.
  void captureMessage(
    String message, {
    SentryLevel level = SentryLevel.info,
    Map<String, dynamic>? extras,
  }) {
    if (!_isSentryAvailable) return;

    unawaited(_captureMessageInternal(message, level, extras));
  }

  Future<void> _captureMessageInternal(
    String message,
    SentryLevel level,
    Map<String, dynamic>? extras,
  ) async {
    try {
      if (extras != null && extras.isNotEmpty) {
        await Sentry.captureMessage(
          message,
          level: level,
          withScope: (scope) => scope.setContexts('extras', extras),
        );
      } else {
        await Sentry.captureMessage(message, level: level);
      }
    } catch (e) {
      logWarning('[SentryManager] Capture message failed: $e');
    }
  }

  /// Sets the user context.
  void setUser(SentryUser user) {
    if (!_isSentryAvailable) return;

    try {
      Sentry.configureScope((scope) => scope.setUser(user));
      log('[SentryManager] User set: ${user.email}');
    } catch (e) {
      logWarning('[SentryManager] Set user failed. Exception: $e');
    }
  }

  /// Clears the user context.
  void clearUser() {
    if (!_isSentryAvailable) return;

    try {
      Sentry.configureScope((scope) => scope.setUser(null));
      log('[SentryManager] User cleared');
    } catch (e) {
      logWarning('[SentryManager] Clear user failed. Exception: $e');
    }
  }
}
