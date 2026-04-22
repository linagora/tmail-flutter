import 'package:sentry_flutter/sentry_flutter.dart';

/// Abstraction over Sentry operations used by log handlers.
///
/// Decouples [LogHandler] implementations from [SentryManager]'s
/// concrete singleton, making handlers independently testable.
abstract interface class SentryReporter {
  void captureException(
    dynamic exception, {
    StackTrace? stackTrace,
    String? message,
    Map<String, dynamic>? extras,
    SentryLevel level,
  });

  void captureMessage(
    String message, {
    Map<String, dynamic>? extras,
    SentryLevel level,
  });

  void addBreadcrumb(
    String message, {
    Map<String, dynamic>? extras,
  });
}
