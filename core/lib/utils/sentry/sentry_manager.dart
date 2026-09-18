import 'dart:async';

import 'package:core/utils/app_logger.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:core/utils/sentry/sentry_reporter.dart';
import 'package:core/utils/sentry/sentry_config.dart';
import 'package:core/utils/sentry/sentry_initializer.dart';
import 'package:core/utils/sentry/sentry_reporting_consent.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

typedef SentryScopeSynchronizer = Future<void> Function(
  SentryUser? user, {
  required bool clearBreadcrumbs,
});

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
        _synchronizeScope = _synchronizeSentryScope,
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
        _synchronizeScope = synchronizeScope,
        _captureException = captureException ?? _captureSentryException,
        _captureMessage = captureMessage ?? _captureSentryMessage,
        _addBreadcrumb = addBreadcrumb ?? _addSentryBreadcrumb,
        _initializeSentrySdk = initializeSentrySdk ?? SentryInitializer.init,
        _closeSentrySdk = closeSentrySdk ?? _closeDefaultSentrySdk;

  static final SentryManager instance = SentryManager._();

  bool _isSentryAvailable;
  final SentryScopeSynchronizer _synchronizeScope;
  final SentryExceptionCapturer _captureException;
  final SentryMessageCapturer _captureMessage;
  final SentryBreadcrumbAdder _addBreadcrumb;
  final SentrySdkInitializer _initializeSentrySdk;
  final SentrySdkCloser _closeSentrySdk;

  // Defaults to true so platforms that never publish a default — web, where
  // Sentry is driven by build-time env vars — keep reporting as before.
  bool _isSentryReportingAllowedByDefault = true;
  bool? _userSentryReportingConsent;
  SentryUser? _sentryUser;
  Future<void> _pendingScopeSync = Future.value();
  int _scopeSyncGeneration = 0;
  int _synchronizedScopeGeneration = 0;
  SentryConfig? _sentryConfig;
  Future<void> _pendingLifecycleTransition = Future.value();

  @override
  bool get isSentryAvailable => _isSentryAvailable;

  @override
  bool get isSentryReportingAllowed =>
      _userSentryReportingConsent ?? _isSentryReportingAllowedByDefault;

  @override
  void setSentryReportingDefault(bool allowed) {
    _isSentryReportingAllowedByDefault = allowed;
    _onReportingPermissionChanged();
  }

  @override
  void setSentryReportingConsent(bool? consent) {
    _userSentryReportingConsent = consent;
    _onReportingPermissionChanged();
  }

  bool get isSentryReportingReady =>
      isSentryReportingAllowed &&
      _scopeSyncGeneration == _synchronizedScopeGeneration;

  /// The single gate every outgoing Sentry report passes through.
  bool get _canSendToSentry => _isSentryAvailable && isSentryReportingReady;

  /// The identity the scope should carry: the one that was set, but only while
  /// reporting is allowed. Independent of [isSentryAvailable], which
  /// [_syncUserScope] checks separately before touching the SDK.
  @visibleForTesting
  SentryUser? get userForScope =>
      isSentryReportingAllowed ? _sentryUser : null;

  @visibleForTesting
  Future<void> get pendingScopeSync => _pendingScopeSync;

  @visibleForTesting
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
      _isSentryReportingAllowedByDefault = sentryConfig.isReportingAllowed;

      if (!isSentryReportingAllowed) {
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
    _isSentryReportingAllowedByDefault = sentryConfig.isReportingAllowed;
    _scheduleLifecycleTransition();
    await _pendingLifecycleTransition;
  }

  void _onReportingPermissionChanged() {
    _syncUserScope();
    _scheduleLifecycleTransition();
  }

  void _scheduleLifecycleTransition() {
    if (_sentryConfig == null) return;
    _pendingLifecycleTransition = _pendingLifecycleTransition.then(
      (_) => _applyDesiredLifecycle(),
    );
  }

  Future<void> _applyDesiredLifecycle() async {
    if (!isSentryReportingAllowed) {
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

      if (!isSentryReportingAllowed) {
        await _stopSentry();
        return;
      }

      _syncUserScope();
      await _pendingScopeSync;
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
    _sentryUser = user;
    _syncUserScope();
  }

  /// Clears the user context.
  void clearUser() {
    _sentryUser = null;
    _syncUserScope();
  }

  /// Keeps the scope's user in step with the identity and the consent.
  ///
  /// The identity is remembered rather than dropped when reporting is off, so
  /// opting in later still tells support who hit the bug; it is kept out of the
  /// scope meanwhile so it cannot ride along with what the SDK sends on its own.
  void _syncUserScope() {
    if (!_isSentryAvailable) return;

    final scopeSyncGeneration = ++_scopeSyncGeneration;
    final user = userForScope;
    final clearBreadcrumbs = !isSentryReportingAllowed;
    _pendingScopeSync = _pendingScopeSync.then((_) async {
      final isSynchronized = await _syncUserScopeInternal(
        user,
        clearBreadcrumbs: clearBreadcrumbs,
      );
      if (isSynchronized) {
        _synchronizedScopeGeneration = scopeSyncGeneration;
      }
    });
  }

  Future<bool> _syncUserScopeInternal(
    SentryUser? user, {
    required bool clearBreadcrumbs,
  }) async {
    try {
      await _synchronizeScope(
        user,
        clearBreadcrumbs: clearBreadcrumbs,
      );
      log('[SentryManager] User scope ${user == null ? 'cleared' : 'set'}');
      return true;
    } catch (e) {
      logWarning('[SentryManager] Sync user scope failed. Exception: $e');
      return false;
    }
  }
}
