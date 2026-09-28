import 'package:core/utils/sentry/sentry_config.dart';
import 'package:core/utils/sentry/sentry_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
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

  test(
    'clears the old account identity before applying a new ecosystem',
    () async {
      sentryManager.setUser(SentryUser(id: 'old-account'));
      sentryManager.setSentryReportingConsent(true);
      await sentryManager.pendingScopeSync;

      handler.onEcosystemCleared();
      handler.onAccountChanged();
      handler.onEcosystemLoaded(
        LinagoraEcosystem.deserialize({
          'sentry': {'enabled': true, 'userOptInByDefault': true},
        }),
      );
      await sentryManager.pendingLifecycleTransition;
      await sentryManager.pendingScopeSync;

      expect(sentryManager.userForScope, isNull);
    },
  );

  test(
    'env SDK starts only with consent and pauses during ecosystem reload',
    () async {
      final startedConfigs = <SentryConfig>[];
      var closes = 0;
      final manager = SentryManager.forTesting(
        isSentryAvailable: false,
        synchronizeScope: (_, {required clearBreadcrumbs}) async {},
        initializeSentrySdk: ({appRunner, sentryConfig}) async {
          startedConfigs.add(sentryConfig!);
          return true;
        },
        closeSentrySdk: () async {
          closes++;
        },
      );
      await manager.initializeWithSentryConfig(
        SentryConfig(
          dsn: 'https://env@sentry.io/123',
          environment: 'test',
          release: '1.0.0',
          isAvailable: true,
        ),
      );
      final webHandler = WebSentryEcosystemHandler(sentryManager: manager);
      manager.setUser(SentryUser(id: 'current-account'));
      await manager.pendingScopeSync;

      expect(startedConfigs, isEmpty);
      expect(manager.isSentryReportingAllowed, isFalse);

      webHandler.onEcosystemLoaded(
        LinagoraEcosystem.deserialize({
          'sentry': {'enabled': true, 'userOptInByDefault': true},
        }),
      );
      expect(manager.isSentryReportingAllowed, isTrue);
      await manager.pendingLifecycleTransition;
      await manager.pendingScopeSync;

      expect(startedConfigs, hasLength(1));
      expect(startedConfigs.single.dsn, 'https://env@sentry.io/123');
      expect(manager.userForScope?.id, 'current-account');

      manager.setSentryReportingConsent(false);
      await manager.pendingLifecycleTransition;

      expect(closes, 1);
      expect(manager.isSentryAvailable, isFalse);

      webHandler.onEcosystemCleared();
      await manager.pendingLifecycleTransition;
      webHandler.onEcosystemLoaded(
        LinagoraEcosystem.deserialize({
          'sentry': {'enabled': true, 'userOptInByDefault': true},
        }),
      );
      await manager.pendingLifecycleTransition;

      expect(
        startedConfigs,
        hasLength(1),
        reason: 'server opt-out still overrides the reloaded default',
      );

      manager.setSentryReportingConsent(null);
      await manager.pendingLifecycleTransition;

      expect(startedConfigs, hasLength(2));
      expect(manager.isSentryAvailable, isTrue);

      webHandler.onEcosystemCleared();
      await manager.pendingLifecycleTransition;

      expect(closes, 2);
      expect(manager.isSentryReportingAllowed, isTrue);
      expect(manager.isSentryReportingReady, isFalse);
      expect(manager.userForScope, isNull);

      webHandler.onEcosystemLoaded(
        LinagoraEcosystem.deserialize({
          'sentry': {'enabled': true, 'userOptInByDefault': true},
        }),
      );
      await manager.pendingLifecycleTransition;
      await manager.pendingScopeSync;

      expect(startedConfigs, hasLength(3));
      expect(manager.userForScope?.id, 'current-account');
    },
  );
}
