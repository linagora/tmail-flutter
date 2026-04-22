import 'package:core/utils/logging/handlers/sentry_breadcrumb_handler.dart';
import 'package:core/utils/logging/log_level.dart';
import 'package:core/utils/logging/log_record.dart';
import 'package:core/utils/sentry/sentry_reporter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class _FakeSentryReporter implements SentryReporter {
  final List<dynamic> capturedExceptions = [];
  final List<String> capturedMessages = [];
  final List<({String message, Map<String, dynamic>? extras, SentryLevel level, String? category})> capturedBreadcrumbs = [];

  @override
  void captureException(
    dynamic exception, {
    StackTrace? stackTrace,
    String? message,
    Map<String, dynamic>? extras,
    SentryLevel level = SentryLevel.error,
  }) {
    capturedExceptions.add(exception);
  }

  @override
  void captureMessage(
    String message, {
    Map<String, dynamic>? extras,
    SentryLevel level = SentryLevel.info,
  }) {
    capturedMessages.add(message);
  }

  @override
  void addBreadcrumb(
    String message, {
    Map<String, dynamic>? extras,
    SentryLevel level = SentryLevel.debug,
    String? category,
  }) {
    capturedBreadcrumbs.add((
      message: message,
      extras: extras,
      level: level,
      category: category,
    ));
  }
}

void main() {
  late _FakeSentryReporter reporter;
  late SentryBreadcrumbHandler handler;

  setUp(() {
    reporter = _FakeSentryReporter();
    handler = SentryBreadcrumbHandler(reporter);
  });

  group('SentryBreadcrumbHandler.handles', () {
    test('handles trace level', () {
      expect(handler.handles(Level.trace), isTrue);
    });

    test('does not handle error', () {
      expect(handler.handles(Level.error), isFalse);
    });

    test('does not handle critical', () {
      expect(handler.handles(Level.critical), isFalse);
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
  });

  group('SentryBreadcrumbHandler.handle', () {
    test('calls addBreadcrumb with rawMessage', () {
      const record = LogRecord(
        level: Level.trace,
        rawMessage: 'fetching mailbox list',
      );

      handler.handle(record);

      expect(reporter.capturedBreadcrumbs, hasLength(1));
      expect(reporter.capturedBreadcrumbs.first.message, 'fetching mailbox list');
    });

    test('passes extras to addBreadcrumb', () {
      const record = LogRecord(
        level: Level.trace,
        rawMessage: 'cache miss',
        extras: {'source': 'remote'},
      );

      handler.handle(record);

      expect(reporter.capturedBreadcrumbs.first.extras, {'source': 'remote'});
    });

    test('passes SentryLevel.debug and category log to addBreadcrumb', () {
      const record = LogRecord(level: Level.trace, rawMessage: 'trace event');

      handler.handle(record);

      expect(reporter.capturedBreadcrumbs.first.level, SentryLevel.debug);
      expect(reporter.capturedBreadcrumbs.first.category, 'log');
    });

    test('does not call captureException or captureMessage', () {
      const record = LogRecord(
        level: Level.trace,
        rawMessage: 'trace message',
      );

      handler.handle(record);

      expect(reporter.capturedExceptions, isEmpty);
      expect(reporter.capturedMessages, isEmpty);
      expect(reporter.capturedBreadcrumbs, hasLength(1));
    });
  });
}
