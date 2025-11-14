import 'package:core/utils/app_logger.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:tmail_ui_user/main/monitoring/sentry/sentry_context_data.dart';

/// A helper class to safely report errors and messages to Sentry.
/// Handles exceptions, informational messages, and breadcrumbs.
class SentryReporter {
  /// Reports an exception with optional context and tags.
  static Future<void> reportError(
    dynamic exception, [
    StackTrace? stackTrace,
    SentryContextData? context,
  ]) async {
    try {
      await Sentry.configureScope((scope) {
        if (context != null) {
          scope.setContexts('Reported Exception', context.toMap());
        }
      });

      await Sentry.captureException(exception, stackTrace: stackTrace);
      logError('[SentryReporter] Reported exception: $exception');
    } catch (err, st) {
      logError('[SentryReporter] Failed to report: $err, $st');
    }
  }

  /// Reports a simple message to Sentry (info, warning, debug, etc.).
  static Future<void> reportMessage(
    String message, {
    SentryLevel level = SentryLevel.info,
    SentryContextData? context,
  }) async {
    try {
      await Sentry.configureScope((scope) {
        if (context != null) {
          scope.setContexts('Reported Message', context.toMap());
        }
      });

      await Sentry.captureMessage(message, level: level);
      log('[SentryReporter] Reported message: $message (level: $level)');
    } catch (err, st) {
      logError('[SentryReporter] Failed to report message: $err, $st');
    }
  }

  /// Adds a breadcrumb for contextual tracking (navigation, user actions, etc.)
  static Future<void> addBreadcrumb(
    String message, {
    String? category,
    SentryLevel level = SentryLevel.info,
    SentryContextData? context,
  }) async {
    try {
      final breadcrumb = Breadcrumb(
        message: message,
        category: category,
        level: level,
        data: context?.toMap(),
      );

      Sentry.addBreadcrumb(breadcrumb);
      log('[SentryReporter] Added breadcrumb: $message');
    } catch (err, st) {
      logError('[SentryReporter] Failed to add breadcrumb: $err, $st');
    }
  }

  /// Send log information to Sentry
  static Future<void> logSentry(
    String message,
    List<dynamic> args, {
    SentryLogLevel level = SentryLogLevel.info,
  }) async {
    try {
      switch (level) {
        case SentryLogLevel.info:
          Sentry.logger.fmt.info(message, args);
        case SentryLogLevel.trace:
          Sentry.logger.fmt.trace(message, args);
        case SentryLogLevel.debug:
          Sentry.logger.fmt.debug(message, args);
        case SentryLogLevel.warn:
          Sentry.logger.fmt.warn(message, args);
        case SentryLogLevel.error:
          Sentry.logger.fmt.error(message, args);
        case SentryLogLevel.fatal:
          Sentry.logger.fmt.fatal(message, args);
      }
    } catch (err, st) {
      logError('[SentryReporter] Log to Sentry failed: $err, $st');
    }
  }
}
