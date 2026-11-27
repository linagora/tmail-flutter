import 'dart:async';
import 'dart:io';

import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/foundation.dart';
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

/// A cold start from a delegated notification tap: the session-load restore and the tap's own
/// restore both meet the delegated draft. Each draft must open in one composer only.
void main() {
  final mine = DelegationFixtures.aliceAccountId;
  final bob = DelegationFixtures.bobAccountId;
  late Directory hiveDir;
  late _RestoringDashboard dashboard;
  late _GatedSwitchView view;

  setUpAll(() async {
    hiveDir = await Directory.systemTemp.createTemp('composer_restore_tap_start');
    await HiveCacheConfig.instance.setUp(cachePath: hiveDir.path);
  });

  tearDownAll(() async => hiveDir.delete(recursive: true));

  setUp(() async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    final session = DelegationFixtures.session();
    dashboard = _RestoringDashboard()
      ..activeAccountId = mine
      ..session = session;
    view = _GatedSwitchView();
    // The app was killed while a draft of the delegated mailbox was open.
    await appProviderContainer
        .read(composerCacheRepositoryProvider)
        .saveComposerCache(
          bob,
          session.username,
          ComposerPersistentCache(
            email: Email(subject: 'delegated draft'),
            composerId: 'delegated-composer',
            timestampMs: DateTime.now().millisecondsSinceEpoch,
          ),
        );
    DelegationFixtures.turnDelegationOn(appProviderContainer);
    appProviderContainer.read(activeAccountProvider.notifier).applySession(session);
  });

  tearDown(() async {
    debugDefaultTargetPlatformOverride = null;
    appProviderContainer.read(accountSwitchProvider.notifier).endSession();
    await appProviderContainer
        .read(composerCacheRepositoryProvider)
        .removeAllComposerCache(bob, DelegationFixtures.session().username);
  });

  /// What _handleNotificationMessageFromEmailId does once showNotificationAccount returns true.
  Future<void> endTapSwitchAndRestore(Future<AccountSwitchResult> switching) async {
    view.load.complete();
    expect(await switching, isA<AccountSwitched>());
    await dashboard.checkAndRestoreComposerOnMobile(onlyDelegated: true);
  }

  test(
    'reopens the delegated draft once when the tap switch starts while the session-load restore reads mine',
    () async {
      late Future<AccountSwitchResult> switching;
      dashboard.onCacheLookup = () {
        dashboard.onCacheLookup = null;
        // The tap read from the platform channel starts its switch now.
        switching = appProviderContainer.read(accountSwitchProvider.notifier).switchTo(bob, view);
        dashboard.activeAccountId = bob;
      };
      final sessionLoadRestore = dashboard.checkAndRestoreComposerOnMobile();
      await pumpEventQueue();

      await endTapSwitchAndRestore(switching);
      await sessionLoadRestore;

      expect(dashboard.composerOpenedOn, [bob], reason: 'one composer for one draft');
    },
  );

  test('reopens the delegated draft once when the session-load restore starts during the tap switch', () async {
    final switching = appProviderContainer.read(accountSwitchProvider.notifier).switchTo(bob, view);
    await pumpEventQueue();
    dashboard.activeAccountId = bob;
    final sessionLoadRestore = dashboard.checkAndRestoreComposerOnMobile();
    await pumpEventQueue();

    await endTapSwitchAndRestore(switching);
    await sessionLoadRestore;

    expect(dashboard.composerOpenedOn, [bob], reason: 'one composer for one draft');
  });

  test('control: the tap restore alone reopens the delegated draft once', () async {
    final switching = appProviderContainer.read(accountSwitchProvider.notifier).switchTo(bob, view);
    await pumpEventQueue();
    dashboard.activeAccountId = bob;

    await endTapSwitchAndRestore(switching);

    expect(dashboard.composerOpenedOn, [bob]);
  });
}
