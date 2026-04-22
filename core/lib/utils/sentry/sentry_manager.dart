import 'dart:async';

import 'package:core/utils/app_logger.dart';
import 'package:core/utils/sentry/sentry_reporter.dart';
import 'package:core/utils/sentry/sentry_config.dart';
import 'package:core/utils/sentry/sentry_initializer.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Controls Sentry initialization and error reporting.
class SentryManager implements SentryReporter {
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
  @override
  void captureException(
    dynamic exception, {
    StackTrace? stackTrace,
    String? message,
    Map<String, dynamic>? extras,
    SentryLevel level = SentryLevel.error,
  }) {
    if (!_isSentryAvailable) return;

    // Use unawaited to prevent linter warnings about unawaited futures.
    // We do not want the UI to pause while Sentry writes the crash report.
    unawaited(
      _captureExceptionInternal(exception, stackTrace, message, extras, level),
    );
  }

  Future<void> _captureExceptionInternal(
    dynamic exception,
    StackTrace? stackTrace,
    String? message,
    Map<String, dynamic>? extras,
    SentryLevel level,
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
            scope.level = level;
          },
        );
      } else {
        await Sentry.captureException(
          exception,
          stackTrace: stackTrace,
          withScope: (scope) => scope.level = level,
        );
      }
    } catch (e) {
      logWarning('[SentryManager] Capture exception failed: $e');
    }
  }

  /// Capture a text message.
  @override
  void captureMessage(
    String message, {
    Map<String, dynamic>? extras,
    SentryLevel level = SentryLevel.info,
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

  /// Adds a breadcrumb to Sentry's local buffer.
  ///
  /// Breadcrumbs are attached automatically to the next error event —
  /// they consume zero quota on their own.
  @override
  void addBreadcrumb(
    String message, {
    Map<String, dynamic>? extras,
    SentryLevel level = SentryLevel.debug,
    String? category,
  }) {
    if (!_isSentryAvailable) return;

    try {
      Sentry.addBreadcrumb(
        Breadcrumb(
          message: message,
          data: extras,
          level: level,
          category: category,
        ),
      );
    } catch (e) {
      // NOTE: Must not route through a log level that the breadcrumb/event
      // handlers subscribe to, otherwise a throwing Sentry SDK could recurse.
      logWarning('[SentryManager] Add breadcrumb failed: $e');
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
