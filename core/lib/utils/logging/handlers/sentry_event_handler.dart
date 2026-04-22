import 'package:core/utils/logging/log_handler.dart';
import 'package:core/utils/logging/log_level.dart';
import 'package:core/utils/logging/log_record.dart';
import 'package:core/utils/sentry/sentry_reporter.dart';

/// Sends log records to Sentry as events.
///
/// Handles [Level.error] and [Level.critical] only.
///
/// - If the record contains an exception object → [SentryReporter.captureException]
/// - If not → [SentryReporter.captureMessage] (semantically correct: a string
///   is not an exception)
///
/// [SentryReporter] is injected via constructor for testability.
class SentryEventHandler implements LogHandler {
  final SentryReporter _sentry;

  const SentryEventHandler(this._sentry);

  @override
  bool handles(Level level) =>
      level == Level.error || level == Level.critical;

  @override
  void handle(LogRecord record) {
    if (record.exception != null) {
      _sentry.captureException(
        record.exception,
        stackTrace: record.stackTrace,
        message: record.rawMessage,
        extras: record.extras,
      );
    } else {
      _sentry.captureMessage(
        record.rawMessage,
        extras: record.extras,
      );
    }
  }
}
