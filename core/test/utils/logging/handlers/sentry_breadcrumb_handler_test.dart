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

  group('SentryBreadcrumbHandler.acceptsLevel', () {
    test('accepts trace level', () {
      expect(handler.acceptsLevel(Level.trace), isTrue);
    });

    test('rejects error', () {
      expect(handler.acceptsLevel(Level.error), isFalse);
    });

    test('rejects critical', () {
      expect(handler.acceptsLevel(Level.critical), isFalse);
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
  });

  group('SentryBreadcrumbHandler.canHandle', () {
    test('handles trace record', () {
      expect(
        handler.canHandle(const LogRecord(level: Level.trace, rawMessage: '')),
        isTrue,
      );
    });

    test('does not handle error record', () {
      expect(
        handler.canHandle(const LogRecord(level: Level.error, rawMessage: '')),
        isFalse,
      );
    });
  });

  group('SentryBreadcrumbHandler — acceptsLevel/canHandle contract', () {
    test('canHandle() is consistent with acceptsLevel() for all levels', () {
      for (final level in Level.values) {
        final record = LogRecord(level: level, rawMessage: '');
        if (!handler.acceptsLevel(level)) {
          expect(
            handler.canHandle(record),
            isFalse,
            reason: 'canHandle() must return false when acceptsLevel() is false — level: $level',
          );
        }
      }
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
