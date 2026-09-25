import 'dart:async';

import 'package:core/utils/app_logger.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:core/utils/sentry/sentry_reporter.dart';
import 'package:core/utils/sentry/sentry_config.dart';
import 'package:core/utils/sentry/sentry_initializer.dart';
import 'package:core/utils/sentry/sentry_reporting_consent.dart';
import 'package:core/utils/sentry/sentry_reporting_policy.dart';
import 'package:core/utils/sentry/sentry_user_scope_coordinator.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

export 'package:core/utils/sentry/sentry_user_scope_coordinator.dart'
    show SentryScopeSynchronizer;

typedef SentryExceptionCapturer = Future<void> Function(
  dynamic exception,
  StackTrace? stackTrace,
  String? message,
  Map<String, dynamic>? extras,
  SentryLevel level,
);

typedef SentryMessageCapturer = Future<void> Function(
  String message,
  SentryLevel level,
  Map<String, dynamic>? extras,
);

typedef SentryBreadcrumbAdder = Future<void> Function(
  String message, {
  Map<String, dynamic>? extras,
  SentryLevel level,
  String? category,
});

typedef SentrySdkInitializer = Future<bool> Function({
  FutureOr<void> Function()? appRunner,
  SentryConfig? sentryConfig,
});

typedef SentrySdkCloser = Future<void> Function();

Future<void> _closeDefaultSentrySdk() => Sentry.close();

Future<void> _synchronizeSentryScope(
  SentryUser? user, {
  required bool clearBreadcrumbs,
}) async {
  await Sentry.configureScope((scope) async {
    if (clearBreadcrumbs) await scope.clearBreadcrumbs();
    await scope.setUser(user);
  });
}

Future<void> _captureSentryException(
  dynamic exception,
  StackTrace? stackTrace,
  String? message,
  Map<String, dynamic>? extras,
  SentryLevel level,
) async {
  await Sentry.captureException(
    exception,
    stackTrace: stackTrace,
    withScope: (scope) {
      scope.level = level;
      if (extras != null && extras.isNotEmpty) scope.setContexts('extras', extras);
      if (message != null && message.isNotEmpty) scope.setTag('message', message);
    },
  );
}

Future<void> _captureSentryMessage(
  String message,
  SentryLevel level,
  Map<String, dynamic>? extras,
) async {
  if (extras != null && extras.isNotEmpty) {
    await Sentry.captureMessage(
      message,
      level: level,
      withScope: (scope) => scope.setContexts('extras', extras),
    );
  } else {
    await Sentry.captureMessage(message, level: level);
  }
}

Future<void> _addSentryBreadcrumb(
  String message, {
  Map<String, dynamic>? extras,
  SentryLevel level = SentryLevel.debug,
  String? category,
}) async {
  await Sentry.addBreadcrumb(
    Breadcrumb(
      message: message,
      data: extras,
      level: level,
      category: category,
    ),
  );
}

/// Controls Sentry initialization and error reporting.
class SentryManager implements SentryReporter, SentryReportingConsent {
  SentryManager._()
      : _isSentryAvailable = false,
        _userScopeCoordinator = SentryUserScopeCoordinator(
          synchronizeScope: _synchronizeSentryScope,
        ),
        _captureException = _captureSentryException,
        _captureMessage = _captureSentryMessage,
        _addBreadcrumb = _addSentryBreadcrumb,
        _initializeSentrySdk = SentryInitializer.init,
        _closeSentrySdk = _closeDefaultSentrySdk;

  @visibleForTesting
  SentryManager.forTesting({
    required SentryScopeSynchronizer synchronizeScope,
    SentryExceptionCapturer? captureException,
    SentryMessageCapturer? captureMessage,
    SentryBreadcrumbAdder? addBreadcrumb,
    SentrySdkInitializer? initializeSentrySdk,
    SentrySdkCloser? closeSentrySdk,
    bool isSentryAvailable = true,
  })  : _isSentryAvailable = isSentryAvailable,
        _userScopeCoordinator = SentryUserScopeCoordinator(
          synchronizeScope: synchronizeScope,
        ),
        _captureException = captureException ?? _captureSentryException,
        _captureMessage = captureMessage ?? _captureSentryMessage,
        _addBreadcrumb = addBreadcrumb ?? _addSentryBreadcrumb,
        _initializeSentrySdk = initializeSentrySdk ?? SentryInitializer.init,
        _closeSentrySdk = closeSentrySdk ?? _closeDefaultSentrySdk;

  static final SentryManager instance = SentryManager._();

  bool _isSentryAvailable;
  final SentryUserScopeCoordinator _userScopeCoordinator;
  final SentryExceptionCapturer _captureException;
  final SentryMessageCapturer _captureMessage;
  final SentryBreadcrumbAdder _addBreadcrumb;
  final SentrySdkInitializer _initializeSentrySdk;
  final SentrySdkCloser _closeSentrySdk;

  final SentryReportingPolicy _reportingPolicy = SentryReportingPolicy();
  SentryConfig? _sentryConfig;
  Future<void> _pendingLifecycleTransition = Future.value();

  @override
  bool get isSentryConfigured =>
      _sentryConfig != null && !_reportingPolicy.isSuspended;

  @override
  bool get isSentryAvailable => _isSentryAvailable;

  @override
  bool get isSentryReportingAllowed => _reportingPolicy.isAllowed;

  bool get _shouldRunSentry => _reportingPolicy.shouldRun;

  @override
  void setSentryReportingDefault(bool allowed) {
    _reportingPolicy.setDefaultOverride(allowed);
    _onReportingPermissionChanged();
  }

