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
import 'package:tmail_ui_user/features/delegation/presentation/utils/start_on_url_account.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations_delegate.dart';
import 'package:tmail_ui_user/main/providers/app_toast_provider.dart';
import 'package:tmail_ui_user/main/providers/cozy/inside_cozy_provider.dart';

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
    AccountSwitchView view,
  ) async {
    switchToCalls.add(targetAccountId);
    return nextResult;
  }
}

void main() {
  late _RecordingSwitchNotifier switchNotifier;
  late RecordingAppToast appToast;
  late bool insideCozy;

  setUp(() {
    switchNotifier = _RecordingSwitchNotifier();
    appToast = RecordingAppToast();
    insideCozy = false;
  });

  /// Pumps an app on mine and runs the start toward [urlAccountId], returning its result and l10n.
  Future<(bool, AppLocalizations)> start(
    WidgetTester tester,
    AccountId urlAccountId,
  ) async {
    final container = ProviderContainer(
      overrides: [
        accountSwitchProvider.overrideWith(() => switchNotifier),
        accountSwitchViewFactoryProvider.overrideWithValue((_) => _FakeSwitchView()),
        appToastProvider.overrideWithValue(appToast.toast),
        insideCozyProvider.overrideWith((ref) async => insideCozy),
      ],
    );
    addTearDown(container.dispose);
    container
        .read(activeAccountProvider.notifier)
        .applySession(DelegationFixtures.session());
    DelegationFixtures.turnDelegationOn(container);

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

    final shown = await startOnUrlAccount(context: context, urlAccountId: urlAccountId);
    return (shown, AppLocalizations.of(context));
  }

  testWidgets('shows the URL account through a switch without a toast', (tester) async {
    final (shown, _) = await start(tester, DelegationFixtures.bobAccountId);

    expect(shown, isTrue);
    expect(switchNotifier.switchToCalls, [DelegationFixtures.bobAccountId]);
    expect(appToast.warningMessages, isEmpty);
    expect(appToast.errorMessages, isEmpty);
  });

  testWidgets('keeps mine with the unavailable toast when the switch is refused', (tester) async {
    switchNotifier.nextResult =
        const AccountSwitchRefused(AccountSwitchRefusal.accountNotListed);

    final (shown, l10n) = await start(tester, DelegationFixtures.unknownAccountId);

    expect(shown, isFalse);
    expect(appToast.warningMessages, [l10n.delegatedMailboxUnavailable]);
    expect(appToast.errorMessages, isEmpty);
  });

  testWidgets('keeps mine with the close composer toast when a composer is open', (tester) async {
    switchNotifier.nextResult =
        const AccountSwitchRefused(AccountSwitchRefusal.composerOpen);

    final (shown, l10n) = await start(tester, DelegationFixtures.bobAccountId);

    expect(shown, isFalse);
    expect(appToast.errorMessages, [l10n.closeComposerBeforeSwitchingAccounts]);
    expect(appToast.warningMessages, isEmpty);
  });

  testWidgets('keeps mine with the owner error toast when the switch fails', (tester) async {
    switchNotifier.nextResult = AccountSwitchFailed(Exception('load'), StackTrace.empty);

    final (shown, l10n) = await start(tester, DelegationFixtures.bobAccountId);

    expect(shown, isFalse);
    expect(appToast.errorMessages, [l10n.couldNotOpenOwnerMailbox(DelegationFixtures.bobAddress)]);
    expect(appToast.warningMessages, isEmpty);
  });

  testWidgets('names an account the session does not list by its id', (tester) async {
    switchNotifier.nextResult = const AccountSwitchTimedOut();

    final (shown, l10n) = await start(tester, DelegationFixtures.unknownAccountId);

    expect(shown, isFalse);
    expect(
      appToast.errorMessages,
      [l10n.couldNotOpenOwnerMailbox(DelegationFixtures.unknownAccountId.id.value)],
    );
  });

  testWidgets('should not switch inside Cozy and keeps mine with the unavailable toast', (tester) async {
    insideCozy = true;

    final (shown, l10n) = await start(tester, DelegationFixtures.bobAccountId);

    expect(shown, isFalse);
    expect(switchNotifier.switchToCalls, isEmpty);
    expect(appToast.warningMessages, [l10n.delegatedMailboxUnavailable]);
  });
}
