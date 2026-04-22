import 'package:core/utils/logging/formatters/log_formatter.dart';
import 'package:core/utils/logging/log_level.dart';

/// ANSI escape colors for web console output.
const _ansiReset = '\x1B[0m';
const _ansiRed = '\x1B[31m';
const _ansiYellow = '\x1B[33m';
const _ansiGreen = '\x1B[32m';
const _ansiBlue = '\x1B[34m';
const _ansiBold = '\x1B[1m';

/// Formats log messages for web console output using ANSI color codes.
class WebConsoleFormatter implements LogFormatter {
  const WebConsoleFormatter();

  @override
  String format(Level level, String raw) {
    switch (level) {
      case Level.critical:
        return '$_ansiRed$_ansiBold!!!CRITICAL!!! $raw$_ansiReset';
      case Level.error:
        return '$_ansiRed$raw$_ansiReset';
      case Level.warning:
        return '$_ansiYellow$raw$_ansiReset';
      case Level.info:
        return '$_ansiGreen$raw$_ansiReset';
      case Level.debug:
        return '$_ansiBlue$raw$_ansiReset';
      case Level.trace:
        return raw;
    }
  }
}
