import 'package:core/utils/logging/log_handler.dart';
import 'package:core/utils/logging/log_level.dart';
import 'package:core/utils/logging/log_record.dart';
import 'package:core/utils/sentry/sentry_manager.dart';

/// Stores log records as Sentry breadcrumbs (zero quota cost).
///
/// Handles [Level.trace] only. Breadcrumbs are buffered locally inside
/// Sentry and attached automatically to the next error event, providing
/// the full call trail leading up to a failure.
///
/// [SentryManager] is injected via constructor for testability.
class SentryBreadcrumbHandler implements LogHandler {
  final SentryManager _sentry;

  const SentryBreadcrumbHandler(this._sentry);

  @override
  bool handles(Level level) => level == Level.trace;

  @override
  void handle(LogRecord record) {
    _sentry.addBreadcrumb(
      record.rawMessage,
      extras: record.extras,
    );
  }
}
