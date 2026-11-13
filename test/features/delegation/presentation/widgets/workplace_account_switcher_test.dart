import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:linagora_design_flutter/linagora_design_flutter.dart';
import 'package:tmail_ui_user/features/delegation/domain/model/active_account.dart';
import 'package:tmail_ui_user/features/delegation/presentation/model/account_switch_result.dart';
import 'package:tmail_ui_user/features/delegation/presentation/model/account_switch_state.dart';
import 'package:tmail_ui_user/features/delegation/presentation/model/account_switch_view.dart';
import 'package:tmail_ui_user/features/delegation/presentation/model/switch_attempt.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/account_switch_notifier.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/active_account_notifier.dart';
import 'package:tmail_ui_user/features/delegation/presentation/providers/account_switch_view_factory_provider.dart';
import 'package:tmail_ui_user/features/delegation/presentation/widgets/workplace_account_switcher.dart';
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
  AccountSwitchState forcedState = const AccountSwitchIdle();

  @override
  AccountSwitchState build() => forcedState;

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
  late ProviderContainer container;
  late _RecordingSwitchNotifier switchNotifier;
  late RecordingAppToast appToast;
  late AppLocalizations l10n;

  setUpAll(() {
    l10n = AppLocalizations();
  });

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

  Future<void> pumpSwitcher(WidgetTester tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
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
          home: Scaffold(
            body: Align(
              alignment: Alignment.topRight,
              child: WorkplaceAccountSwitcher(),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  group('WorkplaceAccountSwitcher', () {
    testWidgets('hides when delegation is off', (tester) async {
      container
          .read(activeAccountProvider.notifier)
          .applySession(DelegationFixtures.session());

      await pumpSwitcher(tester);

      expect(find.byKey(LinagoraAccountSwitcher.chipKey), findsNothing);
    });

    testWidgets(
        'hides when delegation is on but no delegated account is listed',
        (tester) async {
      DelegationFixtures.turnDelegationOn(container);
      container.read(activeAccountProvider.notifier).applySession(
            DelegationFixtures.session(listsBob: false, listsCarol: false),
          );

      await pumpSwitcher(tester);

      expect(find.byKey(LinagoraAccountSwitcher.chipKey), findsNothing);
    });

    testWidgets('shows Viewing chip and menu sections when delegation is on',
        (tester) async {
      DelegationFixtures.turnDelegationOn(container);
      container
          .read(activeAccountProvider.notifier)
          .applySession(DelegationFixtures.session());

      await pumpSwitcher(tester);

      expect(
        find.text(l10n.viewingOwnerMailbox(DelegationFixtures.aliceAddress)),
        findsOneWidget,
      );

      await tester.tap(find.byKey(LinagoraAccountSwitcher.chipKey));
      await tester.pumpAndSettle();

      expect(find.text(l10n.yourMailbox), findsOneWidget);
      expect(find.text(l10n.delegatedToYou), findsOneWidget);
      expect(find.text(DelegationFixtures.bobAddress), findsWidgets);
      expect(find.text(DelegationFixtures.carolAddress), findsWidgets);
    });

    testWidgets('chip label follows the shown delegated account',
        (tester) async {
      DelegationFixtures.turnDelegationOn(container);
      final notifier = container.read(activeAccountProvider.notifier);
      notifier.applySession(DelegationFixtures.session());
      expect(notifier.select(DelegationFixtures.bobAccountId), isTrue);

      await pumpSwitcher(tester);

      expect(
        find.text(l10n.viewingOwnerMailbox(DelegationFixtures.bobAddress)),
        findsOneWidget,
      );
      expect(
        container.read(activeAccountProvider),
        ActiveAccount.delegated(
          DelegationFixtures.session(),
          DelegationFixtures.bobAccountId,
        ),
      );
    });

    testWidgets(
        'chip avatar uses chipAvatarSize; menu row avatars use tile avatarSize',
        (tester) async {
      DelegationFixtures.turnDelegationOn(container);
      container
          .read(activeAccountProvider.notifier)
          .applySession(DelegationFixtures.session());

      await pumpSwitcher(tester);

      final style = LinagoraAccountSwitcherStyle.material();
      final chipSize = style.chipAvatarSize;
      final tileSize = style.tileStyle.avatarSize;

      Finder initialsAt(double size) => find.byWidgetPredicate(
            (w) =>
                w is Text &&
                (w.data?.length ?? 0) == 1 &&
                w.style?.fontSize == size * 0.44 &&
                w.style?.fontWeight == FontWeight.w600,
          );

      expect(
        find.descendant(
          of: find.byKey(LinagoraAccountSwitcher.chipKey),
          matching: initialsAt(chipSize),
        ),
        findsOneWidget,
      );

      await tester.tap(find.byKey(LinagoraAccountSwitcher.chipKey));
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(LinagoraPersonTile),
          matching: initialsAt(tileSize),
        ),
        findsNWidgets(3),
      );
    });

    testWidgets('selecting a delegated row calls switchTo with that account',
        (tester) async {
      DelegationFixtures.turnDelegationOn(container);
      container
          .read(activeAccountProvider.notifier)
          .applySession(DelegationFixtures.session());

      await pumpSwitcher(tester);
      await tester.tap(find.byKey(LinagoraAccountSwitcher.chipKey));
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(LinagoraAccountMenu.itemKey(DelegationFixtures.bobAccountId)),
      );
      await tester.pumpAndSettle();

      expect(switchNotifier.switchToCalls, [DelegationFixtures.bobAccountId]);
    });

    testWidgets('toasts when switchTo fails after a menu select',
        (tester) async {
      switchNotifier.nextResult =
          AccountSwitchFailed(Exception('load'), StackTrace.current);
      DelegationFixtures.turnDelegationOn(container);
      container
          .read(activeAccountProvider.notifier)
          .applySession(DelegationFixtures.session());

      await pumpSwitcher(tester);
      await tester.tap(find.byKey(LinagoraAccountSwitcher.chipKey));
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(LinagoraAccountMenu.itemKey(DelegationFixtures.bobAccountId)),
      );
      await tester.pumpAndSettle();

      expect(
        appToast.errorMessages,
        [
          l10n.couldNotOpenOwnerMailbox(DelegationFixtures.bobAddress),
        ],
      );
    });

    testWidgets('toasts close-composer copy when switch is refused',
        (tester) async {
      switchNotifier.nextResult =
          const AccountSwitchRefused(AccountSwitchRefusal.composerOpen);
      DelegationFixtures.turnDelegationOn(container);
      container
          .read(activeAccountProvider.notifier)
          .applySession(DelegationFixtures.session());

      await pumpSwitcher(tester);
      await tester.tap(find.byKey(LinagoraAccountSwitcher.chipKey));
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(LinagoraAccountMenu.itemKey(DelegationFixtures.bobAccountId)),
      );
      await tester.pumpAndSettle();

      expect(
        appToast.errorMessages,
        [l10n.closeComposerBeforeSwitchingAccounts],
      );
    });

    testWidgets(
        'toasts return-to-mine copy when switching back to mine fails',
        (tester) async {
      switchNotifier.nextResult =
          AccountSwitchFailed(Exception('load'), StackTrace.current);
      DelegationFixtures.turnDelegationOn(container);
      final notifier = container.read(activeAccountProvider.notifier);
      notifier.applySession(DelegationFixtures.session());
      expect(notifier.select(DelegationFixtures.bobAccountId), isTrue);

      await pumpSwitcher(tester);
      await tester.tap(find.byKey(LinagoraAccountSwitcher.chipKey));
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(
          LinagoraAccountMenu.itemKey(DelegationFixtures.aliceAccountId),
        ),
      );
      await tester.pumpAndSettle();

      expect(switchNotifier.switchToCalls, [DelegationFixtures.aliceAccountId]);
      expect(appToast.errorMessages, [l10n.couldNotReturnToYourMailbox]);
    });

    testWidgets(
        'ellipsizes a long Viewing label when the header bounds chip width',
        (tester) async {
      DelegationFixtures.turnDelegationOn(container);
      final notifier = container.read(activeAccountProvider.notifier);
      notifier.applySession(DelegationFixtures.session());
      expect(notifier.select(DelegationFixtures.bobAccountId), isTrue);

      await tester.binding.setSurfaceSize(const Size(900, 600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(1.3)),
            child: MaterialApp(
              localizationsDelegates: [
                AppLocalizationsDelegate(),
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: LocalizationService.supportedLocales,
              locale: LocalizationService.defaultLocale,
              home: Scaffold(
                body: SizedBox(
                  width: 252,
                  child: Row(
                    children: [
                      Expanded(
                        child: Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: WorkplaceAccountSwitcher(),
                        ),
                      ),
                      SizedBox(width: 52),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.byKey(LinagoraAccountSwitcher.chipKey), findsOneWidget);
      final viewingLabel = l10n.viewingOwnerMailbox(DelegationFixtures.bobAddress);
      final label = tester.widget<Text>(
        find.descendant(
          of: find.byKey(LinagoraAccountSwitcher.chipKey),
          matching: find.text(viewingLabel),
        ),
      );
      expect(label.overflow, TextOverflow.ellipsis);
      expect(label.maxLines, 1);
    });

    testWidgets('ignores taps on the chip while a switch is in progress',
        (tester) async {
      switchNotifier.forcedState = AccountSwitching(
        SwitchAttempt(
          id: 1,
          from: DelegationFixtures.aliceAccountId,
          to: DelegationFixtures.bobAccountId,
        ),
      );
      DelegationFixtures.turnDelegationOn(container);
      container
          .read(activeAccountProvider.notifier)
          .applySession(DelegationFixtures.session());

      await pumpSwitcher(tester);

      expect(
        find.descendant(
          of: find.byType(WorkplaceAccountSwitcher),
          matching: find.byWidgetPredicate(
            (widget) => widget is Opacity && widget.opacity == 0.5,
          ),
        ),
        findsOneWidget,
      );
      expect(
        tester
            .widgetList<IgnorePointer>(
              find.descendant(
                of: find.byType(WorkplaceAccountSwitcher),
                matching: find.byType(IgnorePointer),
              ),
            )
            .any((widget) => widget.ignoring),
        isTrue,
      );

      await tester.tap(
        find.byKey(LinagoraAccountSwitcher.chipKey),
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();

      expect(find.byKey(LinagoraAccountSwitcher.menuKey), findsNothing);
      expect(switchNotifier.switchToCalls, isEmpty);
    });
  });
}
