import 'package:core/utils/logging/app_logger_registry.dart';
import 'package:core/utils/logging/log_handler.dart';
import 'package:core/utils/logging/log_level.dart';
import 'package:core/utils/logging/log_record.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeHandler extends LogHandler {
  final List<LogRecord> received = [];
  final bool Function(Level) _acceptsLevel;

  _FakeHandler({bool Function(Level)? acceptsLevel})
      : _acceptsLevel = (acceptsLevel ?? (_) => true);

  @override
  bool acceptsLevel(Level level) => _acceptsLevel(level);

  @override
  bool canHandle(LogRecord record) => _acceptsLevel(record.level);

  @override
  void handle(LogRecord record) => received.add(record);
}

class _OtherFakeHandler extends _FakeHandler {
  _OtherFakeHandler() : super(acceptsLevel: (_) => true);
}

class _ThrowingHandlesHandler extends LogHandler {
  @override
  bool canHandle(LogRecord record) => throw Exception('handles() exploded');

  @override
  void handle(LogRecord record) {}
}

class _ThrowingHandleHandler extends LogHandler {
  @override
  bool canHandle(LogRecord record) => true;

  @override
  void handle(LogRecord record) => throw Exception('handle() exploded');
}

/// Same concrete type as [_FakeHandler] but with a distinct [handlerKey],
/// used to verify that two instances of the same class can coexist in the registry.
class _KeyedFakeHandler extends _FakeHandler {
  final String _key;

  _KeyedFakeHandler(this._key);

  @override
  String get handlerKey => _key;
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

    test('is idempotent — same handlerKey registered twice stays as one', () {
      registry.registerHandler(_FakeHandler());
      registry.registerHandler(_FakeHandler());
      expect(registry.handlerCount, 1);
    });

    test('registers distinct handler types separately', () {
      registry.registerHandler(_FakeHandler());
      registry.registerHandler(_OtherFakeHandler());
      expect(registry.handlerCount, 2);
    });

    test('two instances of same class with different handlerKey coexist', () {
      registry.registerHandler(_KeyedFakeHandler('key-a'));
      registry.registerHandler(_KeyedFakeHandler('key-b'));
      expect(registry.handlerCount, 2);
    });

    test('re-registering same handlerKey replaces the existing handler', () {
      final first = _KeyedFakeHandler('key-a');
      final second = _KeyedFakeHandler('key-a');
      registry.registerHandler(first);
      registry.registerHandler(second);
      expect(registry.handlerCount, 1);

      const record = LogRecord(level: Level.info, rawMessage: 'x');
      registry.dispatch(record);
      expect(second.received, hasLength(1));
      expect(first.received, isEmpty);
    });

    test('both keyed handlers receive dispatched records', () {
      final handlerA = _KeyedFakeHandler('key-a');
      final handlerB = _KeyedFakeHandler('key-b');
      registry.registerHandler(handlerA);
      registry.registerHandler(handlerB);

      const record = LogRecord(level: Level.info, rawMessage: 'hello');
      registry.dispatch(record);
      expect(handlerA.received, hasLength(1));
      expect(handlerB.received, hasLength(1));
    });
  });

  group('AppLoggerRegistry.hasHandlerFor', () {
    test('returns true when a handler accepts the level', () {
      registry.registerHandler(_FakeHandler(acceptsLevel: (l) => l == Level.error));
      expect(registry.hasHandlerFor(Level.error), isTrue);
    });

    test('returns false when no handler accepts the level', () {
      registry.registerHandler(_FakeHandler(acceptsLevel: (l) => l == Level.error));
      expect(registry.hasHandlerFor(Level.debug), isFalse);
    });

    test('returns false when no handlers are registered', () {
      expect(registry.hasHandlerFor(Level.info), isFalse);
    });
  });

  group('AppLoggerRegistry.dispatch', () {
    test('dispatches record to handler that handles the level', () {
      final handler = _FakeHandler(acceptsLevel: (l) => l == Level.error);
      registry.registerHandler(handler);

      const record = LogRecord(level: Level.error, rawMessage: 'oops');
      registry.dispatch(record);

      expect(handler.received, hasLength(1));
      expect(handler.received.first.rawMessage, 'oops');
    });

    test('does not dispatch record to handler that rejects the level', () {
      final handler = _FakeHandler(acceptsLevel: (l) => l == Level.error);
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

    test('canHandle() throwing does not crash dispatch; other handlers still receive the record', () {
      final throwing = _ThrowingHandlesHandler();
      final good = _OtherFakeHandler();
      registry.registerHandler(throwing);
      registry.registerHandler(good);

      const record = LogRecord(level: Level.info, rawMessage: 'test');
      expect(() => registry.dispatch(record), returnsNormally);
      expect(good.received, hasLength(1));
    });

    test('handle() throwing does not crash dispatch; other handlers still receive the record', () {
      final throwing = _ThrowingHandleHandler();
      final good = _OtherFakeHandler();
      registry.registerHandler(throwing);
      registry.registerHandler(good);

      const record = LogRecord(level: Level.info, rawMessage: 'test');
      expect(() => registry.dispatch(record), returnsNormally);
      expect(good.received, hasLength(1));
    });
  });

  group('AppLoggerRegistry.resetForTesting', () {
    test('clears all handlers', () {
      registry.registerHandler(_FakeHandler());
      registry.resetForTesting();
      expect(registry.handlerCount, 0);
    });
  });

  group('LogRecord.build', () {
    test('builds rawMessage from message only', () {
      final record = LogRecord.build(level: Level.info, message: 'hello');
      expect(record.rawMessage, 'hello');
    });

    test('appends exception to rawMessage', () {
      final record = LogRecord.build(
        level: Level.error,
        message: 'fail',
        exception: Exception('boom'),
      );
      expect(record.rawMessage, contains('fail'));
      expect(record.rawMessage, contains('exception:'));
    });

    test('appends extras to rawMessage', () {
      final record = LogRecord.build(
        level: Level.error,
        message: 'fail',
        extras: {'key': 'value'},
      );
      expect(record.rawMessage, contains('extras:'));
    });

    test('appends stackTrace to rawMessage', () {
      final stack = StackTrace.current;
      final record = LogRecord.build(
        level: Level.error,
        message: 'fail',
        stackTrace: stack,
      );
      expect(record.rawMessage, contains('stackTrace:'));
    });

    test('rawMessage is empty string when message is null and no extras', () {
      final record = LogRecord.build(level: Level.info, message: null);
      expect(record.rawMessage, isEmpty);
    });

    test('propagates exception, stackTrace, extras to LogRecord fields', () {
      final ex = Exception('err');
      final st = StackTrace.current;
      final extras = {'a': 1};
      final record = LogRecord.build(
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
