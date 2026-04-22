import 'package:core/utils/logging/log_handler.dart';
import 'package:core/utils/logging/log_level.dart';
import 'package:core/utils/logging/log_record.dart';
import 'package:core/utils/platform_info.dart';

/// Abstraction over file-based logging operations.
///
/// Decouples [FileLogHandler] from [LogTracking]'s concrete singleton,
/// making the handler independently testable.
abstract interface class FileLogger {
  bool get isEnabled;
  Future<void> addLog({required String message});
}

/// Writes log records to a local file via [FileLogger].
///
/// Only active on mobile platforms where file logging is supported.
/// Respects [FileLogger.isEnabled] — if the user has not enabled file
/// logging, [handles] returns false and no file I/O occurs.
///
/// Does not modify [LogTracking] itself — wraps it as a read-only adapter
/// (Open/Closed Principle).
class FileLogHandler implements LogHandler {
  final FileLogger _logger;

  const FileLogHandler(this._logger);

  @override
  bool handles(Level level) => PlatformInfo.isMobile && _logger.isEnabled;

  @override
  void handle(LogRecord record) {
    _logger.addLog(message: _format(record));
  }

  String _format(LogRecord record) {
    final levelTag = record.level.name.toUpperCase();
    return '[$levelTag] ${record.rawMessage}';
  }
}
