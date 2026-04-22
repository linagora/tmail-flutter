import 'package:core/utils/logging/log_level.dart';

/// Abstract interface for formatting a raw log message.
///
/// Implementations are platform-specific and injected into handlers
/// via constructor (Dependency Inversion Principle).
abstract interface class LogFormatter {
  /// Returns a formatted string for the given [level] and [raw] message.
  String format(Level level, String raw);
}
