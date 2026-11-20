import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/caching/config/hive_cache_config.dart';
import 'package:tmail_ui_user/features/delegation/presentation/model/account_switch_result.dart';
import 'package:tmail_ui_user/features/delegation/presentation/model/account_switch_view.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/account_switch_notifier.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/active_account_notifier.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/model/composer_persistent_cache.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/handle_composer_restore_on_mobile_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/providers/composer_cache_data_providers.dart';
import 'package:tmail_ui_user/main/providers/app_provider_container.dart';

import '../../../../fixtures/delegation_fixtures.dart';

/// A switch view whose account load waits for [load], with a composer that can open meanwhile.
class _GatedSwitchView implements AccountSwitchView {
  final load = Completer<void>();

  @override
  bool hasOpenComposer = false;

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

  @override
  Session? sessionCurrent;

  final List<AccountId?> composerOpenedOn = [];

  @override
  List<Identity> get listIdentities {
    composerOpenedOn.add(activeAccountId);
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
          ..sessionCurrent = session;
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

      test('SHOULD NOT open my draft once the delegated mailbox of the tap is shown', () async {
        final restoring = dashboard.checkAndRestoreComposerOnMobile();
        // The tap's switch selects Bob while the restore reads its cache.
        dashboard.activeAccountId = bob;
        await restoring;

        expect(dashboard.composerOpenedOn, isNot(contains(bob)),
            reason: 'my draft would compose with the identities of the shown delegated mailbox');
      });
    });
  });
}
