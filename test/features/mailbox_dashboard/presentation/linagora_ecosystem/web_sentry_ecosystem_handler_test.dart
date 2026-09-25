import 'package:core/utils/sentry/sentry_config.dart';
import 'package:core/utils/sentry/sentry_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/linagora_ecosystem.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/linagora_ecosystem/web_sentry_ecosystem_handler.dart';

void main() {
  late SentryManager sentryManager;
  late WebSentryEcosystemHandler handler;

  setUp(() async {
    sentryManager = SentryManager.forTesting(
      isSentryAvailable: false,
      synchronizeScope: (_, {required clearBreadcrumbs}) async {},
      initializeSentrySdk: ({appRunner, sentryConfig}) async => true,
      closeSentrySdk: () async {},
    );
    await sentryManager.initializeWithSentryConfig(SentryConfig(
      dsn: 'https://env@sentry.io/123',
      environment: 'test',
      release: '1.0.0',
      isAvailable: true,
      isReportingAllowed: true,
    ));
    handler = WebSentryEcosystemHandler(sentryManager: sentryManager);
  });

  test('applies only the ecosystem reporting default', () async {
    handler.onEcosystemLoaded(LinagoraEcosystem.deserialize({
      'sentry': {
        'enabled': true,
        'userOptInByDefault': false,
      },
    }));
    await sentryManager.pendingLifecycleTransition;

    expect(sentryManager.isSentryConfigured, isTrue);
    expect(sentryManager.isSentryReportingAllowed, isFalse);
    expect(sentryManager.isSentryAvailable, isFalse);
  });

  test('suspends reporting when the ecosystem becomes unavailable', () async {
    handler.onEcosystemCleared();
    await sentryManager.pendingLifecycleTransition;

    expect(sentryManager.isSentryReportingAllowed, isTrue);
    expect(sentryManager.isSentryAvailable, isFalse);
    expect(sentryManager.isSentryReportingReady, isFalse);
  });

  test('defaults to denied when the loaded ecosystem has no Sentry config',
      () async {
    handler.onEcosystemLoaded(LinagoraEcosystem.deserialize({
      'sentry': {
        'enabled': true,
        'userOptInByDefault': false,
      },
    }));
    handler.onEcosystemCleared();

    handler.onEcosystemLoaded(LinagoraEcosystem.deserialize({
      'paywallUrlTemplate': 'https://domain.tld/premium',
    }));
    await sentryManager.pendingLifecycleTransition;

    expect(sentryManager.isSentryReportingAllowed, isFalse);
    expect(sentryManager.isSentryAvailable, isFalse);
    expect(sentryManager.isSentryReportingReady, isFalse);
  });

  final missingEcosystemDefaultCases = <({
    String description,
    bool? serverConsent,
    bool expectedReportingState,
  })>[
    (
      description: 'defaults to denied when userOptInByDefault is absent',
      serverConsent: null,
      expectedReportingState: false,
    ),
    (
      description: 'keeps server opt-in when userOptInByDefault is absent',
      serverConsent: true,
      expectedReportingState: true,
    ),
  ];

  for (final testCase in missingEcosystemDefaultCases) {
    test(testCase.description, () async {
      sentryManager.setSentryReportingConsent(testCase.serverConsent);
      handler.onEcosystemLoaded(LinagoraEcosystem.deserialize({
        'sentry': {
          'enabled': true,
        },
      }));
      await sentryManager.pendingLifecycleTransition;

      expect(
        sentryManager.isSentryReportingAllowed,
        testCase.expectedReportingState,
      );
      expect(
        sentryManager.isSentryAvailable,
        testCase.expectedReportingState,
      );
    });
  }

  test('keeps explicit user consent above the ecosystem default', () async {
    sentryManager.setSentryReportingConsent(true);

    handler.onEcosystemLoaded(LinagoraEcosystem.deserialize({
      'sentry': {
        'enabled': true,
        'userOptInByDefault': false,
      },
    }));
    await sentryManager.pendingLifecycleTransition;

    expect(sentryManager.isSentryReportingAllowed, isTrue);
  });

  test('resets server consent when the account changes', () async {
    handler.onEcosystemLoaded(LinagoraEcosystem.deserialize({
      'sentry': {
        'enabled': true,
        'userOptInByDefault': false,
      },
    }));
    sentryManager.setSentryReportingConsent(true);
    await sentryManager.pendingLifecycleTransition;

    handler.onAccountChanged();
    await sentryManager.pendingLifecycleTransition;

    expect(sentryManager.isSentryReportingAllowed, isFalse);
  });
}
