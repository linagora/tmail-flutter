import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:linagora_design_flutter/linagora_design_flutter.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';
import 'package:tmail_ui_user/features/delegation/presentation/model/account_switch_result.dart';
import 'package:tmail_ui_user/features/delegation/presentation/model/account_switch_state.dart';
import 'package:tmail_ui_user/features/delegation/presentation/model/account_switch_view.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/account_switch_notifier.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/active_account_notifier.dart';
import 'package:tmail_ui_user/features/delegation/presentation/providers/account_switch_view_factory_provider.dart';
import 'package:tmail_ui_user/features/delegation/presentation/widgets/standalone_account_avatar_menu.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/profile_setting/profile_setting_action_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/profile_setting/profile_setting_icon.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations_delegate.dart';
import 'package:tmail_ui_user/main/localizations/localization_service.dart';
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
    AccountSwitchView view,
  ) async {
    switchToCalls.add(targetAccountId);
    return nextResult;
  }
}

Widget _app(ProviderContainer container, {required Widget child}) {
  return UncontrolledProviderScope(
    container: container,
    child: Portal(
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: LocalizationService.supportedLocales,
        locale: LocalizationService.defaultLocale,
        // Anchor top-right so the portal menu stays on-screen (LTR opens leftward).
        home: Scaffold(
          body: Align(alignment: Alignment.topRight, child: child),
        ),
      ),
    ),
  );
}

