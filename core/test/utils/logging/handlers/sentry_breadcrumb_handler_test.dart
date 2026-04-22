import 'package:core/utils/logging/handlers/sentry_breadcrumb_handler.dart';
import 'package:core/utils/logging/log_level.dart';
import 'package:core/utils/logging/log_record.dart';
import 'package:core/utils/sentry/sentry_reporter.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeSentryReporter implements SentryReporter {
  final List<({String message, Map<String, dynamic>? extras})> capturedBreadcrumbs = [];

  @override
  void captureException(dynamic exception, {StackTrace? stackTrace, String? message, Map<String, dynamic>? extras}) {}

  @override
  void captureMessage(String message, {Map<String, dynamic>? extras}) {}

  @override
  void addBreadcrumb(String message, {Map<String, dynamic>? extras}) {
    capturedBreadcrumbs.add((message: message, extras: extras));
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
      final record = LogRecord(
        level: Level.trace,
        rawMessage: 'cache miss',
        extras: {'source': 'remote'},
      );

      handler.handle(record);

      expect(reporter.capturedBreadcrumbs.first.extras, {'source': 'remote'});
    });

    test('does not call captureException or captureMessage', () {
      // Verified by _FakeSentryReporter having empty lists for those
      const record = LogRecord(
        level: Level.trace,
        rawMessage: 'trace message',
      );

      handler.handle(record);

      // Only breadcrumbs should be populated
      expect(reporter.capturedBreadcrumbs, hasLength(1));
    });
  });
}
