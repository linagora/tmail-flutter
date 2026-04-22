import 'package:core/utils/logging/handlers/file_log_handler.dart';
import 'package:core/utils/logging/log_level.dart';
import 'package:core/utils/logging/log_record.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeFileLogger implements FileLogger {
  final List<String> logged = [];

  @override
  bool isEnabled = false;

  @override
  Future<void> addLog({required String message}) async {
    logged.add(message);
  }
}

void main() {
  late _FakeFileLogger logger;
  late FileLogHandler handler;

  setUp(() {
    logger = _FakeFileLogger();
    handler = FileLogHandler(logger);
  });

  group('FileLogHandler.handles', () {
    test('returns false when FileLogger is disabled', () {
      logger.isEnabled = false;
      expect(handler.handles(Level.error), isFalse);
    });

    test('returns false for any level when disabled', () {
      logger.isEnabled = false;
      for (final level in Level.values) {
        expect(handler.handles(level), isFalse,
            reason: 'Should not handle $level when disabled');
      }
    });
  });

  group('FileLogHandler.handle', () {
    test('formats and delegates to FileLogger.addLog', () async {
      const record = LogRecord(
        level: Level.error,
        rawMessage: 'something failed',
      );

      handler.handle(record);

      await Future.microtask(() {});
      expect(logger.logged, hasLength(1));
      expect(logger.logged.first, '[ERROR] something failed');
    });

    test('includes level tag in formatted message for warning', () async {
      const record = LogRecord(
        level: Level.warning,
        rawMessage: 'low disk space',
      );

      handler.handle(record);

      await Future.microtask(() {});
      expect(logger.logged.first, startsWith('[WARNING]'));
    });

    test('preserves raw message content', () async {
      const raw = 'detailed diagnostic info';
      const record = LogRecord(level: Level.trace, rawMessage: raw);

      handler.handle(record);

      await Future.microtask(() {});
      expect(logger.logged.first, contains(raw));
    });

    test('formats all levels correctly', () async {
      final levels = {
        Level.critical: '[CRITICAL]',
        Level.error: '[ERROR]',
        Level.warning: '[WARNING]',
        Level.info: '[INFO]',
        Level.debug: '[DEBUG]',
        Level.trace: '[TRACE]',
      };

      for (final entry in levels.entries) {
        final fakeLogger = _FakeFileLogger();
        final h = FileLogHandler(fakeLogger);
        h.handle(LogRecord(level: entry.key, rawMessage: 'msg'));
        await Future.microtask(() {});
        expect(fakeLogger.logged.first, startsWith(entry.value),
            reason: 'Level ${entry.key} should format as ${entry.value}');
      }
    });
  });
}
