import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/delegation/presentation/model/account_switch_result.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/account_switch_notifier.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/active_account_notifier.dart';
import 'package:tmail_ui_user/features/delegation/presentation/providers/account_switch_view_factory_provider.dart';
import 'package:tmail_ui_user/features/delegation/presentation/utils/show_mine_before_intent.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations_delegate.dart';
import 'package:tmail_ui_user/main/localizations/localization_service.dart';
import 'package:tmail_ui_user/main/providers/app_toast_provider.dart';

import '../../../../fixtures/account_switch_fakes.dart';
import '../../../../fixtures/delegation_fixtures.dart';
import '../../../../fixtures/recording_app_toast.dart';

void main() {
  late ProviderContainer container;
  late RecordingAccountSwitchNotifier switchNotifier;
  late RecordingAppToast appToast;

  setUp(() {
    switchNotifier = RecordingAccountSwitchNotifier();
    appToast = RecordingAppToast();
    container = ProviderContainer(
      overrides: [
        accountSwitchProvider.overrideWith(() => switchNotifier),
        accountSwitchViewFactoryProvider.overrideWithValue((_) => FakeAccountSwitchView()),
        appToastProvider.overrideWithValue(appToast.toast),
      ],
    );
    addTearDown(container.dispose);
  });

  void showMine() => container
      .read(activeAccountProvider.notifier)
      .applySession(DelegationFixtures.session());

  void showBob() {
    showMine();
    DelegationFixtures.turnDelegationOn(container);
    container.read(activeAccountProvider.notifier).select(DelegationFixtures.bobAccountId);
  }

  Future<bool> runShowMineBeforeIntent(WidgetTester tester) async {
    late BuildContext captured;
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        localizationsDelegates: const [AppLocalizationsDelegate()],
        supportedLocales: LocalizationService.supportedLocales,
        locale: LocalizationService.defaultLocale,
        home: Builder(builder: (context) {
          captured = context;
          return const SizedBox.shrink();
        }),
      ),
    ));
    await tester.pump();
    return showMineBeforeIntent(captured);
  }

  testWidgets('goes on without a switch while mine is shown', (tester) async {
    showMine();

    expect(await runShowMineBeforeIntent(tester), isTrue);
    expect(switchNotifier.switchToCalls, isEmpty);
    expect(appToast.errorMessages, isEmpty);
  });

  testWidgets('goes on without a switch before the session is loaded', (tester) async {
    expect(await runShowMineBeforeIntent(tester), isTrue);
    expect(switchNotifier.switchToCalls, isEmpty);
    expect(appToast.errorMessages, isEmpty);
  });

  testWidgets('switches a delegated account back to mine and goes on', (tester) async {
    showBob();

    expect(await runShowMineBeforeIntent(tester), isTrue);
    expect(switchNotifier.switchToCalls, [DelegationFixtures.aliceAccountId]);
    expect(appToast.errorMessages, isEmpty);
  });

  testWidgets('should not go on when an open composer refuses the switch', (tester) async {
    showBob();
    switchNotifier.nextResult = const AccountSwitchRefused(AccountSwitchRefusal.composerOpen);

    expect(await runShowMineBeforeIntent(tester), isFalse);
    expect(
      appToast.errorMessages,
      [AppLocalizations().closeComposerBeforeSwitchingAccounts],
    );
  });

  for (final result in <AccountSwitchResult>[
    const AccountSwitchRefused(AccountSwitchRefusal.switchInProgress),
    AccountSwitchFailed(Exception('load'), StackTrace.empty),
    const AccountSwitchCancelled(),
    const AccountSwitchTimedOut(),
  ]) {
    testWidgets('should not go on after $result and toasts', (tester) async {
      showBob();
      switchNotifier.nextResult = result;

      expect(await runShowMineBeforeIntent(tester), isFalse);
      expect(appToast.errorMessages, [AppLocalizations().couldNotReturnToYourMailbox]);
    });
  }
}
