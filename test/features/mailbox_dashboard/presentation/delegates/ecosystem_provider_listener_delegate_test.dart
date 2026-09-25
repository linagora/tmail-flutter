import 'package:core/data/network/config/dynamic_url_interceptors.dart';
import 'package:core/utils/platform_info.dart';
import 'package:core/utils/sentry/sentry_config.dart';
import 'package:core/utils/sentry/sentry_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/linagora_ecosystem.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/linagora_ecosystem_handler.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/sentry_config_linagora_ecosystem.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/delegates/ecosystem_provider_listener_delegate.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/linagora_ecosystem/linagora_ecosystem_handler_registry.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/linagora_ecosystem/web_sentry_ecosystem_handler.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/providers/active_ecosystem_provider.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/riverpod_widgets/mailbox_dashboard_provider_listener_widget.dart';
import 'package:tmail_ui_user/features/paywall/presentation/providers/premium_cta_provider.dart';

mockControllerCallback() => InternalFinalCallback<void>(callback: () {});

class _DashboardController extends Mock
    implements MailboxDashBoardController {
  final testAccountId = Rxn<AccountId>();
  int setUpSentryCount = 0;
  int clearSentryCount = 0;

  @override
  final DynamicUrlInterceptors dynamicUrlInterceptors =
      DynamicUrlInterceptors()..setJmapUrl('https://jmap.domain.tld');

  @override
  InternalFinalCallback<void> get onStart => mockControllerCallback();

  @override
  InternalFinalCallback<void> get onDelete => mockControllerCallback();

  @override
  Rxn<AccountId> get accountId => testAccountId;

  @override
  Future<void> setUpSentry(
    SentryConfigLinagoraEcosystem ecosystemConfig,
  ) async {
    setUpSentryCount++;
  }

  @override
  Future<void> clearSentry() async {
    clearSentryCount++;
  }
}

class _EcosystemStateNotifier extends Notifier<EcosystemState> {
  @override
  EcosystemState build() => const EcosystemLoading();

  void setState(EcosystemState value) {
    state = value;
  }
}

class _RecordingEcosystemHandler implements LinagoraEcosystemHandler {
  final loaded = <LinagoraEcosystem>[];
  int clearedCount = 0;

  @override
  void onEcosystemLoaded(LinagoraEcosystem ecosystem) {
    loaded.add(ecosystem);
  }

  @override
  void onEcosystemCleared() {
    clearedCount++;
  }
}

final _ecosystemStateProvider =
    NotifierProvider<_EcosystemStateNotifier, EcosystemState>(
  _EcosystemStateNotifier.new,
);

