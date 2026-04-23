import 'package:core/utils/build_utils.dart';
import 'package:core/utils/logging/formatters/log_formatter.dart';
import 'package:core/utils/logging/log_handler.dart';
import 'package:core/utils/logging/log_level.dart';
import 'package:core/utils/logging/log_record.dart';
import 'package:core/utils/platform_info.dart';
import 'package:universal_html/html.dart' as html;

const _appLogName = '[TwakeMail]';

/// Writes log records to the console.
///
/// On web, delegates to the browser console API when either:
/// - the record was logged with [LogRecord.webConsoleEnabled] = true (per-call opt-in), or
/// - the app is running in debug mode.
///
/// On other platforms, uses [print] — visible only in debug mode.
///
/// The [formatter] is injected via constructor (Dependency Inversion Principle),
/// allowing platform-specific formatting without branching inside this class.
class ConsoleLogHandler extends LogHandler {
  final LogFormatter formatter;

  const ConsoleLogHandler({required this.formatter});

  @override
  bool handles(Level level) {
    // Always accept on web — final filtering happens in handle() because
    // per-record webConsoleEnabled may override the debug-mode gate.
    if (PlatformInfo.isWeb) return true;
    return BuildUtils.isDebugMode;
  }

  @override
  void handle(LogRecord record) {
    final formatted = formatter.format(record.level, record.rawMessage);

    if (PlatformInfo.isWeb) {
      if (record.webConsoleEnabled || BuildUtils.isDebugMode) {
        _printToWebConsole(record.level, formatted);
      }
    } else {
      // ignore: avoid_print
      print('$_appLogName $formatted');
    }
  }

  void _printToWebConsole(Level level, String value) {
    switch (level) {
      case Level.error:
      case Level.critical:
        html.window.console.error('$_appLogName $value');
        break;
      case Level.warning:
        html.window.console.warn('$_appLogName $value');
        break;
      case Level.info:
        html.window.console.info('$_appLogName $value');
        break;
      case Level.debug:
      case Level.trace:
        html.window.console.debug('$_appLogName $value');
        break;
    }
  }
}
