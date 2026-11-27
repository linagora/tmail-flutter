import 'dart:async';

import 'package:core/data/model/source_type/data_source_type.dart';
import 'package:fcm/model/type_name.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/delegation/presentation/model/account_switch_view.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/active_account_notifier.dart';
import 'package:tmail_ui_user/features/delegation/presentation/providers/account_switch_view_factory_provider.dart';
import 'package:tmail_ui_user/features/delegation/presentation/utils/show_notification_account.dart';
import 'package:tmail_ui_user/features/mailbox/data/datasource/mailbox_datasource.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/jmap_mailbox_response.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/delegates/delegated_notification_baseline_provider_listener_delegate.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/riverpod_widgets/mailbox_dashboard_provider_listener_widget.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/delegation_config.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/preferences_setting.dart';
import 'package:tmail_ui_user/features/push_notification/data/datasource/fcm_datasource.dart';
import 'package:tmail_ui_user/features/push_notification/data/keychain/keychain_delegated_account.dart';
import 'package:tmail_ui_user/features/push_notification/data/repository/fcm_repository_impl.dart';
import 'package:tmail_ui_user/features/push_notification/domain/exceptions/fcm_exception.dart';
import 'package:tmail_ui_user/features/push_notification/domain/repository/fcm_repository.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/store_delegated_notification_baselines_interactor.dart';
import 'package:tmail_ui_user/features/thread/data/datasource/thread_datasource.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations_delegate.dart';
import 'package:tmail_ui_user/main/providers/app_toast_provider.dart';
import 'package:tmail_ui_user/main/providers/settings/local_settings_notifier.dart';

import '../../../fixtures/delegation_fixtures.dart';
import '../../../fixtures/recording_app_toast.dart';

/// The push cursors (Android FCM cache) and the delegated keychain items (iOS) kept in memory.
/// The keychain write keeps a stored field the call sends as null, as IOSSharingManager does.
class _MemoryFcmCache implements FCMDatasource {
  final Map<String, jmap.State> cursors = {};
  final Map<AccountId, KeychainDelegatedAccount> keychain = {};
  final List<List<KeychainDelegatedAccount>> keychainWrites = [];

  String _key(AccountId accountId, TypeName typeName) => '${accountId.id.value}|$typeName';

  jmap.State? cursorOf(AccountId accountId) => cursors[_key(accountId, TypeName.emailDelivery)];

  @override
  Future<void> storeStateToRefresh(AccountId accountId, UserName userName, TypeName typeName, jmap.State newState) async {
    cursors[_key(accountId, typeName)] = newState;
  }

  @override
  Future<jmap.State> getStateToRefresh(AccountId accountId, UserName userName, TypeName typeName) async {
    final state = cursors[_key(accountId, typeName)];
    if (state != null) return state;
    if (typeName == TypeName.emailDelivery) throw const NotFoundEmailDeliveryStateException();
    throw const NotFoundStateToRefreshException();
  }

  @override
  Future<void> deleteStateToRefresh(AccountId accountId, UserName userName, TypeName typeName) async {
    cursors.remove(_key(accountId, typeName));
  }

  @override
  Future<List<KeychainDelegatedAccount>> getDelegatedAccountsInKeychain(AccountId accountId) async =>
      keychain.values.toList();

