import 'package:core/utils/logging/log_handler.dart';
import 'package:core/utils/logging/log_level.dart';
import 'package:core/utils/logging/log_record.dart';

/// Captures dispatched [LogRecord]s so tests can assert what reaches Sentry.
///
/// Register with `AppLoggerRegistry.instance.registerHandler(...)` in setUp and
/// clear with `AppLoggerRegistry.instance.resetForTesting()` in tearDown.
class CapturingLogHandler extends LogHandler {
  final List<LogRecord> records = [];

  @override
  void handle(LogRecord record) => records.add(record);

  List<LogRecord> get errorRecords =>
      records.where((r) => r.level == Level.error).toList();

  List<LogRecord> get warningRecords =>
      records.where((r) => r.level == Level.warning).toList();
}
