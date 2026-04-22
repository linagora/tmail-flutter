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
  });

  void captureMessage(
    String message, {
    Map<String, dynamic>? extras,
  });

  void addBreadcrumb(
    String message, {
    Map<String, dynamic>? extras,
  });
}
