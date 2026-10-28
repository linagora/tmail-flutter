import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/delegation/domain/model/active_account.dart';
import 'package:tmail_ui_user/features/delegation/presentation/bridge/riverpod_active_account_source.dart';
import 'package:tmail_ui_user/features/delegation/presentation/model/account_switch_result.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/account_switch_notifier.dart';
import 'package:tmail_ui_user/features/delegation/presentation/model/shown_account_load.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/shown_account_input_block_notifier.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/shown_account_reload_notifier.dart';
import 'package:tmail_ui_user/features/delegation/presentation/providers/shown_account_load_tracker_provider.dart';
import 'package:tmail_ui_user/features/delegation/presentation/view/dashboard_account_switch_view.dart';
import 'package:tmail_ui_user/features/delegation/presentation/view/shown_mailbox_selection.dart';

import '../../../../fixtures/delegation_fixtures.dart';

class _FakeSelection implements ShownMailboxSelection {
  @override
  bool hasOpenComposer = false;

  int clearedCount = 0;

  @override
  void clearSelectionAndSearch() => clearedCount++;
}

ShownAccountLoad _loadedIn(int attemptId) =>
    ShownAccountLoad(attemptId: attemptId, result: Future.value(const ShownAccountLoaded()));

void main() {
  late ProviderContainer container;
  late _FakeSelection selection;
  late DashboardAccountSwitchView view;
  late List<int?> reloadRequests;
  late ActiveAccount account;
  late GlobalKey<NavigatorState> navigatorKey;

  setUp(() {
    container = ProviderContainer();
    addTearDown(container.dispose);
    container.listen(shownAccountInputBlockProvider, (_, __) {});
    reloadRequests = [];
    container.listen(shownAccountReloadProvider, (_, attemptId) => reloadRequests.add(attemptId));
    selection = _FakeSelection();
    navigatorKey = GlobalKey<NavigatorState>();
    view = DashboardAccountSwitchView(container, selection, navigatorKey);
    account = ActiveAccount.personal(DelegationFixtures.session());
  });

  group('composer and input:', () {
    test('reports an open composer of the dashboard', () {
      selection.hasOpenComposer = true;

      expect(view.hasOpenComposer, isTrue);
    });

    test('blockInput blocks taps on the shown mailbox', () {
      view.blockInput();

      expect(container.read(shownAccountInputBlockProvider), isTrue);
    });

    testWidgets('blockInput closes the dialogs, sheets and menus open above the dashboard', (tester) async {
      await tester.pumpWidget(MaterialApp(navigatorKey: navigatorKey, home: const Text('dashboard')));
      final context = navigatorKey.currentContext!;
      unawaited(showModalBottomSheet<void>(context: context, builder: (_) => const Text('sheet')));
      unawaited(showDialog<void>(context: context, builder: (_) => const Text('dialog')));
      await tester.pumpAndSettle();
      expect(find.text('dialog'), findsOneWidget);
      expect(find.text('sheet'), findsOneWidget);

      view.blockInput();
      await tester.pumpAndSettle();

      expect(find.text('dialog'), findsNothing);
      expect(find.text('sheet'), findsNothing);
      expect(find.text('dashboard'), findsOneWidget);
    });

    testWidgets('blockInput keeps the pages open above the dashboard', (tester) async {
      await tester.pumpWidget(MaterialApp(navigatorKey: navigatorKey, home: const Text('dashboard')));
      unawaited(navigatorKey.currentState!.push(MaterialPageRoute<void>(builder: (_) => const Text('page'))));
      await tester.pumpAndSettle();
      unawaited(showDialog<void>(context: navigatorKey.currentContext!, builder: (_) => const Text('dialog')));
      await tester.pumpAndSettle();

      view.blockInput();
      await tester.pumpAndSettle();

      expect(find.text('dialog'), findsNothing);
      expect(find.text('page'), findsOneWidget);
    });

    test('unblockInput lets taps through again', () {
      view.blockInput();

      view.unblockInput();

      expect(container.read(shownAccountInputBlockProvider), isFalse);
    });
  });

  group('selection and search:', () {
    test('clearing the selection and search clears them in the dashboard once', () {
      view.clearSelectionAndSearch();

      expect(selection.clearedCount, 1);
    });
  });

  group('loads:', () {
    test('loading an account already being loaded in the attempt asks for no reload', () async {
      final tracker = container.read(shownAccountLoadTrackerProvider)..reportFolders(_loadedIn(2));

      await view.loadAccount(account, 2);

      expect(reloadRequests, isEmpty);
      expect(tracker.hasFoldersLoad(2), isTrue);
    });

    test('loading an account nothing loads yet in the attempt asks for a reload', () {
      view.loadAccount(account, 2);

      expect(reloadRequests, [2]);
    });

    test('loading ends once the tracked loads of the attempt end', () async {
      container.read(shownAccountLoadTrackerProvider).reportFolders(_loadedIn(2));

      await expectLater(view.loadAccount(account, 2), completes);
    });

    test('catching up an account whose folders reloaded in the attempt asks for no reload', () {
      container.read(shownAccountLoadTrackerProvider).reportFolders(_loadedIn(3));

      view.catchUpAccount(account, 3);

      expect(reloadRequests, isEmpty);
    });

    test('catching up clears what the target already opened, so nothing of it stays tappable', () {
      container.read(shownAccountLoadTrackerProvider).reportFolders(_loadedIn(3));

      view.catchUpAccount(account, 3);

      expect(selection.clearedCount, 1);
    });

    test('catching up an account nothing reloaded in the attempt asks for a reload', () {
      view.catchUpAccount(account, 3);

      expect(reloadRequests, [3]);
    });
  });

  group('switch through the dashboard view:', () {
    late RiverpodActiveAccountSource source;
    late Completer<ShownAccountLoadResult> folders;

    setUp(() {
      source = RiverpodActiveAccountSource(container)..applySession(DelegationFixtures.session());
      folders = Completer<ShownAccountLoadResult>();
      addTearDown(source.watchShown((_) => source.reportLoad(
            ShownAccountLoadKind.folders,
            ShownAccountLoad(attemptId: source.currentSwitchAttemptId, result: folders.future),
          )));
    });

    test('ends once the folders of the target and the email list they open are loaded', () async {
      final emailList = Completer<ShownAccountLoadResult>();
      AccountSwitchResult? result;
      container
          .read(accountSwitchProvider.notifier)
          .switchTo(DelegationFixtures.bobAccountId, view)
          .then((value) => result = value);
      source.reportLoad(
        ShownAccountLoadKind.emailList,
        ShownAccountLoad(attemptId: source.currentSwitchAttemptId, result: emailList.future),
      );

      folders.complete(const ShownAccountLoaded());
      await pumpEventQueue();
      expect(result, isNull);
      expect(container.read(shownAccountInputBlockProvider), isTrue);

      emailList.complete(const ShownAccountLoaded());
      await pumpEventQueue();
      expect(result, const AccountSwitched());
      expect(source.accountId, DelegationFixtures.bobAccountId);
      expect(container.read(shownAccountInputBlockProvider), isFalse);
    });

    test('fails when the folders of the target fail and shows the previous account again', () async {
      final switching = container.read(accountSwitchProvider.notifier).switchTo(DelegationFixtures.bobAccountId, view);

      folders.complete(const ShownAccountLoadFailed('folders failed'));
      final result = await switching;

      expect(result, isA<AccountSwitchFailed>());
      expect(selection.clearedCount, 2);
      expect(source.accountId, DelegationFixtures.aliceAccountId);
      expect(container.read(shownAccountInputBlockProvider), isFalse);
      expect(reloadRequests, isEmpty);
    });
  });
}
