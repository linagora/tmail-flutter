import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linagora_design_flutter/linagora_design_flutter.dart';
import 'package:tmail_ui_user/features/delegation/presentation/model/account_switch_result.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/account_switch_notifier.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/active_account_notifier.dart';
import 'package:tmail_ui_user/features/delegation/presentation/providers/account_switch_view_factory_provider.dart';
import 'package:tmail_ui_user/features/delegation/presentation/widgets/compact_account_switcher.dart';
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
    container.read(activeAccountProvider.notifier).applySession(DelegationFixtures.session());
    DelegationFixtures.turnDelegationOn(container);
  });

  Future<void> selectBobFromTheSwitcher(WidgetTester tester) async {
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(
        localizationsDelegates: [AppLocalizationsDelegate()],
        supportedLocales: LocalizationService.supportedLocales,
        locale: LocalizationService.defaultLocale,
        home: Scaffold(body: CompactAccountSwitcher()),
      ),
    ));
    await tester.pump();

    await tester.tap(find.byKey(LinagoraAccountSwitcher.chipKey));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(LinagoraAccountMenu.itemKey(DelegationFixtures.bobAccountId)));
    await tester.pumpAndSettle();
  }

  testWidgets('selecting a delegated account switches to it', (tester) async {
    await selectBobFromTheSwitcher(tester);

    expect(switchNotifier.switchToCalls, [DelegationFixtures.bobAccountId]);
    expect(appToast.errorMessages, isEmpty);
  });

  testWidgets('a failed switch from the switcher toasts the owner', (tester) async {
    switchNotifier.nextResult = const AccountSwitchTimedOut();

    await selectBobFromTheSwitcher(tester);

    expect(
      appToast.errorMessages,
      [AppLocalizations().couldNotOpenOwnerMailbox(DelegationFixtures.bobAddress)],
    );
  });
}