  /// Removes the ecosystem override and restores the runtime config default.
  void clearSentryReportingDefault() {
    _reportingPolicy.clearDefaultOverride();
    _onReportingPermissionChanged();
  }

  /// Stops reporting while ecosystem ownership is being resolved.
  void suspendSentryReporting() {
    if (!_reportingPolicy.suspend()) return;
    _onReportingPermissionChanged();
  }

  /// Applies the current consent and default after ecosystem resolution.
  void resumeSentryReporting() {
    if (!_reportingPolicy.resume()) return;
    _onReportingPermissionChanged();
  }

  @override
  void setSentryReportingConsent(bool? consent) {
    _reportingPolicy.setUserConsent(consent);
    _onReportingPermissionChanged();
  }

  bool get isSentryReportingReady =>
      _shouldRunSentry &&
      _userScopeCoordinator.isSynchronized;

  /// The single gate every outgoing Sentry report passes through.
  bool get _canSendToSentry => _isSentryAvailable && isSentryReportingReady;

  /// The identity the scope should carry: the one that was set, but only while
  /// reporting is allowed.
  @visibleForTesting
  SentryUser? get userForScope =>
      _userScopeCoordinator.userForScope(shouldReport: _shouldRunSentry);

  @visibleForTesting
  Future<void> get pendingScopeSync =>
      _userScopeCoordinator.pendingSynchronization;

  /// Completes after all requested SDK start/close transitions are applied.
  Future<void> get pendingLifecycleTransition => _pendingLifecycleTransition;

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
      final sentryConfig = await SentryConfig.load();
      if (sentryConfig == null) {
        await fallBackRunner();
        return;
      }
      _sentryConfig = sentryConfig;
      _reportingPolicy.setConfigurationDefault(
        sentryConfig.isReportingAllowed,
      );

      if (!_shouldRunSentry) {
        await fallBackRunner();
        return;
      }

      _isSentryAvailable = await _initializeSentrySdk(
        appRunner: appRunner,
        sentryConfig: sentryConfig,
      );

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
    _sentryConfig = sentryConfig;
    _reportingPolicy.setConfigurationDefault(
      sentryConfig.isReportingAllowed,
    );
    _scheduleLifecycleTransition();
    await _pendingLifecycleTransition;
  }

  void _onReportingPermissionChanged() {
    _synchronizeUserScope();
    _scheduleLifecycleTransition();
  }

  void _scheduleLifecycleTransition() {
    if (_sentryConfig == null) return;
    _pendingLifecycleTransition = _pendingLifecycleTransition.then(
      (_) => _applyDesiredLifecycle(),
    );
  }

  Future<void> _applyDesiredLifecycle() async {
    if (!_shouldRunSentry) {
      await _stopSentry();
      return;
    }
    await _startSentry();
  }

  Future<void> _startSentry() async {
    if (_isSentryAvailable || _sentryConfig == null) return;

    try {
      final started = await _initializeSentrySdk(
        sentryConfig: _sentryConfig!.withReportingAllowed(true),
      );
      _isSentryAvailable = started;
      if (!started) return;

      if (!_shouldRunSentry) {
        await _stopSentry();
        return;
      }

      _synchronizeUserScope();
      await _userScopeCoordinator.pendingSynchronization;
      log('[SentryManager] Sentry active.');
    } catch (e) {
      _isSentryAvailable = false;
      logWarning('[SentryManager] Init exception: $e');
    }
  }

  Future<void> _stopSentry() async {
    if (!_isSentryAvailable) return;

    _isSentryAvailable = false;
    try {
      await _closeSentrySdk();
      log('[SentryManager] Sentry inactive.');
    } catch (e) {
      logWarning('[SentryManager] Close exception: $e');
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
    if (!_canSendToSentry) return;

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
      await _captureException(exception, stackTrace, message, extras, level);
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
    if (!_canSendToSentry) return;

    unawaited(_captureMessageInternal(message, level, extras));
  }

  Future<void> _captureMessageInternal(
    String message,
    SentryLevel level,
    Map<String, dynamic>? extras,
  ) async {
    try {
      await _captureMessage(message, level, extras);
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
    if (!_canSendToSentry) return;

    unawaited(_addBreadcrumbInternal(message, extras: extras, level: level, category: category));
  }

  Future<void> _addBreadcrumbInternal(
    String message, {
    Map<String, dynamic>? extras,
    SentryLevel level = SentryLevel.debug,
    String? category,
  }) async {
    try {
      await _addBreadcrumb(
        message,
        extras: extras,
        level: level,
        category: category,
      );
    } catch (e) {
      // NOTE: Must not route through a log level that the breadcrumb/event
      // handlers subscribe to, otherwise a throwing Sentry SDK could recurse.
      logWarning('[SentryManager] Add breadcrumb failed: $e');
    }
  }

  /// Sets the user context.
  void setUser(SentryUser user) {
    _userScopeCoordinator.setUser(user);
    _synchronizeUserScope();
  }

  /// Clears the user context.
  void clearUser() {
    _userScopeCoordinator.clearUser();
    _synchronizeUserScope();
  }

  /// Clears account-owned Sentry state while preserving the instance default.
  Future<void> clearSessionContext() async {
    _userScopeCoordinator.clearUser();
    _reportingPolicy.setUserConsent(null);
    _onReportingPermissionChanged();

    await Future.wait([
      _userScopeCoordinator.pendingSynchronization,
      _pendingLifecycleTransition,
    ]);
  }

  void _synchronizeUserScope() {
    _userScopeCoordinator.synchronize(
      isSentryAvailable: _isSentryAvailable,
      shouldReport: _shouldRunSentry,
    );
  }
}
