import 'package:core/utils/logging/app_logger_registry.dart';
import 'package:core/utils/logging/log_handler.dart';
import 'package:core/utils/logging/log_level.dart';
import 'package:core/utils/logging/log_record.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeHandler implements LogHandler {
  final List<LogRecord> received = [];
  final bool Function(Level) _handles;

  _FakeHandler({bool Function(Level)? handles})
      : _handles = (handles ?? (_) => true);

  @override
  bool handles(Level level) => _handles(level);

  @override
  void handle(LogRecord record) => received.add(record);
}

class _OtherFakeHandler extends _FakeHandler {
  _OtherFakeHandler({super.handles});
}

void main() {
  late AppLoggerRegistry registry;

  setUp(() {
    registry = AppLoggerRegistry.instance;
    registry.resetForTesting();
  });

  tearDown(() {
    registry.resetForTesting();
  });

  group('AppLoggerRegistry.registerHandler', () {
    test('registers a handler', () {
      registry.registerHandler(_FakeHandler());
      expect(registry.handlerCount, 1);
    });

    test('is idempotent — same runtimeType registered twice stays as one', () {
      registry.registerHandler(_FakeHandler());
      registry.registerHandler(_FakeHandler());
      expect(registry.handlerCount, 1);
    });

    test('registers distinct handler types separately', () {
      registry.registerHandler(_FakeHandler());
      registry.registerHandler(_OtherFakeHandler());
      expect(registry.handlerCount, 2);
    });
  });

  group('AppLoggerRegistry.dispatch', () {
    test('dispatches record to handler that handles the level', () {
      final handler = _FakeHandler(handles: (l) => l == Level.error);
      registry.registerHandler(handler);

      const record = LogRecord(level: Level.error, rawMessage: 'oops');
      registry.dispatch(record);

      expect(handler.received, hasLength(1));
      expect(handler.received.first.rawMessage, 'oops');
    });

    test('does not dispatch record to handler that rejects the level', () {
      final handler = _FakeHandler(handles: (l) => l == Level.error);
      registry.registerHandler(handler);

      const record = LogRecord(level: Level.trace, rawMessage: 'verbose');
      registry.dispatch(record);

      expect(handler.received, isEmpty);
    });

    test('dispatches to multiple handlers when both accept the level', () {
      final h1 = _FakeHandler();
      final h2 = _OtherFakeHandler();
      registry.registerHandler(h1);
      registry.registerHandler(h2);

      const record = LogRecord(level: Level.info, rawMessage: 'hello');
      registry.dispatch(record);

      expect(h1.received, hasLength(1));
      expect(h2.received, hasLength(1));
    });

    test('no-op when no handlers registered', () {
      expect(
        () => registry.dispatch(const LogRecord(level: Level.info, rawMessage: 'x')),
        returnsNormally,
      );
    });
  });

  group('AppLoggerRegistry.resetForTesting', () {
    test('clears all handlers', () {
      registry.registerHandler(_FakeHandler());
      registry.resetForTesting();
      expect(registry.handlerCount, 0);
    });
  });

  group('buildLogRecord', () {
    test('builds rawMessage from message only', () {
      final record = buildLogRecord(level: Level.info, message: 'hello');
      expect(record.rawMessage, 'hello');
    });

    test('appends exception to rawMessage', () {
      final record = buildLogRecord(
        level: Level.error,
        message: 'fail',
        exception: Exception('boom'),
      );
      expect(record.rawMessage, contains('fail'));
      expect(record.rawMessage, contains('exception:'));
    });

    test('appends extras to rawMessage', () {
      final record = buildLogRecord(
        level: Level.error,
        message: 'fail',
        extras: {'key': 'value'},
      );
      expect(record.rawMessage, contains('extras:'));
    });

    test('appends stackTrace to rawMessage', () {
      final stack = StackTrace.current;
      final record = buildLogRecord(
        level: Level.error,
        message: 'fail',
        stackTrace: stack,
      );
      expect(record.rawMessage, contains('stackTrace:'));
    });

    test('rawMessage is empty string when message is null and no extras', () {
      final record = buildLogRecord(level: Level.info, message: null);
      expect(record.rawMessage, isEmpty);
    });

    test('propagates exception, stackTrace, extras to LogRecord fields', () {
      final ex = Exception('err');
      final st = StackTrace.current;
      final extras = {'a': 1};
      final record = buildLogRecord(
        level: Level.error,
        message: 'msg',
        exception: ex,
        stackTrace: st,
        extras: extras,
      );
      expect(record.exception, ex);
      expect(record.stackTrace, st);
      expect(record.extras, extras);
    });
  });
}