StandaloneAccountAvatarMenu _menu({
  List<ProfileSettingActionType>? settingActionTypes,
}) =>
    StandaloneAccountAvatarMenu(
      ownEmailAddress: DelegationFixtures.aliceAddress,
      settingActionTypes: settingActionTypes ??
          ProfileSettingActionType.shown(canOpenSettings: true),
      onProfileSettingActionTypeClick: (_) {},
    );

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

  testWidgets('falls back to the profile menu when delegation is off',
      (tester) async {
    container
        .read(activeAccountProvider.notifier)
        .applySession(DelegationFixtures.session());

    await tester.pumpWidget(_app(container, child: _menu()));
    await tester.pump();

    expect(find.byType(ProfileSettingIcon), findsOneWidget);
    expect(find.byKey(const ValueKey(UiKeys.accountSwitcherMenu)), findsNothing);
  });

  testWidgets('opens the account menu with mine and delegated rows',
      (tester) async {
    container
        .read(activeAccountProvider.notifier)
        .applySession(DelegationFixtures.session());
    DelegationFixtures.turnDelegationOn(container);

    await tester.pumpWidget(_app(container, child: _menu()));
    await tester.pump();

    expect(find.byType(ProfileSettingIcon), findsNothing);
    await tester.tap(find.byKey(const ValueKey(UiKeys.userAvatar)));
    await tester.pumpAndSettle();

    final l10n = AppLocalizations();
    expect(find.byKey(const ValueKey(UiKeys.accountSwitcherMenu)), findsOneWidget);
    expect(find.text(l10n.yourMailbox), findsOneWidget);
    expect(find.text(l10n.delegatedToYou), findsOneWidget);
    expect(
      find.byKey(LinagoraAccountMenu.itemKey(DelegationFixtures.bobAccountId)),
      findsOneWidget,
    );
    expect(find.text(DelegationFixtures.bobAddress), findsOneWidget);
    expect(find.byKey(LinagoraAccountMenuActions.manageKey), findsOneWidget);
    expect(find.byKey(LinagoraAccountMenuActions.signOutKey), findsOneWidget);
  });

  testWidgets('hides Manage and keeps Sign out while a delegated mailbox is shown',
      (tester) async {
    container
        .read(activeAccountProvider.notifier)
        .applySession(DelegationFixtures.session());
    DelegationFixtures.turnDelegationOn(container);
    container
        .read(activeAccountProvider.notifier)
        .select(DelegationFixtures.bobAccountId);

    await tester.pumpWidget(
      _app(
        container,
        child: _menu(
          settingActionTypes:
              ProfileSettingActionType.shown(canOpenSettings: false),
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey(UiKeys.userAvatar)));
    await tester.pumpAndSettle();

    final l10n = AppLocalizations();
    expect(find.text(l10n.manage_account), findsNothing);
    expect(find.byKey(LinagoraAccountMenuActions.manageKey), findsNothing);
    expect(find.byKey(LinagoraAccountMenuActions.signOutKey), findsOneWidget);
    expect(find.text(l10n.sign_out), findsOneWidget);
  });

  testWidgets('puts the owner avatar on top of mine while a delegated mailbox is shown',
      (tester) async {
    container
        .read(activeAccountProvider.notifier)
        .applySession(DelegationFixtures.session());
    DelegationFixtures.turnDelegationOn(container);
    container
        .read(activeAccountProvider.notifier)
        .select(DelegationFixtures.bobAccountId);

    await tester.pumpWidget(_app(container, child: _menu()));
    await tester.pump();

    final avatars = tester
        .widget<LinagoraStackedAvatars>(find.byType(LinagoraStackedAvatars))
        .avatars;
    expect(avatars, hasLength(2));
    expect(
      find.descendant(of: find.byWidget(avatars.first), matching: find.text('B')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: find.byWidget(avatars.last), matching: find.text('A')),
      findsOneWidget,
    );
  });

  testWidgets('selecting a delegated row calls switchTo with that account',
      (tester) async {
    container
        .read(activeAccountProvider.notifier)
        .applySession(DelegationFixtures.session());
    DelegationFixtures.turnDelegationOn(container);

    await tester.pumpWidget(_app(container, child: _menu()));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey(UiKeys.userAvatar)));
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(LinagoraAccountMenu.itemKey(DelegationFixtures.bobAccountId)),
    );
    await tester.pumpAndSettle();

    expect(switchNotifier.switchToCalls, [DelegationFixtures.bobAccountId]);
  });

  testWidgets('toasts when switchTo fails after a menu select', (tester) async {
    switchNotifier.nextResult =
        AccountSwitchFailed(Exception('load'), StackTrace.current);
    container
        .read(activeAccountProvider.notifier)
        .applySession(DelegationFixtures.session());
    DelegationFixtures.turnDelegationOn(container);

    await tester.pumpWidget(_app(container, child: _menu()));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey(UiKeys.userAvatar)));
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(LinagoraAccountMenu.itemKey(DelegationFixtures.bobAccountId)),
    );
    await tester.pumpAndSettle();

    expect(
      appToast.errorMessages,
      [
        AppLocalizations()
            .couldNotOpenOwnerMailbox(DelegationFixtures.bobAddress),
      ],
    );
  });

  testWidgets('toasts close-composer copy when switch is refused',
      (tester) async {
    switchNotifier.nextResult =
        const AccountSwitchRefused(AccountSwitchRefusal.composerOpen);
    container
        .read(activeAccountProvider.notifier)
        .applySession(DelegationFixtures.session());
    DelegationFixtures.turnDelegationOn(container);

    await tester.pumpWidget(_app(container, child: _menu()));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey(UiKeys.userAvatar)));
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(LinagoraAccountMenu.itemKey(DelegationFixtures.bobAccountId)),
    );
    await tester.pumpAndSettle();

    expect(
      appToast.errorMessages,
      [AppLocalizations().closeComposerBeforeSwitchingAccounts],
    );
  });

  testWidgets('copying the shown address toasts through the app toast provider',
      (tester) async {
    container
        .read(activeAccountProvider.notifier)
        .applySession(DelegationFixtures.session());
    DelegationFixtures.turnDelegationOn(container);

    await tester.pumpWidget(_app(container, child: _menu()));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey(UiKeys.userAvatar)));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(LinagoraAccountMenuHeader.copyKey));
    await tester.pump();

    expect(
      appToast.successMessages,
      [AppLocalizations().email_address_copied_to_clipboard],
    );
  });
}