void main() {
  testWidgets(
    'dispatches shared ecosystem state and cleans up account listener',
    (tester) async {
      Get.testMode = true;
      addTearDown(Get.reset);
      final dashboardController = _DashboardController();
      dashboardController.testAccountId.value = AccountId(Id('first'));
      final registry = LinagoraEcosystemHandlerRegistry();
      final recordingHandler = _RecordingEcosystemHandler();
      registry.register(recordingHandler);
      Get.put<MailboxDashBoardController>(dashboardController);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            linagoraEcosystemHandlerRegistryProvider.overrideWithValue(registry),
            activeEcosystemProvider.overrideWith(
              (ref, _) => ref.watch(_ecosystemStateProvider),
            ),
          ],
          child: const MaterialApp(
            home: MailboxDashboardProviderListenerWidget(
              delegateFactories: [EcosystemProviderListenerDelegate.new],
              child: SizedBox(),
            ),
          ),
        ),
      );
      final container = ProviderScope.containerOf(
        tester.element(find.byType(MailboxDashboardProviderListenerWidget)),
      );
      final ecosystem = LinagoraEcosystem.deserialize({
        'paywallUrlTemplate': 'https://domain.tld/premium',
      });

      expect(recordingHandler.clearedCount, 1);
      container
          .read(_ecosystemStateProvider.notifier)
          .setState(EcosystemAvailable(ecosystem));
      await tester.pump();

      expect(recordingHandler.loaded, [ecosystem]);

      dashboardController.testAccountId.value = AccountId(Id('second'));
      await tester.pump();

      expect(recordingHandler.clearedCount, 2);
      expect(recordingHandler.loaded, [ecosystem, ecosystem]);

      // Disposal clears the shared registry so the ecosystem of this session
      // cannot leak into the next one...
      await tester.pumpWidget(const SizedBox());

      expect(recordingHandler.clearedCount, 3);

      // ...and nothing is dispatched after disposal.
      dashboardController.testAccountId.value = AccountId(Id('third'));
      await tester.pump();

      expect(recordingHandler.clearedCount, 3);
      expect(recordingHandler.loaded, [ecosystem, ecosystem]);
    },
  );

  testWidgets(
    'ecosystem handlers resolve the current dashboard controller',
    (tester) async {
      Get.testMode = true;
      addTearDown(Get.reset);
      final firstController = _DashboardController();
      firstController.testAccountId.value = AccountId(Id('first'));
      final registry = LinagoraEcosystemHandlerRegistry();
      Get.put<MailboxDashBoardController>(firstController);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            linagoraEcosystemHandlerRegistryProvider.overrideWithValue(registry),
            activeEcosystemProvider.overrideWith(
              (ref, _) => ref.watch(_ecosystemStateProvider),
            ),
          ],
          child: const MaterialApp(
            home: MailboxDashboardProviderListenerWidget(
              delegateFactories: [EcosystemProviderListenerDelegate.new],
              child: SizedBox(),
            ),
          ),
        ),
      );

      final secondController = _DashboardController();
      secondController.testAccountId.value = AccountId(Id('second'));
      Get.delete<MailboxDashBoardController>(force: true);
      Get.put<MailboxDashBoardController>(secondController);

      registry.dispatchLoaded(LinagoraEcosystem.deserialize({
        'sentry': {'enabled': false},
      }));
      await tester.pump();

      registry.dispatchCleared();
      await tester.pump();

      registry.dispatchLoaded(LinagoraEcosystem.deserialize({
        'paywallUrlTemplate': 'https://domain.tld/premium',
      }));
      await tester.pump();

      expect(firstController.setUpSentryCount, 0);
      expect(secondController.setUpSentryCount, 1);
      expect(secondController.clearSentryCount, 2);
    },
  );

  testWidgets(
    'registers the web Sentry handler without invoking non-web setup',
    (tester) async {
      PlatformInfo.isTestingForWeb = true;
      final sentryManager = SentryManager.instance
        ..resumeSentryReporting()
        ..setSentryReportingConsent(null)
        ..setSentryReportingDefault(true)
        ..clearSentryReportingDefault();
      addTearDown(() {
        PlatformInfo.isTestingForWeb = false;
        sentryManager
          ..resumeSentryReporting()
          ..setSentryReportingConsent(null)
          ..setSentryReportingDefault(true);
      });
      final dashboardController = _registerDashboardController('first');
      final registry = LinagoraEcosystemHandlerRegistry();

      await _pumpDelegate(tester, registry);

      registry.dispatchLoaded(LinagoraEcosystem.deserialize({
        'sentry': {
          'enabled': true,
          'userOptInByDefault': false,
        },
      }));
      await sentryManager.pendingLifecycleTransition;

      expect(sentryManager.isSentryReportingAllowed, isFalse);

      registry.dispatchLoaded(LinagoraEcosystem.deserialize({
        'paywallUrlTemplate': 'https://domain.tld/premium',
      }));
      await sentryManager.pendingLifecycleTransition;

      expect(sentryManager.isSentryReportingAllowed, isFalse);

      registry.dispatchCleared();
      await sentryManager.pendingLifecycleTransition;

      expect(sentryManager.isSentryReportingReady, isFalse);
      expect(dashboardController.setUpSentryCount, 0);
      expect(dashboardController.clearSentryCount, 0);
    },
  );

  testWidgets(
    'does not carry server Sentry consent to another account',
    (tester) async {
      final sentryManager = SentryManager.forTesting(
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
        isReportingAllowed: false,
      ));
      final dashboardController = _registerDashboardController('first');
      final registry = LinagoraEcosystemHandlerRegistry()
        ..register(WebSentryEcosystemHandler(sentryManager: sentryManager));
      final ecosystem = LinagoraEcosystem.deserialize({
        'sentry': {
          'enabled': true,
          'userOptInByDefault': false,
        },
      });

      await _pumpDelegate(tester, registry);
      registry.dispatchLoaded(ecosystem);
      sentryManager.setSentryReportingConsent(true);
      await sentryManager.pendingLifecycleTransition;

      expect(sentryManager.isSentryReportingAllowed, isTrue);

      dashboardController.testAccountId.value = AccountId(Id('second'));
      await tester.pump();
      registry.dispatchLoaded(ecosystem);
      await sentryManager.pendingLifecycleTransition;

      expect(sentryManager.isSentryReportingAllowed, isFalse);
    },
  );

  // The unavailable arm is what stops a failed or unconfigured ecosystem from
  // leaving stale data live in the app-lifetime registry.
  testWidgets(
    'clears handlers when the ecosystem becomes unavailable',
    (tester) async {
      final dashboardController = _registerDashboardController('first');
      final registry = LinagoraEcosystemHandlerRegistry();
      final recordingHandler = _RecordingEcosystemHandler();
      registry.register(recordingHandler);

      final container = await _pumpDelegate(tester, registry);
      final ecosystem = LinagoraEcosystem.deserialize({
        'paywallUrlTemplate': 'https://domain.tld/premium',
      });
      final notifier = container.read(_ecosystemStateProvider.notifier);

      notifier.setState(EcosystemAvailable(ecosystem));
      await tester.pump();

      expect(recordingHandler.loaded, [ecosystem]);

      notifier.setState(
        const EcosystemUnavailable(EcosystemUnavailableReason.loadFailed),
      );
      await tester.pump();

      // One clear from the initial subscribe, one from the unavailable state.
      expect(recordingHandler.clearedCount, 2);
      expect(recordingHandler.loaded, [ecosystem]);
      expect(dashboardController.setUpSentryCount, 0);
    },
  );

  testWidgets(
    'clears handlers when an available ecosystem starts reloading',
    (tester) async {
      _registerDashboardController('first');
      final registry = LinagoraEcosystemHandlerRegistry();
      final recordingHandler = _RecordingEcosystemHandler();
      registry.register(recordingHandler);

      final container = await _pumpDelegate(tester, registry);
      final notifier = container.read(_ecosystemStateProvider.notifier);
      notifier.setState(EcosystemAvailable(LinagoraEcosystem.deserialize({
        'paywallUrlTemplate': 'https://domain.tld/premium',
      })));
      await tester.pump();

      notifier.setState(const EcosystemLoading());
      await tester.pump();

      expect(recordingHandler.clearedCount, 2);
      expect(recordingHandler.loaded, hasLength(1));
    },
  );

  // Pins which ecosystem the delegate actually subscribes to: the signed-in
  // account paired with its JMAP URL, re-keyed whenever the account changes.
  testWidgets(
    'keys the ecosystem subscription on the account and JMAP URL',
    (tester) async {
      final dashboardController = _registerDashboardController('first');
      final registry = LinagoraEcosystemHandlerRegistry();
      registry.register(_RecordingEcosystemHandler());
      final observedKeys = <(AccountId?, String?)>[];

      await _pumpDelegate(tester, registry, observedKeys: observedKeys);

      final jmapUrl = dashboardController.dynamicUrlInterceptors.jmapUrl;
      expect(observedKeys, [(AccountId(Id('first')), jmapUrl)]);

      dashboardController.testAccountId.value = AccountId(Id('second'));
      await tester.pump();

      expect(observedKeys, [
        (AccountId(Id('first')), jmapUrl),
        (AccountId(Id('second')), jmapUrl),
      ]);
    },
  );

  testWidgets(
    'stays inert when no dashboard controller is registered',
    (tester) async {
      Get.testMode = true;
      addTearDown(Get.reset);
      final registry = LinagoraEcosystemHandlerRegistry();
      final recordingHandler = _RecordingEcosystemHandler();
      registry.register(recordingHandler);
      final observedKeys = <(AccountId?, String?)>[];

      await _pumpDelegate(tester, registry, observedKeys: observedKeys);
      await tester.pumpWidget(const SizedBox());

      expect(observedKeys, isEmpty);
      expect(recordingHandler.clearedCount, 0);
      expect(recordingHandler.loaded, isEmpty);
    },
  );

  // A registry that already holds handlers must not gain the default ones on
  // top, which would dispatch every ecosystem twice.
  testWidgets(
    'does not add default handlers to a populated registry',
    (tester) async {
      final dashboardController = _registerDashboardController('first');
      final registry = LinagoraEcosystemHandlerRegistry();
      final recordingHandler = _RecordingEcosystemHandler();
      registry.register(recordingHandler);

      final container = await _pumpDelegate(tester, registry);
      final ecosystem = LinagoraEcosystem.deserialize({
        'sentry': {'enabled': false},
      });
      container
          .read(_ecosystemStateProvider.notifier)
          .setState(EcosystemAvailable(ecosystem));
      await tester.pump();

      expect(recordingHandler.loaded, [ecosystem]);
      // The default non-web Sentry handler would have forwarded this config.
      expect(dashboardController.setUpSentryCount, 0);
    },
  );
}

_DashboardController _registerDashboardController(String accountId) {
  Get.testMode = true;
  addTearDown(Get.reset);
  final dashboardController = _DashboardController();
  dashboardController.testAccountId.value = AccountId(Id(accountId));
  Get.put<MailboxDashBoardController>(dashboardController);
  return dashboardController;
}

/// Mounts the delegate over [registry], recording into [observedKeys] the
/// ecosystem family arguments it subscribes with.
Future<ProviderContainer> _pumpDelegate(
  WidgetTester tester,
  LinagoraEcosystemHandlerRegistry registry, {
  List<(AccountId?, String?)>? observedKeys,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        linagoraEcosystemHandlerRegistryProvider.overrideWithValue(registry),
        activeEcosystemProvider.overrideWith((ref, args) {
          observedKeys?.add(args);
          return ref.watch(_ecosystemStateProvider);
        }),
      ],
      child: const MaterialApp(
        home: MailboxDashboardProviderListenerWidget(
          delegateFactories: [EcosystemProviderListenerDelegate.new],
          child: SizedBox(),
        ),
      ),
    ),
  );
  return ProviderScope.containerOf(
    tester.element(find.byType(MailboxDashboardProviderListenerWidget)),
  );
}
