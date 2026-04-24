import 'package:core/utils/logging/log_level.dart';
import 'package:core/utils/logging/log_record.dart';

/// Abstract interface for log destinations.
///
/// Each handler owns its own filter rule via [handles] and its
/// own dispatch logic via [handle]. Adding a new log destination
/// requires only a new [LogHandler] implementation — no changes
/// to existing code (Open/Closed Principle).
///
/// [handlerKey] is used by [AppLoggerRegistry] to identify a handler slot.
/// The default value is [runtimeType.toString()], which means one instance
/// per concrete class. Override [handlerKey] to allow multiple instances of
/// the same class to coexist (e.g. two [ConsoleLogHandler]s with different
/// formatters, or two Sentry handlers targeting different DSNs).
abstract class LogHandler {
  const LogHandler();

  /// Unique key used for registration deduplication.
  ///
  /// Two handlers with the same [handlerKey] occupy the same slot in the
  /// registry — re-registering replaces the existing one. Override this
  /// to register multiple instances of the same concrete class.
  String get handlerKey => runtimeType.toString();

  /// Fast level-only pre-screen used by the registry before building a [LogRecord].
  ///
  /// Return false when this handler will *never* accept records at [level],
  /// regardless of any per-record fields. The default is true (conservative:
  /// no records are skipped at this stage).
  ///
  /// This must be a superset of [handles]: if [acceptsLevel] returns false,
  /// [handles] must also return false for all records at that level.
  bool acceptsLevel(Level level) => true;

  /// Returns true if this handler should process [record].
  ///
  /// The default delegates to [acceptsLevel] — sufficient for level-pure
  /// handlers that do not need per-record fields. Override when per-record
  /// fields (e.g. [LogRecord.webConsoleEnabled]) must influence the decision.
  bool handles(LogRecord record) => acceptsLevel(record.level);

  /// Process the given [record]. Called only when [handles] returns true.
  void handle(LogRecord record);
}
