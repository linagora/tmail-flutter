import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linagora_design_flutter/linagora_design_flutter.dart';
import 'package:tmail_ui_user/features/delegation/domain/model/active_account.dart';
import 'package:tmail_ui_user/features/delegation/presentation/model/account_switch_view.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/account_switch_notifier.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/active_account_notifier.dart';
import 'package:tmail_ui_user/features/delegation/presentation/utils/switch_loading_dialog_timing.dart';
import 'package:tmail_ui_user/features/delegation/presentation/view/account_switch_loading_dialog_host.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/shown_account_input_blocker.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations_delegate.dart';
import 'package:tmail_ui_user/main/localizations/localization_service.dart';

import '../../../../fixtures/delegation_fixtures.dart';

class _SlowSwitchView implements AccountSwitchView {
  @override
  bool hasOpenComposer = false;

  final loadings = <Completer<void>>[];

  @override
  void blockInput() {}

  @override
  void unblockInput() {}

  @override
  void clearSelectionAndSearch() {}

  @override
  Future<void> loadAccount(ActiveAccount account, int switchAttemptId) {
    final loading = Completer<void>();
    loadings.add(loading);
    return loading.future;
  }

  @override
  void catchUpAccount(ActiveAccount account, int switchAttemptId) {}
}

Widget _hostApp(ProviderContainer container) {
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
      home: Scaffold(
        body: AccountSwitchLoadingDialogHost(child: SizedBox.shrink()),
      ),
    ),
  );
}