  @override
  Future<void> storeDelegatedAccountsInKeychain(AccountId accountId, List<KeychainDelegatedAccount> delegatedAccounts) async {
    keychainWrites.add(delegatedAccounts);
    final stored = Map.of(keychain);
    keychain
      ..clear()
      ..addEntries(delegatedAccounts.map((account) => MapEntry(
            account.accountId,
            KeychainDelegatedAccount(
              accountId: account.accountId,
              emailDeliveryState: account.emailDeliveryState ?? stored[account.accountId]?.emailDeliveryState,
              mailboxIdsBlockNotification:
                  account.mailboxIdsBlockNotification ?? stored[account.accountId]?.mailboxIdsBlockNotification,
              ownerName: account.ownerName,
            ),
          )));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// The current Email state the server answers, held back by [gate] when set.
class _ServerStates implements ThreadDataSource {
  final Map<AccountId, jmap.State> states;
  Completer<void>? gate;
  final List<AccountId> reads = [];

  _ServerStates(this.states);

  @override
  Future<jmap.State?> getEmailState(Session session, AccountId accountId) async {
    reads.add(accountId);
    if (gate != null) await gate!.future;
    return states[accountId];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final _inbox = Mailbox(id: MailboxId(Id('inbox-id')), role: PresentationMailbox.roleInbox);
final _spam = Mailbox(id: MailboxId(Id('spam-id')), role: PresentationMailbox.roleSpam);

/// No cached mailbox of a delegated account, the server list readable once [readable] is set.
class _Mailboxes implements MailboxDataSource {
  bool readable = true;

  _Mailboxes();

  @override
  Future<List<Mailbox>> getAllMailboxCache(AccountId accountId, UserName userName) async => [];

  @override
  Future<JmapMailboxResponse> getAllMailbox(Session session, AccountId accountId, {properties}) async {
    if (!readable) throw Exception('offline');
    return JmapMailboxResponse(mailboxes: [_inbox, _spam]);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeSwitchView implements AccountSwitchView {
  @override
  bool get hasOpenComposer => false;

  @override
  Future<int> closeComposers() async => 0;

  @override
  void blockInput() {}

  @override
  void unblockInput() {}

  @override
  void clearSelectionAndSearch() {}

  @override
  Future<void> loadAccount(account, int switchAttemptId) async {}

  @override
  void catchUpAccount(account, int switchAttemptId) {}
}

void main() {
  final android = TargetPlatformVariant.only(TargetPlatform.android);
  final ios = TargetPlatformVariant.only(TargetPlatform.iOS);
  final bob = DelegationFixtures.bobAccountId;
  final carol = DelegationFixtures.carolAccountId;
  final bobAndCarol = {
    bob: DelegationFixtures.bobAddress,
    carol: DelegationFixtures.carolAddress,
  };

  late _MemoryFcmCache cache;
  late _ServerStates server;
  late _Mailboxes mailboxes;
  late FCMRepository repository;

  setUp(() {
    cache = _MemoryFcmCache();
    server = _ServerStates({bob: jmap.State('bob-S9'), carol: jmap.State('carol-S9')});
    mailboxes = _Mailboxes();
    repository = FCMRepositoryImpl(
      {DataSourceType.local: cache},
      server,
      {DataSourceType.local: mailboxes, DataSourceType.network: mailboxes},
    );
  });

  /// The production store: the baseline interactor over the real repository.
  Future<bool> realStore(Session session, Map<AccountId, String> ownerNames) async {
    final result = await StoreDelegatedNotificationBaselinesInteractor(repository).execute(session, ownerNames).last;
    return result.isRight();
  }

  Future<ProviderContainer> pumpDelegate(WidgetTester tester, StoreDelegatedNotificationBaselines store) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: MailboxDashboardProviderListenerWidget(
            delegateFactories: [() => DelegatedNotificationBaselineProviderListenerDelegate(store: store)],
            child: const SizedBox(),
          ),
        ),
      ),
    );
    return ProviderScope.containerOf(tester.element(find.byType(SizedBox)));
  }

  /// The dashboard applies the session it got from the login, the saved settings are still loading.
  Future<void> showSession(WidgetTester tester, ProviderContainer container, Session session) async {
    container.read(activeAccountProvider.notifier).applySession(session);
    await tester.pump();
  }

  /// LocalSettingsService finishes reading the saved settings: delegation is on.
  Future<void> loadSavedSettings(WidgetTester tester, ProviderContainer container) async {
    container
        .read(localSettingsProvider.notifier)
        .update(PreferencesSetting([DelegationConfig(isEnabled: true)]));
    await tester.pump();
  }

  group('cold start before the saved settings load', () {
    testWidgets('SHOULD NOT store an empty delegated list first', (tester) async {
      final stored = <Map<AccountId, String>>[];
      final container = await pumpDelegate(tester, (session, ownerNames) async {
        stored.add(ownerNames);
        return true;
      });

      await showSession(tester, container, DelegationFixtures.session());
      await loadSavedSettings(tester, container);

      expect(stored, [bobAndCarol]);
    }, variant: android);

    Future<void> startWithMovedCursors(WidgetTester tester, {required bool settingsFirst}) async {
      final session = DelegationFixtures.session();
      await cache.storeStateToRefresh(bob, session.username, TypeName.emailDelivery, jmap.State('bob-S5'));
      await cache.storeStateToRefresh(carol, session.username, TypeName.emailDelivery, jmap.State('carol-S5'));
      final container = await pumpDelegate(tester, realStore);
      if (settingsFirst) await loadSavedSettings(tester, container);
      await showSession(tester, container, session);
      if (!settingsFirst) await loadSavedSettings(tester, container);
      await tester.pump();
    }

    testWidgets('on Android SHOULD keep the cursor the pushes already moved', (tester) async {
      await startWithMovedCursors(tester, settingsFirst: false);

      expect(cache.cursorOf(bob), jmap.State('bob-S5'));
      expect(cache.cursorOf(carol), jmap.State('carol-S5'));
      expect(server.reads, isEmpty, reason: 'a kept cursor needs no new server state');
    }, variant: android);

    testWidgets('control: on Android the cursors stay when the settings load first', (tester) async {
      await startWithMovedCursors(tester, settingsFirst: true);

      expect(cache.cursorOf(bob), jmap.State('bob-S5'));
      expect(cache.cursorOf(carol), jmap.State('carol-S5'));
      expect(server.reads, isEmpty);
    }, variant: android);

    testWidgets('on iOS SHOULD NOT clear the delegated keychain items the NSE reads', (tester) async {
      cache.keychain[bob] = KeychainDelegatedAccount(
        accountId: bob,
        emailDeliveryState: 'bob-S5',
        mailboxIdsBlockNotification: [_spam.id!],
        ownerName: DelegationFixtures.bobAddress,
      );
      final container = await pumpDelegate(tester, realStore);

      await showSession(tester, container, DelegationFixtures.session(listsCarol: false));
      await loadSavedSettings(tester, container);
      await tester.pump();

      expect(cache.keychainWrites.where((items) => items.isEmpty), isEmpty,
          reason: 'an empty list leaves the NSE without the delegated mailbox until the next write');
      expect(cache.keychain[bob]?.emailDeliveryState, 'bob-S5');
    }, variant: ios);

    /// Taps a notification of Bob with the real account switch, returns whether it opens and the warnings shown.
    Future<(bool, List<String>)> tapBobNotification(WidgetTester tester, {required bool settingsLoaded}) async {
      final appToast = RecordingAppToast();
      final container = ProviderContainer(overrides: [
        accountSwitchViewFactoryProvider.overrideWithValue((_) => _FakeSwitchView()),
        appToastProvider.overrideWithValue(appToast.toast),
      ]);
      addTearDown(container.dispose);
      if (settingsLoaded) DelegationFixtures.turnDelegationOn(container);
      container.read(activeAccountProvider.notifier).applySession(DelegationFixtures.session());
      BuildContext? context;
      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: const [AppLocalizationsDelegate()],
          home: Builder(builder: (ctx) {
            context = ctx;
            return const SizedBox.shrink();
          }),
        ),
      ));
      await tester.pump();

      final tap = showNotificationAccount(context: context!, notificationAccountId: bob);
      // LocalSettingsService finishes reading the saved settings while the tap waits.
      if (!settingsLoaded) DelegationFixtures.turnDelegationOn(container);
      final shown = await tap;
      return (shown, appToast.warningMessages);
    }

    testWidgets('a notification tap of a delegated mailbox SHOULD open in that mailbox', (tester) async {
      final (shown, warnings) = await tapBobNotification(tester, settingsLoaded: false);

      expect(warnings, isEmpty);
      expect(shown, isTrue);
    }, variant: android);

    testWidgets('control: the same tap opens once the settings are loaded', (tester) async {
      final (shown, warnings) = await tapBobNotification(tester, settingsLoaded: true);

      expect(warnings, isEmpty);
      expect(shown, isTrue);
    }, variant: android);
  });

  testWidgets('on iOS SHOULD write the blocked mailboxes once they can be read', (tester) async {
    mailboxes.readable = false;
    final container = await pumpDelegate(tester, realStore);
    await loadSavedSettings(tester, container);
    await showSession(tester, container, DelegationFixtures.session(listsCarol: false));
    await tester.pump();
    expect(cache.keychain[bob]?.mailboxIdsBlockNotification, isNull);

    mailboxes.readable = true;
    await showSession(tester, container, DelegationFixtures.session(listsCarol: false, state: 'state-2'));
    await tester.pump();

    expect(cache.keychain[bob]?.mailboxIdsBlockNotification, [_spam.id!],
        reason: 'without it the NSE notifies the Spam and Trash of the delegated mailbox');
  }, variant: ios);

  test('on Android a baseline SHOULD NOT overwrite a newer cursor a push stored meanwhile', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    final session = DelegationFixtures.session(listsCarol: false);
    server
      ..states[bob] = jmap.State('bob-S1')
      ..gate = Completer<void>();

    final baseline = StoreDelegatedNotificationBaselinesInteractor(repository)
        .execute(session, {bob: DelegationFixtures.bobAddress})
        .last;
    while (server.reads.isEmpty) {
      await Future<void>.delayed(Duration.zero);
    }
    // The background FCM isolate notifies a new email and moves the cursor.
    await cache.storeStateToRefresh(bob, session.username, TypeName.emailDelivery, jmap.State('bob-S2'));
    server.gate!.complete();
    await baseline;

    expect(cache.cursorOf(bob), jmap.State('bob-S2'));
    expect(await repository.getStateToRefresh(bob, session.username, TypeName.emailDelivery), jmap.State('bob-S2'));
  });

  test('on Android a cursor a push stores after the baseline SHOULD win over it', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    final session = DelegationFixtures.session(listsCarol: false);
    server.states[bob] = jmap.State('bob-S1');

    await StoreDelegatedNotificationBaselinesInteractor(repository)
        .execute(session, {bob: DelegationFixtures.bobAddress})
        .last;
    final beforePush = await repository.getStateToRefresh(bob, session.username, TypeName.emailDelivery);
    await repository.storeStateToRefresh(bob, session.username, TypeName.emailDelivery, jmap.State('bob-S2'));

    expect(beforePush, jmap.State('bob-S1'));
    expect(await repository.getStateToRefresh(bob, session.username, TypeName.emailDelivery), jmap.State('bob-S2'));
  });

  test('on Android a mailbox no longer notified SHOULD drop its baseline too', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    final session = DelegationFixtures.session(listsCarol: false);
    server.states[bob] = jmap.State('bob-S1');
    await StoreDelegatedNotificationBaselinesInteractor(repository)
        .execute(session, {bob: DelegationFixtures.bobAddress})
        .last;

    await StoreDelegatedNotificationBaselinesInteractor(repository).execute(session, {}).last;

    expect(
      () => repository.getStateToRefresh(bob, session.username, TypeName.emailDelivery),
      throwsA(isA<NotFoundEmailDeliveryStateException>()),
    );
  });
}
