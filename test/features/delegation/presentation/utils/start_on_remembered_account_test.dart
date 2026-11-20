import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmail_ui_user/features/delegation/data/datasource/last_shown_account_store_impl.dart';
import 'package:tmail_ui_user/features/delegation/domain/repository/last_shown_account_store.dart';
import 'package:tmail_ui_user/features/delegation/presentation/model/account_switch_result.dart';
import 'package:tmail_ui_user/features/delegation/presentation/model/account_switch_state.dart';
import 'package:tmail_ui_user/features/delegation/presentation/model/account_switch_view.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/account_switch_notifier.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/active_account_notifier.dart';
import 'package:tmail_ui_user/features/delegation/presentation/providers/account_switch_view_factory_provider.dart';
import 'package:tmail_ui_user/features/delegation/presentation/providers/last_shown_account_providers.dart';
import 'package:tmail_ui_user/features/delegation/presentation/utils/start_on_remembered_account.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations_delegate.dart';
import 'package:tmail_ui_user/main/providers/app_toast_provider.dart';
import 'package:tmail_ui_user/main/providers/cozy/inside_cozy_provider.dart';

import '../../../../fixtures/delegation_fixtures.dart';
import '../../../../fixtures/recording_app_toast.dart';

class _FakeSwitchView implements AccountSwitchView {
  _FakeSwitchView({this.hasOpenComposer = false});

  @override
  final bool hasOpenComposer;

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

/// Selects the target on success like the real switch, so the recorder sees it.
class _RecordingSwitchNotifier extends AccountSwitchNotifier {
  final List<AccountId> switchToCalls = [];
  AccountSwitchResult nextResult = const AccountSwitched();

  @override
  AccountSwitchState build() => const AccountSwitchIdle();

