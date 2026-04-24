import 'package:core/utils/logging/handlers/sentry_event_handler.dart';
import 'package:core/utils/logging/log_level.dart';
import 'package:core/utils/logging/log_record.dart';
import 'package:core/utils/sentry/sentry_reporter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class _FakeSentryReporter implements SentryReporter {
  final List<({dynamic exception, StackTrace? stackTrace, String? message, Map<String, dynamic>? extras, SentryLevel level})>
      capturedExceptions = [];
  final List<({String message, Map<String, dynamic>? extras, SentryLevel level})> capturedMessages = [];
  final List<({String message, Map<String, dynamic>? extras, SentryLevel level, String? category})> capturedBreadcrumbs = [];

  @override
  void captureException(
    dynamic exception, {
    StackTrace? stackTrace,
    String? message,
    Map<String, dynamic>? extras,
    SentryLevel level = SentryLevel.error,
  }) {
    capturedExceptions.add((
      exception: exception,
      stackTrace: stackTrace,
      message: message,
      extras: extras,
      level: level,
    ));
  }

  @override
  void captureMessage(
    String message, {
    Map<String, dynamic>? extras,
    SentryLevel level = SentryLevel.info,
  }) {
    capturedMessages.add((message: message, extras: extras, level: level));
  }

  @override
  void addBreadcrumb(
    String message, {
    Map<String, dynamic>? extras,
    SentryLevel level = SentryLevel.debug,
    String? category,
  }) {
    capturedBreadcrumbs.add((message: message, extras: extras, level: level, category: category));
  }
}

void main() {
  late _FakeSentryReporter reporter;
  late SentryEventHandler handler;

  setUp(() {
    reporter = _FakeSentryReporter();
    handler = SentryEventHandler(reporter);
  });

  group('SentryEventHandler.acceptsLevel', () {
    test('accepts error level', () {
      expect(handler.acceptsLevel(Level.error), isTrue);
    });

    test('accepts critical level', () {
      expect(handler.acceptsLevel(Level.critical), isTrue);
    });

    test('rejects warning', () {
      expect(handler.acceptsLevel(Level.warning), isFalse);
    });

    test('rejects info', () {
      expect(handler.acceptsLevel(Level.info), isFalse);
    });

    test('rejects debug', () {
      expect(handler.acceptsLevel(Level.debug), isFalse);
    });

    test('rejects trace', () {
      expect(handler.acceptsLevel(Level.trace), isFalse);
    });
  });

  group('SentryEventHandler.handles', () {
    test('handles error record', () {
      expect(
        handler.handles(const LogRecord(level: Level.error, rawMessage: '')),
        isTrue,
      );
    });

    test('handles critical record', () {
      expect(
        handler.handles(const LogRecord(level: Level.critical, rawMessage: '')),
        isTrue,
      );
    });

    test('does not handle info record', () {
      expect(
        handler.handles(const LogRecord(level: Level.info, rawMessage: '')),
        isFalse,
      );
    });
  });

  group('SentryEventHandler — acceptsLevel/handles contract', () {
    test('handles() is consistent with acceptsLevel() for all levels', () {
      for (final level in Level.values) {
        final record = LogRecord(level: level, rawMessage: '');
        if (!handler.acceptsLevel(level)) {
          expect(
            handler.handles(record),
            isFalse,
            reason: 'handles() must return false when acceptsLevel() is false — level: $level',
          );
        }
      }
    });
  });

  group('SentryEventHandler.handle — with exception', () {
    test('calls captureException when record has exception', () {
      final ex = Exception('boom');
      final st = StackTrace.current;
      final record = LogRecord(
        level: Level.error,
        rawMessage: 'something failed',
        exception: ex,
        stackTrace: st,
        extras: {'key': 'val'},
      );

      handler.handle(record);

      expect(reporter.capturedExceptions, hasLength(1));
      expect(reporter.capturedExceptions.first.exception, ex);
      expect(reporter.capturedExceptions.first.stackTrace, st);
      expect(reporter.capturedExceptions.first.message, 'something failed');
      expect(reporter.capturedExceptions.first.extras, {'key': 'val'});
      expect(reporter.capturedExceptions.first.level, SentryLevel.error);
      expect(reporter.capturedMessages, isEmpty);
    });

    test('maps critical level to SentryLevel.fatal', () {
      final record = LogRecord(
        level: Level.critical,
        rawMessage: 'system down',
        exception: Exception('fatal error'),
      );

      handler.handle(record);

      expect(reporter.capturedExceptions.first.level, SentryLevel.fatal);
    });
  });

  group('SentryEventHandler.handle — without exception', () {
    test('calls captureMessage when record has no exception', () {
      const record = LogRecord(
        level: Level.error,
        rawMessage: 'something went wrong',
      );

      handler.handle(record);

      expect(reporter.capturedMessages, hasLength(1));
      expect(reporter.capturedMessages.first.message, 'something went wrong');
      expect(reporter.capturedMessages.first.level, SentryLevel.error);
      expect(reporter.capturedExceptions, isEmpty);
    });

    test('passes extras to captureMessage', () {
      const record = LogRecord(
        level: Level.error,
        rawMessage: 'msg',
        extras: {'a': 1},
      );

      handler.handle(record);

      expect(reporter.capturedMessages.first.extras, {'a': 1});
    });

    test('maps critical level to SentryLevel.fatal when no exception', () {
      const record = LogRecord(
        level: Level.critical,
        rawMessage: 'system down',
      );

      handler.handle(record);

      expect(reporter.capturedMessages.first.level, SentryLevel.fatal);
    });
  });
}
