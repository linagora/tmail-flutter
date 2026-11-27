import 'dart:async';
import 'dart:io';

import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/caching/config/hive_cache_config.dart';
import 'package:tmail_ui_user/features/delegation/presentation/model/account_switch_result.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';
import 'package:tmail_ui_user/features/delegation/presentation/model/account_switch_view.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/account_switch_notifier.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/active_account_notifier.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/model/composer_persistent_cache.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/handle_composer_restore_on_mobile_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/providers/composer_cache_data_providers.dart';
import 'package:tmail_ui_user/main/providers/app_provider_container.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';

import '../../../../fixtures/delegation_fixtures.dart';

/// A switch view whose account load waits for [load], with a composer that can open meanwhile.
class _GatedSwitchView implements AccountSwitchView {
  final load = Completer<void>();

  @override
  bool hasOpenComposer = false;

  @override
  Future<int> closeComposers() async => 0;

  @override
  void blockInput() {}

  @override
  void unblockInput() {}

  @override
  void clearSelectionAndSearch() {}

  @override
  Future<void> loadAccount(account, int switchAttemptId) => load.future;

  @override
  void catchUpAccount(account, int switchAttemptId) {}
}

/// The dashboard as the composer restore reads it. openComposer reads the identities first,
/// so that read records which account was shown when the restored composer opened.
class _RestoringDashboard extends Mock implements MailboxDashBoardController {
  @override
  AccountId? activeAccountId;

  Session? session;

  int cacheLookups = 0;

  /// Runs when the restore reads the session to look up the shown account's draft.
  void Function()? onCacheLookup;

  @override
  Session? get sessionCurrent {
    cacheLookups++;
    onCacheLookup?.call();
    return session;
  }

  final List<AccountId?> composerOpenedOn = [];

  /// Lets the restore reach the composer route of a test app.
  bool routeToComposer = false;

  @override
  final ResponsiveUtils responsiveUtils = ResponsiveUtils();

  @override
  List<Identity> get listIdentities {
    composerOpenedOn.add(activeAccountId);
    if (routeToComposer) return [];
    // Stops before the composer route, which needs a running app.
    throw StateError('composer opened');
  }
}

