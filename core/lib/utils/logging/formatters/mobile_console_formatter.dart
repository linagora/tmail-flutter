import 'package:core/utils/logging/formatters/log_formatter.dart';
import 'package:core/utils/logging/log_level.dart';

/// Formats log messages for mobile/debug console output using emoji prefixes.
class MobileConsoleFormatter implements LogFormatter {
  const MobileConsoleFormatter();

  @override
  String format(Level level, String raw) {
    switch (level) {
      case Level.critical:
        return '🔥 CRITICAL: $raw';
      case Level.error:
        return '❌ ERROR: $raw';
      case Level.warning:
        return '⚠️ WARNING: $raw';
      case Level.info:
        return 'ℹ️ INFO: $raw';
      case Level.debug:
        return '🐛 DEBUG: $raw';
      case Level.trace:
        return '🔍 VERBOSE: $raw';
    }
  }
}
