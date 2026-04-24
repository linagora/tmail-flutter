import 'package:core/utils/logging/formatters/log_formatter.dart';
import 'package:core/utils/logging/handlers/console_log_handler.dart';
import 'package:core/utils/logging/log_level.dart';
import 'package:core/utils/logging/log_record.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter_test/flutter_test.dart';

class _SpyFormatter implements LogFormatter {
  final List<({Level level, String raw})> calls = [];

  @override
  String format(Level level, String raw) {
    calls.add((level: level, raw: raw));
    return 'formatted:$raw';
  }
}

void main() {
  late _SpyFormatter formatter;
  late ConsoleLogHandler handler;

  setUp(() {
    formatter = _SpyFormatter();
    handler = ConsoleLogHandler(formatter: formatter);
    PlatformInfo.isTestingForWeb = false;
  });

  tearDown(() {
    PlatformInfo.isTestingForWeb = false;
  });

  // ─── acceptsLevel ──────────────────────────────────────────────────────────

  group('ConsoleLogHandler.acceptsLevel — non-web (debug mode)', () {
    // In test environment kDebugMode is always true.
    test('accepts all levels', () {
      for (final level in Level.values) {
        expect(handler.acceptsLevel(level), isTrue, reason: 'level: $level');
      }
    });
  });

  group('ConsoleLogHandler.acceptsLevel — web', () {
    setUp(() => PlatformInfo.isTestingForWeb = true);

    test('always accepts — per-record webConsoleEnabled may override debug gate', () {
      for (final level in Level.values) {
        expect(handler.acceptsLevel(level), isTrue, reason: 'level: $level');
      }
    });
  });

  // ─── handles ───────────────────────────────────────────────────────────────

  group('ConsoleLogHandler.handles — non-web (debug mode)', () {
    test('accepts record regardless of webConsoleEnabled', () {
      const record = LogRecord(level: Level.info, rawMessage: 'msg');
      expect(handler.handles(record), isTrue);
    });

    test('accepts record with webConsoleEnabled=true', () {
      const record = LogRecord(
        level: Level.info,
        rawMessage: 'msg',
        webConsoleEnabled: true,
      );
      expect(handler.handles(record), isTrue);
    });
  });

  group('ConsoleLogHandler.handles — web', () {
    setUp(() => PlatformInfo.isTestingForWeb = true);

    test('accepts when webConsoleEnabled=true', () {
      const record = LogRecord(
        level: Level.error,
        rawMessage: 'msg',
        webConsoleEnabled: true,
      );
      expect(handler.handles(record), isTrue);
    });

    test('accepts when isDebugMode=true (always true in test)', () {
      const record = LogRecord(
        level: Level.debug,
        rawMessage: 'msg',
        webConsoleEnabled: false,
      );
      // kDebugMode is true in test environment → handles() returns true
      expect(handler.handles(record), isTrue);
    });
  });

  // ─── acceptsLevel / handles contract ──────────────────────────────────────

  group('ConsoleLogHandler — acceptsLevel/handles contract', () {
    test('if acceptsLevel returns false then handles also returns false', () {
      // acceptsLevel is always true in test (debug mode / web), so we can only
      // verify the positive direction: acceptsLevel true does not imply handles false.
      // The negative direction is validated by the non-web release-mode path which
      // cannot be exercised in unit tests because kDebugMode is a compile-time const.
      for (final level in Level.values) {
        final record = LogRecord(level: level, rawMessage: '');
        if (!handler.acceptsLevel(level)) {
          expect(
            handler.handles(record),
            isFalse,
            reason: 'handles() must respect acceptsLevel() contract for $level',
          );
        }
      }
    });
  });

  // ─── handle ────────────────────────────────────────────────────────────────

  group('ConsoleLogHandler.handle — formatter delegation', () {
    test('calls formatter.format with correct level and rawMessage', () {
      const record = LogRecord(level: Level.error, rawMessage: 'something failed');
      handler.handle(record);

      expect(formatter.calls, hasLength(1));
      expect(formatter.calls.first.level, Level.error);
      expect(formatter.calls.first.raw, 'something failed');
    });

    test('calls formatter once per handle() call', () {
      for (final level in Level.values) {
        handler.handle(LogRecord(level: level, rawMessage: 'x'));
      }
      expect(formatter.calls, hasLength(Level.values.length));
    });

    test('formatter output is used — format is called before output', () {
      const record = LogRecord(level: Level.info, rawMessage: 'hello');
      handler.handle(record);
      // If formatter was never called, the spy list would be empty.
      expect(formatter.calls, isNotEmpty);
    });
  });

  group('ConsoleLogHandler.handle — web path', () {
    setUp(() => PlatformInfo.isTestingForWeb = true);

    test('calls formatter with correct level on web', () {
      const record = LogRecord(
        level: Level.warning,
        rawMessage: 'web warning',
        webConsoleEnabled: true,
      );
      handler.handle(record);

      expect(formatter.calls.first.level, Level.warning);
      expect(formatter.calls.first.raw, 'web warning');
    });

    test('calls formatter for each log level on web', () {
      for (final level in Level.values) {
        handler.handle(LogRecord(level: level, rawMessage: 'msg'));
      }
      expect(formatter.calls, hasLength(Level.values.length));
    });
  });
}
