import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:tmail_ui_user/features/delegation/presentation/model/account_switch_result.dart';
import 'package:tmail_ui_user/features/delegation/presentation/model/account_switch_state.dart';
import 'package:tmail_ui_user/features/delegation/presentation/model/account_switch_view.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/account_switch_notifier.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/active_account_notifier.dart';
import 'package:tmail_ui_user/features/delegation/presentation/providers/account_switch_view_factory_provider.dart';
import 'package:tmail_ui_user/features/delegation/presentation/utils/show_notification_account.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations_delegate.dart';
import 'package:tmail_ui_user/main/providers/app_toast_provider.dart';

import '../../../../fixtures/delegation_fixtures.dart';
import '../../../../fixtures/recording_app_toast.dart';

class _FakeSwitchView implements AccountSwitchView {
  @override
  bool get hasOpenComposer => false;

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

class _RecordingSwitchNotifier extends AccountSwitchNotifier {
  final List<AccountId> switchToCalls = [];
  AccountSwitchResult nextResult = const AccountSwitched();

  @override
  AccountSwitchState build() => const AccountSwitchIdle();

  @override
  Future<AccountSwitchResult> switchTo(
    AccountId targetAccountId,
    AccountSwitchView view, {
    bool closesOpenComposer = false,
  }) async {
    switchToCalls.add(targetAccountId);
    return nextResult;
  }
}

void main() {
  late _RecordingSwitchNotifier switchNotifier;
  late RecordingAppToast appToast;

  setUp(() {
    switchNotifier = _RecordingSwitchNotifier();
    appToast = RecordingAppToast();
  });

  /// Pumps an app showing [shownAccountId] (mine when null, none when [showsAccount] is false) and taps
  /// a notification of [notificationAccountId].
  Future<(bool, AppLocalizations)> tap(
    WidgetTester tester,
    AccountId? notificationAccountId, {
    AccountId? shownAccountId,
    bool showsAccount = true,
  }) async {
    final container = ProviderContainer(
      overrides: [
        accountSwitchProvider.overrideWith(() => switchNotifier),
        accountSwitchViewFactoryProvider.overrideWithValue((_) => _FakeSwitchView()),
        appToastProvider.overrideWithValue(appToast.toast),
      ],
    );
    addTearDown(container.dispose);
    DelegationFixtures.turnDelegationOn(container);
    if (showsAccount) {
      container.read(activeAccountProvider.notifier).applySession(DelegationFixtures.session());
    }
    if (shownAccountId != null) {
      container.read(activeAccountProvider.notifier).select(shownAccountId);
    }

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

    final shown = await showNotificationAccount(context: context, notificationAccountId: notificationAccountId);
    return (shown, AppLocalizations.of(context));
  }

  testWidgets('opens a notification of mine on mine without a switch', (tester) async {
    final (shown, _) = await tap(tester, null);

    expect(shown, isTrue);
    expect(switchNotifier.switchToCalls, isEmpty);
  });

  testWidgets('opens a notification of the shown delegated account without a switch', (tester) async {
    final (shown, _) = await tap(
      tester,
      DelegationFixtures.bobAccountId,
      shownAccountId: DelegationFixtures.bobAccountId,
    );

    expect(shown, isTrue);
    expect(switchNotifier.switchToCalls, isEmpty);
  });

  testWidgets('switches to the delegated account of the notification', (tester) async {
    final (shown, _) = await tap(tester, DelegationFixtures.bobAccountId);

    expect(shown, isTrue);
    expect(switchNotifier.switchToCalls, [DelegationFixtures.bobAccountId]);
    expect(appToast.warningMessages, isEmpty);
    expect(appToast.errorMessages, isEmpty);
  });

  testWidgets('switches back to mine for a notification of mine while a delegated account is shown', (tester) async {
    final (shown, _) = await tap(tester, null, shownAccountId: DelegationFixtures.bobAccountId);

    expect(shown, isTrue);
    expect(switchNotifier.switchToCalls, [DelegationFixtures.aliceAccountId]);
  });

  testWidgets('drops the tap with the close composer toast while a composer is open', (tester) async {
    switchNotifier.nextResult = const AccountSwitchRefused(AccountSwitchRefusal.composerOpen);

    final (shown, l10n) = await tap(tester, DelegationFixtures.bobAccountId);

    expect(shown, isFalse);
    expect(appToast.errorMessages, [l10n.closeComposerBeforeSwitchingAccounts]);
    expect(appToast.warningMessages, isEmpty);
  });

  testWidgets('drops the tap with the unavailable toast for an account no longer listed', (tester) async {
    switchNotifier.nextResult = const AccountSwitchRefused(AccountSwitchRefusal.accountNotListed);

    final (shown, l10n) = await tap(tester, DelegationFixtures.unknownAccountId);

    expect(shown, isFalse);
    expect(appToast.warningMessages, [l10n.delegatedMailboxUnavailable]);
  });

  testWidgets('opens a notification of mine before any account is shown', (tester) async {
    final (shown, _) = await tap(tester, null, showsAccount: false);

    expect(shown, isTrue);
    expect(switchNotifier.switchToCalls, isEmpty);
  });

  testWidgets('SHOULD NOT open a delegated notification before any account is shown', (tester) async {
    final (shown, _) = await tap(tester, DelegationFixtures.bobAccountId, showsAccount: false);

    expect(shown, isFalse);
    expect(switchNotifier.switchToCalls, isEmpty);
  });
}