void main() {
  final mine = DelegationFixtures.aliceAccountId;
  final bob = DelegationFixtures.bobAccountId;

  group('a delegated notification tap at cold start while my draft is being restored', () {
    test('the switch SHOULD NOT end on the delegated mailbox when a composer opened during its load', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      DelegationFixtures.turnDelegationOn(container);
      container.read(activeAccountProvider.notifier).applySession(DelegationFixtures.session());
      final view = _GatedSwitchView();

      final switching = container.read(accountSwitchProvider.notifier).switchTo(bob, view);
      await pumpEventQueue();
      expect(container.read(activeAccountProvider)!.accountId, bob,
          reason: 'the target is already shown while its account loads');

      // The composer restore finishes now and opens my draft.
      view.hasOpenComposer = true;
      view.load.complete();
      final result = await switching;

      expect(result, isNot(isA<AccountSwitched>()));
      expect(container.read(activeAccountProvider)!.accountId, mine);
    });

    group('the composer restore', () {
      late Directory hiveDir;
      late _RestoringDashboard dashboard;

      setUpAll(() async {
        hiveDir = await Directory.systemTemp.createTemp('composer_restore_race');
        await HiveCacheConfig.instance.setUp(cachePath: hiveDir.path);
      });

      tearDownAll(() async => hiveDir.delete(recursive: true));

      setUp(() async {
        debugDefaultTargetPlatformOverride = TargetPlatform.android;
        final session = DelegationFixtures.session();
        dashboard = _RestoringDashboard()
          ..activeAccountId = mine
          ..session = session;
        await appProviderContainer.read(composerCacheRepositoryProvider).saveComposerCache(
              mine,
              session.username,
              ComposerPersistentCache(
                email: Email(subject: 'my draft'),
                composerId: 'my-composer',
                timestampMs: DateTime.now().millisecondsSinceEpoch,
              ),
            );
      });

      tearDown(() => debugDefaultTargetPlatformOverride = null);

      test('control: reopens my draft on my mailbox', () async {
        await dashboard.checkAndRestoreComposerOnMobile();

        expect(dashboard.composerOpenedOn, [mine]);
      });

      group('restoring only a delegated draft at the end of a start', () {
        setUp(() => appProviderContainer.read(composerCacheRepositoryProvider).saveComposerCache(
              bob,
              DelegationFixtures.session().username,
              ComposerPersistentCache(
                email: Email(subject: 'delegated draft'),
                composerId: 'delegated-composer',
                timestampMs: DateTime.now().millisecondsSinceEpoch,
              ),
            ));

        tearDown(() => appProviderContainer
            .read(composerCacheRepositoryProvider)
            .removeAllComposerCache(bob, DelegationFixtures.session().username));

        test('SHOULD NOT reopen my draft again on my mailbox', () async {
          await dashboard.checkAndRestoreComposerOnMobile(onlyDelegated: true);

          expect(dashboard.composerOpenedOn, isEmpty);
        });

        test('reopens the draft of the shown delegated mailbox', () async {
          dashboard.activeAccountId = bob;

          await dashboard.checkAndRestoreComposerOnMobile(onlyDelegated: true);

          expect(dashboard.composerOpenedOn, [bob]);
        });
      });

      test('SHOULD NOT open my draft once the delegated mailbox of the tap is shown', () async {
        final restoring = dashboard.checkAndRestoreComposerOnMobile();
        // The tap's switch selects Bob while the restore reads its cache.
        dashboard.activeAccountId = bob;
        await restoring;

        expect(dashboard.composerOpenedOn, isNot(contains(bob)),
            reason: 'my draft would compose with the identities of the shown delegated mailbox');
      });

      test('SHOULD NOT open my draft when the shown account changes while my draft is read', () async {
        dashboard.onCacheLookup = () {
          dashboard.onCacheLookup = null;
          dashboard.activeAccountId = bob;
        };

        await dashboard.checkAndRestoreComposerOnMobile();

        expect(dashboard.composerOpenedOn, isEmpty);
      });

      group('while the tap switch loads the delegated mailbox', () {
        late _GatedSwitchView view;
        late Future<AccountSwitchResult> switching;

        setUp(() async {
          DelegationFixtures.turnDelegationOn(appProviderContainer);
          appProviderContainer.read(activeAccountProvider.notifier).applySession(DelegationFixtures.session());
          view = _GatedSwitchView();
          switching = appProviderContainer.read(accountSwitchProvider.notifier).switchTo(bob, view);
          await pumpEventQueue();
          dashboard.activeAccountId = bob;
        });

        tearDown(() => appProviderContainer.read(accountSwitchProvider.notifier).endSession());

        test('SHOULD NOT look up a draft before the switch ends', () async {
          unawaited(dashboard.checkAndRestoreComposerOnMobile());
          await pumpEventQueue();

          expect(dashboard.cacheLookups, 0);
          expect(dashboard.composerOpenedOn, isEmpty);
          view.load.complete();
          await switching;
        });

        test('reopens my draft on my mailbox once the switch falls back to it', () async {
          final restoring = dashboard.checkAndRestoreComposerOnMobile();
          await pumpEventQueue();
          dashboard.activeAccountId = mine;
          view.load.completeError(StateError('folders failed'));

          expect(await switching, isA<AccountSwitchFailed>());
          await restoring;
          expect(dashboard.composerOpenedOn, [mine]);
        });

        test('SHOULD NOT open my draft when the switch ends on the delegated mailbox', () async {
          final restoring = dashboard.checkAndRestoreComposerOnMobile();
          await pumpEventQueue();
          view.load.complete();

          expect(await switching, isA<AccountSwitched>());
          await restoring;
          expect(dashboard.composerOpenedOn, isEmpty);
        });
      });

      testWidgets('opens my draft in my account, so a later switch cannot move it to the delegated mailbox', (tester) async {
        tester.view.physicalSize = const Size(400, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        addTearDown(Get.reset);
        ComposerArguments? openedWith;
        await tester.pumpWidget(GetMaterialApp(
          initialRoute: '/',
          getPages: [
            GetPage(name: '/', page: () => const SizedBox()),
            GetPage(name: AppRoutes.composer, page: () {
              openedWith = Get.arguments as ComposerArguments;
              return const SizedBox();
            }),
          ],
        ));
        dashboard.routeToComposer = true;

        try {
          await tester.runAsync(dashboard.checkAndRestoreComposerOnMobile);
          await tester.pumpAndSettle();

          expect(openedWith?.accountId, mine);
        } finally {
          debugDefaultTargetPlatformOverride = null;
        }
      });
    });
  });
}
