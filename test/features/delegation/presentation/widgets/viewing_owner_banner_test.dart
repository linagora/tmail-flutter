import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:tmail_ui_user/features/delegation/presentation/model/account_switch_result.dart';
import 'package:tmail_ui_user/features/delegation/presentation/model/account_switch_state.dart';
import 'package:tmail_ui_user/features/delegation/presentation/model/account_switch_view.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/account_switch_notifier.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/active_account_notifier.dart';
import 'package:tmail_ui_user/features/delegation/presentation/providers/account_switch_view_factory_provider.dart';
import 'package:tmail_ui_user/features/delegation/presentation/widgets/viewing_owner_banner.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/delegation_config.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/preferences_setting.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations_delegate.dart';
import 'package:tmail_ui_user/main/localizations/localization_service.dart';
import 'package:tmail_ui_user/main/providers/app_toast_provider.dart';
import 'package:tmail_ui_user/main/providers/settings/local_settings_notifier.dart';

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

Widget _app(ProviderContainer container) {
  return UncontrolledProviderScope(
    container: container,
    child: const MaterialApp(
      localizationsDelegates: [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: LocalizationService.supportedLocales,
      locale: LocalizationService.defaultLocale,
      home: Scaffold(body: ViewingOwnerBanner()),
    ),
  );
}

void main() {
  late ProviderContainer container;
  late _RecordingSwitchNotifier switchNotifier;
  late RecordingAppToast appToast;

  setUp(() {
    switchNotifier = _RecordingSwitchNotifier();
    appToast = RecordingAppToast();
    container = ProviderContainer(
      overrides: [
        accountSwitchProvider.overrideWith(() => switchNotifier),
        accountSwitchViewFactoryProvider
            .overrideWithValue((_) => _FakeSwitchView()),
        appToastProvider.overrideWithValue(appToast.toast),
      ],
    );
    addTearDown(container.dispose);
  });

  testWidgets('hides when showing mine', (tester) async {
    container
        .read(activeAccountProvider.notifier)
        .applySession(DelegationFixtures.session());
    DelegationFixtures.turnDelegationOn(container);

    await tester.pumpWidget(_app(container));
    await tester.pump();

    expect(find.byKey(ViewingOwnerBanner.bannerKey), findsNothing);
  });

  testWidgets('shows the owner address while a delegated mailbox is active',
      (tester) async {
    container
        .read(activeAccountProvider.notifier)
        .applySession(DelegationFixtures.session());
    DelegationFixtures.turnDelegationOn(container);
    container
        .read(activeAccountProvider.notifier)
        .select(DelegationFixtures.bobAccountId);

    await tester.pumpWidget(_app(container));
    await tester.pump();

    final label =
        AppLocalizations().viewingOwnerMailbox(DelegationFixtures.bobAddress);
    expect(find.byKey(ViewingOwnerBanner.bannerKey), findsOneWidget);
    expect(find.text(label), findsOneWidget);
    expect(find.byKey(ViewingOwnerBanner.dismissKey), findsOneWidget);
  });

  testWidgets(
      'hides when delegation is off even while a delegated mailbox is active',
      (tester) async {
    container
        .read(activeAccountProvider.notifier)
        .applySession(DelegationFixtures.session());
    DelegationFixtures.turnDelegationOn(container);
    container
        .read(activeAccountProvider.notifier)
        .select(DelegationFixtures.bobAccountId);
    container.read(localSettingsProvider.notifier).update(
          PreferencesSetting([DelegationConfig(isEnabled: false)]),
        );

    await tester.pumpWidget(_app(container));
    await tester.pump();

    expect(find.byKey(ViewingOwnerBanner.bannerKey), findsNothing);
  });

  testWidgets('dismiss calls switchTo(mine)', (tester) async {
    container
        .read(activeAccountProvider.notifier)
        .applySession(DelegationFixtures.session());
    DelegationFixtures.turnDelegationOn(container);
    container
        .read(activeAccountProvider.notifier)
        .select(DelegationFixtures.bobAccountId);

    await tester.pumpWidget(_app(container));
    await tester.pump();
    await tester.tap(find.byKey(ViewingOwnerBanner.dismissKey));
    await tester.pumpAndSettle();

    expect(switchNotifier.switchToCalls, [DelegationFixtures.aliceAccountId]);
  });

  testWidgets('dismiss failure toasts return-to-mine copy', (tester) async {
    switchNotifier.nextResult = const AccountSwitchCancelled();
    container
        .read(activeAccountProvider.notifier)
        .applySession(DelegationFixtures.session());
    DelegationFixtures.turnDelegationOn(container);
    container
        .read(activeAccountProvider.notifier)
        .select(DelegationFixtures.bobAccountId);

    await tester.pumpWidget(_app(container));
    await tester.pump();
    await tester.tap(find.byKey(ViewingOwnerBanner.dismissKey));
    await tester.pumpAndSettle();

    expect(
      appToast.errorMessages,
      [AppLocalizations().couldNotReturnToYourMailbox],
    );
  });
}
