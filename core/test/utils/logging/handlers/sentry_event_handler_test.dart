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
  final List<({String message, Map<String, dynamic>? extras})> capturedBreadcrumbs = [];

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
  void addBreadcrumb(String message, {Map<String, dynamic>? extras}) {
    capturedBreadcrumbs.add((message: message, extras: extras));
  }
}

void main() {
  late _FakeSentryReporter reporter;
  late SentryEventHandler handler;

  setUp(() {
    reporter = _FakeSentryReporter();
    handler = SentryEventHandler(reporter);
  });

  group('SentryEventHandler.handles', () {
    test('handles error level', () {
      expect(handler.handles(Level.error), isTrue);
    });

    test('handles critical level', () {
      expect(handler.handles(Level.critical), isTrue);
    });

    test('does not handle warning', () {
      expect(handler.handles(Level.warning), isFalse);
    });

    test('does not handle info', () {
      expect(handler.handles(Level.info), isFalse);
    });

    test('does not handle debug', () {
      expect(handler.handles(Level.debug), isFalse);
    });

    test('does not handle trace', () {
      expect(handler.handles(Level.trace), isFalse);
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
  });
}