void main() {
  late ProviderContainer container;
  late _SlowSwitchView view;

  setUp(() {
    container = ProviderContainer();
    addTearDown(container.dispose);
    view = _SlowSwitchView();
    container.read(activeAccountProvider.notifier).applySession(DelegationFixtures.session());
  });

  Future<void> startSwitchToBob() {
    return container.read(accountSwitchProvider.notifier).switchTo(
          DelegationFixtures.bobAccountId,
          view,
        );
  }

  testWidgets('shows no dialog while idle', (tester) async {
    await tester.pumpWidget(_hostApp(container));
    await tester.pump();

    expect(find.byType(LinagoraDialog), findsNothing);
  });

  testWidgets('does not show the dialog for a switch shorter than the show delay', (tester) async {
    await tester.pumpWidget(_hostApp(container));
    final switching = startSwitchToBob();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 299));
    view.loadings.single.complete();
    await switching;
    await tester.pump();
    await tester.pump(SwitchLoadingDialogTiming.showDelay);

    expect(find.byType(LinagoraDialog), findsNothing);
  });

  testWidgets('shows the dialog after the show delay and keeps it for the minimum time',
      (tester) async {
    await tester.pumpWidget(_hostApp(container));
    final switching = startSwitchToBob();
    await tester.pump();
    await tester.pump(SwitchLoadingDialogTiming.showDelay);

    expect(find.text("Opening ${DelegationFixtures.bobAddress}'s mailbox…"), findsOneWidget);

    view.loadings.single.complete();
    await switching;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 499));
    expect(find.byType(LinagoraDialog), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1));
    await tester.pumpAndSettle();
    expect(find.byType(LinagoraDialog), findsNothing);
  });

  testWidgets('Cancel calls cancel on the switch notifier', (tester) async {
    await tester.pumpWidget(_hostApp(container));
    final switching = startSwitchToBob();
    await tester.pump();
    await tester.pump(SwitchLoadingDialogTiming.showDelay);

    await tester.tap(find.byKey(LinagoraDialog.primaryActionKey));
    await tester.pump();
    await switching;
    await tester.pump(SwitchLoadingDialogTiming.minVisible);
    await tester.pumpAndSettle();

    expect(find.byType(LinagoraDialog), findsNothing);
  });

  testWidgets('Escape cancels the switch', (tester) async {
    await tester.pumpWidget(_hostApp(container));
    final switching = startSwitchToBob();
    await tester.pump();
    await tester.pump(SwitchLoadingDialogTiming.showDelay);
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    await switching.timeout(const Duration(seconds: 2));
    await tester.pump(SwitchLoadingDialogTiming.minVisible);
    await tester.pumpAndSettle();

    expect(find.byType(LinagoraDialog), findsNothing);
  });

  testWidgets('Enter cancels the switch', (tester) async {
    await tester.pumpWidget(_hostApp(container));
    final switching = startSwitchToBob();
    await tester.pump();
    await tester.pump(SwitchLoadingDialogTiming.showDelay);
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    await switching.timeout(const Duration(seconds: 2));
    await tester.pump(SwitchLoadingDialogTiming.minVisible);
    await tester.pumpAndSettle();

    expect(find.byType(LinagoraDialog), findsNothing);
  });

  testWidgets('closes when the session ends during a switch', (tester) async {
    await tester.pumpWidget(_hostApp(container));
    final switching = startSwitchToBob();
    await tester.pump();
    await tester.pump(SwitchLoadingDialogTiming.showDelay);
    expect(find.byType(LinagoraDialog), findsOneWidget);

    container.read(accountSwitchProvider.notifier).endSession();
    await switching;
    await tester.pump();
    await tester.pump(SwitchLoadingDialogTiming.minVisible);
    await tester.pumpAndSettle();

    expect(find.byType(LinagoraDialog), findsNothing);
  });

  testWidgets('removes the dialog when the host is unmounted while it is visible', (tester) async {
    await tester.pumpWidget(_hostApp(container));
    final switching = startSwitchToBob();
    await tester.pump();
    await tester.pump(SwitchLoadingDialogTiming.showDelay);
    expect(find.byType(LinagoraDialog), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();

    expect(find.byType(LinagoraDialog), findsNothing);
    view.loadings.single.complete();
    await switching;
  });

  testWidgets('hiding the dialog does not pop a route pushed above it', (tester) async {
    final navigatorKey = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          navigatorKey: navigatorKey,
          localizationsDelegates: const [
            AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: LocalizationService.supportedLocales,
          locale: LocalizationService.defaultLocale,
          home: const Scaffold(
            body: AccountSwitchLoadingDialogHost(child: SizedBox.shrink()),
          ),
        ),
      ),
    );
    final switching = startSwitchToBob();
    await tester.pump();
    await tester.pump(SwitchLoadingDialogTiming.showDelay);
    expect(find.byType(LinagoraDialog), findsOneWidget);

    unawaited(navigatorKey.currentState!.push(
      MaterialPageRoute<void>(builder: (_) => const Text('above-dialog')),
    ));
    await tester.pumpAndSettle();
    expect(find.text('above-dialog'), findsOneWidget);

    view.loadings.single.complete();
    await switching;
    await tester.pump();
    await tester.pump(SwitchLoadingDialogTiming.minVisible);
    await tester.pumpAndSettle();

    expect(find.byType(LinagoraDialog), findsNothing);
    expect(find.text('above-dialog'), findsOneWidget);
  });

  testWidgets('does not throw when the host leaves the tree while the dialog is up', (tester) async {
    final showHost = ValueNotifier<bool>(true);
    addTearDown(showHost.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: LocalizationService.supportedLocales,
          locale: LocalizationService.defaultLocale,
          home: Scaffold(
            body: ValueListenableBuilder<bool>(
              valueListenable: showHost,
              builder: (_, show, __) => show
                  ? const AccountSwitchLoadingDialogHost(
                      child: ShownAccountInputBlocker(child: SizedBox.shrink()),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final switching = startSwitchToBob();
    await tester.pump();
    await tester.pump(SwitchLoadingDialogTiming.showDelay);
    expect(find.byType(LinagoraDialog), findsOneWidget);

    // For example the dashboard is torn down because the session ended mid-switch.
    showHost.value = false;
    await tester.pump();
    await tester.pump();

    expect(tester.takeException(), isNull);

    container.read(accountSwitchProvider.notifier).cancel();
    await switching;
    await tester.pumpAndSettle();
    expect(find.byType(LinagoraDialog), findsNothing);
  });
}
