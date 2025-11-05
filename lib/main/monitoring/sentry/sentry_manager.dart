import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:tmail_ui_user/main/monitoring/sentry/sentry_context_data.dart';
import 'package:tmail_ui_user/main/monitoring/sentry/sentry_initializer.dart';
import 'package:tmail_ui_user/main/monitoring/sentry/sentry_reporter.dart';

/// For managing Sentry integration globally.
class SentryManager {
  SentryManager._();

  static final SentryManager instance = SentryManager._();

  /// Initializes Sentry SDK via SentryInitializer.
  Future<void> initialize(Future<void> Function() appRunner) async {
    try {
      await SentryInitializer.init(appRunner);
    } catch (_) {
      await appRunner();
    }
  }

  /// Forwards to SentryReporter to capture an exception.
  Future<void> reportError(
    dynamic exception, [
    StackTrace? stackTrace,
    SentryContextData? context,
  ]) async {
    if (PlatformInfo.isWeb) {
      await SentryReporter.reportError(exception, stackTrace, context);
    }
  }

  /// Forwards to SentryReporter to log a message.
  Future<void> logMessage(
    String message,
    List<dynamic> args, {
    SentryLogLevel level = SentryLogLevel.info,
  }) async {
    if (PlatformInfo.isWeb) {
      await SentryReporter.logSentry(message, args, level: level);
    }
  }

  /// Sets the current user context once after login.
  Future<void> setUser(SentryUser sentryUser) async {
    try {
      await Sentry.configureScope((scope) {
        scope.setUser(sentryUser);
      });
      log('[SentryManager] User set: ${sentryUser.email}');
    } catch (_) {}
  }

  /// Clears user context on logout.
  Future<void> clearUser() async {
    try {
      await Sentry.configureScope((scope) {
        scope.setUser(null);
      });
      log('[SentryManager] Cleared user context');
    } catch (_) {}
  }
}
