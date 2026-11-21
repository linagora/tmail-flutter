import 'package:core/utils/sentry/sentry_config.dart';
import 'package:core/utils/sentry/sentry_manager.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

SentryConfig _config() => SentryConfig(
      dsn: 'https://public@example.com/1',
      environment: 'test',
      release: '1.0.0',
      isAvailable: true,
      isReportingAllowed: false,
    );

class _Probe {
  _Probe({
    Duration scopeSyncDelay = Duration.zero,
    DateTime Function()? now,
  }) {
    manager = SentryManager.forTesting(
      now: now,
      isSentryAvailable: false,
      synchronizeScope: (_, {required clearBreadcrumbs}) =>
          Future<void>.delayed(scopeSyncDelay),
      initializeSentrySdk: ({appRunner, sentryConfig}) async => true,
      closeSentrySdk: () async {},
      captureException: (exception, stackTrace, message, extras, level) async {
        sent.add('$exception');
      },
      captureMessage: (message, level, extras) async {
        sent.add(message);
      },
    );
  }

  late final SentryManager manager;
  final sent = <String>[];

  /// What SentryEcosystem.setUp does once the ecosystem answers.
  Future<void> receiveConfiguration({required bool reportingAllowed}) async {
    manager.suspendSentryReporting();
    manager.setSentryReportingDefault(reportingAllowed);
    await manager.initializeWithSentryConfig(_config());
    manager.resumeSentryReporting();
    await _settle();
  }

  /// What applySentryReportingConsent does once the server settings answer.
  Future<void> receiveConsent(bool? consent) async {
    manager.setSentryReportingConsent(consent);
    manager.resolveReportingConsent();
    await _settle();
  }

  Future<void> receiveConfigurationAndConsent({
    required bool reportingAllowed,
  }) async {
    await receiveConfiguration(reportingAllowed: reportingAllowed);
    await receiveConsent(null);
  }

  Future<void> _settle() async {
    await manager.pendingLifecycleTransition;
    await manager.pendingScopeSync;
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  test('sends the errors raised before the configuration once reporting is allowed',
      () async {
    final probe = _Probe();

    probe.manager.captureException('session failed');
    probe.manager.captureMessage('folders failed');
    await probe.receiveConfigurationAndConsent(reportingAllowed: true);

    expect(probe.sent, ['session failed', 'folders failed']);
  });

  test('keeps them while the user choice is not known yet', () async {
    final probe = _Probe();

    probe.manager.captureException('session failed');
    await probe.receiveConfiguration(reportingAllowed: true);

    expect(probe.sent, isEmpty);

    await probe.receiveConsent(null);

    expect(probe.sent, ['session failed']);
  });

  test('drops them when the user opted out on an instance that reports by default',
      () async {
    final probe = _Probe();

    probe.manager.captureException('session failed');
    await probe.receiveConfiguration(reportingAllowed: true);
    await probe.receiveConsent(false);
    await probe.receiveConsent(true);

    expect(probe.sent, isEmpty);
  });

  test('drops them without sending when reporting is not allowed', () async {
    final probe = _Probe();

    probe.manager.captureException('session failed');
    await probe.receiveConfigurationAndConsent(reportingAllowed: false);
    await probe.receiveConsent(true);

    expect(probe.sent, isEmpty);
  });

  test('drops them when the instance turns Sentry off', () async {
    final probe = _Probe();

    probe.manager.captureException('session failed');
    probe.manager.discardPendingReports();
    await probe.receiveConfigurationAndConsent(reportingAllowed: true);

    expect(probe.sent, isEmpty);
  });

  List<String> sentAfterDecidingLate(Duration delay) {
    late List<String> sent;
    fakeAsync((async) {
      final probe = _Probe();
      var decided = false;

      probe.manager.captureException('session failed');
      async.elapse(delay);
      probe
          .receiveConfigurationAndConsent(reportingAllowed: true)
          .then((_) => decided = true);
      async.elapse(const Duration(seconds: 1));

      expect(decided, isTrue);
      sent = probe.sent;
    });
    return sent;
  }

  test('still sends them when the decision comes within five minutes', () {
    expect(sentAfterDecidingLate(const Duration(minutes: 4)), ['session failed']);
  });

  test('drops them five minutes after the first one when nothing is decided', () {
    expect(sentAfterDecidingLate(const Duration(minutes: 5)), isEmpty);
  });

  test('drops them past the deadline even when the expiry timer has not run yet',
      () async {
    var now = DateTime(2026, 11, 21, 8);
    final probe = _Probe(now: () => now);

    probe.manager.captureException('session failed');
    now = now.add(const Duration(minutes: 6));
    await probe.receiveConfigurationAndConsent(reportingAllowed: true);

    expect(probe.sent, isEmpty);
  });

  test('keeps at most the first 20 errors', () async {
    final probe = _Probe();

    for (var i = 0; i < 25; i++) {
      probe.manager.captureException('error $i');
    }
    await probe.receiveConfigurationAndConsent(reportingAllowed: true);

    expect(probe.sent, List.generate(20, (i) => 'error $i'));
  });

  test('drops them when the session ends', () async {
    final probe = _Probe();

    probe.manager.captureException('previous account error');
    await probe.manager.clearSessionContext();
    await probe.receiveConfigurationAndConsent(reportingAllowed: true);

    expect(probe.sent, isEmpty);
  });

  test('waits for the new user choice after the session ends', () async {
    final probe = _Probe();

    await probe.receiveConfigurationAndConsent(reportingAllowed: true);
    await probe.manager.clearSessionContext();
    probe.manager.suspendSentryReporting();
    probe.manager.captureException('new account error');
    await probe.receiveConfiguration(reportingAllowed: true);

    expect(probe.sent, isEmpty);

    await probe.receiveConsent(null);

    expect(probe.sent, ['new account error']);
  });

  test('drops them and keeps nothing new once the user refused, even before the configuration',
      () async {
    final probe = _Probe();

    probe.manager.captureException('before refusal');
    await probe.receiveConsent(false);
    probe.manager.captureException('during refusal');
    await probe.receiveConsent(true);
    await probe.receiveConfiguration(reportingAllowed: true);

    expect(probe.sent, isEmpty);
  });

  test('holds the reports of a running SDK until the user choice is read',
      () async {
    final probe = _Probe();

    await probe.receiveConfiguration(reportingAllowed: true);
    probe.manager.captureException('before the user choice');

    expect(probe.sent, isEmpty);

    await probe.receiveConsent(false);

    expect(probe.sent, isEmpty);
  });

  test('sends them once the scope update that the user choice started is done',
      () async {
    final probe = _Probe(scopeSyncDelay: const Duration(milliseconds: 20));

    await probe.receiveConfiguration(reportingAllowed: true);
    probe.manager.captureException('before the user choice');
    await probe.receiveConsent(null);

    expect(probe.sent, ['before the user choice']);
  });

  test('sends nothing twice', () async {
    final probe = _Probe();

    probe.manager.captureException('session failed');
    await probe.receiveConfigurationAndConsent(reportingAllowed: true);
    await probe.receiveConfigurationAndConsent(reportingAllowed: true);

    expect(probe.sent, ['session failed']);
  });
}
