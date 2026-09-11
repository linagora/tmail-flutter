import 'package:core/utils/sentry/sentry_config.dart';
import 'package:core/utils/sentry/sentry_initializer.dart';
import 'package:core/utils/sentry/sentry_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

void main() {
  final sentryManager = SentryManager.instance;
  final replayEnabledConfig = SentryConfig(
    dsn: 'https://public@example.com/1',
    environment: 'test',
    release: '1.0.0',
    isAvailable: true,
    sessionSampleRate: 1,
    onErrorSampleRate: 1,
  );

  setUp(() {
    sentryManager.setSentryReportingDefault(true);
    sentryManager.setSentryReportingConsent(null);
  });

  group('SentryInitializer.beforeSendHandler', () {
    // This gate — not the one in SentryManager — is what stops the events the
    // SDK captures by itself, such as uncaught Flutter errors.
    test('drops the event while the user has reporting turned off', () async {
      sentryManager.setSentryReportingConsent(false);

      expect(await SentryInitializer.beforeSendHandler(SentryEvent(), null), isNull);
    });

    test('drops the event while the instance opts users out by default', () async {
      sentryManager.setSentryReportingDefault(false);

      expect(await SentryInitializer.beforeSendHandler(SentryEvent(), null), isNull);
    });

    test('keeps the event once the user opts in on such an instance', () async {
      sentryManager.setSentryReportingDefault(false);
      sentryManager.setSentryReportingConsent(true);

      expect(await SentryInitializer.beforeSendHandler(SentryEvent(), null), isNotNull);
    });

    test('still strips sensitive request headers when it keeps the event', () async {
      final event = SentryEvent(
        request: SentryRequest(
          url: 'https://example.org/jmap',
          headers: const {'Authorization': 'Bearer secret', 'Accept': 'application/json'},
        ),
      );

      final sent = await SentryInitializer.beforeSendHandler(event, null);

      expect(sent?.request?.headers.containsKey('Authorization'), isFalse);
      expect(sent?.request?.headers['Accept'], 'application/json');
    });
  });

  group('SentryInitializer session replay', () {
    test('disables Replay while consent is unknown', () {
      final options = SentryFlutterOptions();

      SentryInitializer.setUpSentryOptions(options, replayEnabledConfig);

      expect(options.replay.sessionSampleRate, isNull);
      expect(options.replay.onErrorSampleRate, isNull);
    });

    test('disables Replay while the user is opted out', () {
      sentryManager.setSentryReportingConsent(false);
      final options = SentryFlutterOptions();

      SentryInitializer.setUpSentryOptions(options, replayEnabledConfig);

      expect(options.replay.sessionSampleRate, isNull);
      expect(options.replay.onErrorSampleRate, isNull);
    });

    test(
      'keeps Replay disabled when consent can change after initialization',
      () {
        sentryManager.setSentryReportingConsent(true);
        final options = SentryFlutterOptions();

        SentryInitializer.setUpSentryOptions(options, replayEnabledConfig);

        expect(options.replay.sessionSampleRate, isNull);
        expect(options.replay.onErrorSampleRate, isNull);
      },
    );
  });

  group('SentryInitializer autonomous senders', () {
    test('keeps senders that bypass the runtime consent gate disabled', () {
      final options = SentryFlutterOptions()
        ..enableAutoSessionTracking = true
        ..enableNativeCrashHandling = true
        ..anrEnabled = true
        ..enableAppHangTracking = true
        ..enableWatchdogTerminationTracking = true
        ..enableAutoPerformanceTracing = true
        ..enableAutoNativeBreadcrumbs = true
        ..sendClientReports = true;

      SentryInitializer.setUpSentryOptions(options, replayEnabledConfig);

      expect(options.enableAutoSessionTracking, isFalse);
      expect(options.enableNativeCrashHandling, isFalse);
      expect(options.anrEnabled, isFalse);
      expect(options.enableAppHangTracking, isFalse);
      expect(options.enableWatchdogTerminationTracking, isFalse);
      expect(options.enableAutoPerformanceTracing, isFalse);
      expect(options.enableAutoNativeBreadcrumbs, isFalse);
      expect(options.sendClientReports, isFalse);
    });
  });

  group('SentryInitializer secondary reporting gates', () {
    final breadcrumb = Breadcrumb(message: 'navigation');
    final log = SentryLog(
      timestamp: DateTime.utc(2026),
      level: SentryLogLevel.info,
      body: 'diagnostic',
      attributes: const {},
    );

    test('drops breadcrumbs, logs and metrics while reporting is off', () {
      sentryManager.setSentryReportingConsent(false);

      expect(
        SentryInitializer.beforeBreadcrumbHandler(breadcrumb, Hint()),
        isNull,
      );
      expect(SentryInitializer.beforeSendLogHandler(log), isNull);
      expect(SentryInitializer.beforeMetricHandler('metric'), isFalse);
    });

    test('keeps breadcrumbs, logs and metrics while reporting is allowed', () {
      expect(
        SentryInitializer.beforeBreadcrumbHandler(breadcrumb, Hint()),
        same(breadcrumb),
      );
      expect(SentryInitializer.beforeSendLogHandler(log), same(log));
      expect(SentryInitializer.beforeMetricHandler('metric'), isTrue);
    });
  });
}