  @override
  Future<AccountSwitchResult> switchTo(
    AccountId targetAccountId,
    AccountSwitchView view,
  ) async {
    switchToCalls.add(targetAccountId);
    if (nextResult is AccountSwitched) {
      ref.read(activeAccountProvider.notifier).select(targetAccountId);
    }
    return nextResult;
  }
}

void main() {
  final alice = UserName(DelegationFixtures.aliceAddress);
  late _RecordingSwitchNotifier switchNotifier;
  late RecordingAppToast appToast;
  late LastShownAccountStore store;
  late ProviderContainer container;
  late bool accountShown;
  var composerOpen = false;

  setUp(() async {
    composerOpen = false;
    switchNotifier = _RecordingSwitchNotifier();
    appToast = RecordingAppToast();
    SharedPreferences.setMockInitialValues({});
    store = LastShownAccountStoreImpl(await SharedPreferences.getInstance());
  });

  /// Pumps an app on mine, as after the session read of a start, and runs the start.
  Future<AppLocalizations> start(
    WidgetTester tester, {
    bool launchedByNotification = false,
    bool firstLoadFailed = false,
    AccountId? chosenBeforeStart,
  }) async {
    container = ProviderContainer(
      overrides: [
        accountSwitchProvider.overrideWith(() => switchNotifier),
        accountSwitchViewFactoryProvider.overrideWithValue((_) => _FakeSwitchView(hasOpenComposer: composerOpen)),
        appToastProvider.overrideWithValue(appToast.toast),
        insideCozyProvider.overrideWith((ref) async => false),
        lastShownAccountStoreProvider.overrideWithValue(store),
      ],
    );
    addTearDown(container.dispose);
    container
        .read(activeAccountProvider.notifier)
        .applySession(DelegationFixtures.session());
    DelegationFixtures.turnDelegationOn(container);
    if (chosenBeforeStart != null) container.read(activeAccountProvider.notifier).select(chosenBeforeStart);

    late BuildContext context;
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

    recordShownAccounts(context);
    accountShown = await startOnRememberedAccount(
      context,
      launchedByNotification: launchedByNotification,
      firstLoadFailed: firstLoadFailed,
    );
    return AppLocalizations.of(context);
  }

  testWidgets('starts on the remembered account and keeps it remembered', (tester) async {
    await store.save(alice, DelegationFixtures.bobAccountId);

    await start(tester);

    expect(switchNotifier.switchToCalls, [DelegationFixtures.bobAccountId]);
    expect(container.read(activeAccountProvider)?.accountId, DelegationFixtures.bobAccountId);
    expect(store.read(alice), DelegationFixtures.bobAccountId);
    expect(accountShown, isTrue);
    expect(appToast.warningMessages, isEmpty);
    expect(appToast.errorMessages, isEmpty);
  });

  testWidgets('should not switch on a start from a notification tap and forgets the account', (tester) async {
    await store.save(alice, DelegationFixtures.bobAccountId);

    await start(tester, launchedByNotification: true);

    expect(switchNotifier.switchToCalls, isEmpty);
    expect(accountShown, isFalse);
    expect(store.read(alice), isNull);
    expect(appToast.warningMessages, isEmpty);
  });

  testWidgets('should not switch while an intent composer is open and forgets the account', (tester) async {
    await store.save(alice, DelegationFixtures.bobAccountId);
    composerOpen = true;

    await start(tester);

    expect(switchNotifier.switchToCalls, isEmpty);
    expect(store.read(alice), isNull);
    expect(appToast.warningMessages, isEmpty);
  });

  testWidgets('should not switch when the first folder load failed and keeps the account for the next start', (tester) async {
    await store.save(alice, DelegationFixtures.bobAccountId);

    await start(tester, firstLoadFailed: true);

    expect(switchNotifier.switchToCalls, isEmpty);
    expect(accountShown, isFalse);
    expect(store.read(alice), DelegationFixtures.bobAccountId);
    expect(appToast.errorMessages, isEmpty);
  });

  testWidgets('should not switch when no account is remembered', (tester) async {
    await start(tester);

    expect(switchNotifier.switchToCalls, isEmpty);
    expect(appToast.warningMessages, isEmpty);
  });

  testWidgets('stays on mine with the unavailable toast and forgets a refused account', (tester) async {
    await store.save(alice, DelegationFixtures.unknownAccountId);
    switchNotifier.nextResult =
        const AccountSwitchRefused(AccountSwitchRefusal.accountNotListed);

    final l10n = await start(tester);

    expect(switchNotifier.switchToCalls, [DelegationFixtures.unknownAccountId]);
    expect(container.read(activeAccountProvider)?.isDelegated, isFalse);
    expect(store.read(alice), isNull);
    expect(accountShown, isFalse);
    expect(appToast.warningMessages, [l10n.delegatedMailboxUnavailable]);
  });

  testWidgets('stays on mine with the error toast and forgets an account whose load failed', (tester) async {
    await store.save(alice, DelegationFixtures.bobAccountId);
    switchNotifier.nextResult = const AccountSwitchTimedOut();

    final l10n = await start(tester);

    expect(store.read(alice), isNull);
    expect(appToast.errorMessages, [l10n.couldNotOpenOwnerMailbox(DelegationFixtures.bobAddress)]);
  });

  testWidgets('records later switches once the start has read the entry', (tester) async {
    await start(tester);

    container.read(activeAccountProvider.notifier).select(DelegationFixtures.carolAccountId);

    expect(store.read(alice), DelegationFixtures.carolAccountId);
  });

  testWidgets('should not switch away from an account chosen before the start and remembers it', (tester) async {
    await store.save(alice, DelegationFixtures.bobAccountId);

    await start(tester, chosenBeforeStart: DelegationFixtures.carolAccountId);

    expect(switchNotifier.switchToCalls, isEmpty);
    expect(accountShown, isFalse);
    expect(container.read(activeAccountProvider)?.accountId, DelegationFixtures.carolAccountId);
    expect(store.read(alice), DelegationFixtures.carolAccountId);
    expect(appToast.warningMessages, isEmpty);
  });
}
