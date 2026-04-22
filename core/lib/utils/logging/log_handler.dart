import 'package:core/utils/logging/log_level.dart';
import 'package:core/utils/logging/log_record.dart';

/// Abstract interface for log destinations.
///
/// Each handler owns its own filter rule via [handles] and its
/// own dispatch logic via [handle]. Adding a new log destination
/// requires only a new [LogHandler] implementation — no changes
/// to existing code (Open/Closed Principle).
abstract interface class LogHandler {
  /// Returns true if this handler should process records at [level].
  bool handles(Level level);

  /// Process the given [record].
  void handle(LogRecord record);
}
