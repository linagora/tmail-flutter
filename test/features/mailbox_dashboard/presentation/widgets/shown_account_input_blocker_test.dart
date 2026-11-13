import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/base/action/ui_action.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/account_switch_loading_dialog_visible_notifier.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/shown_account_input_block_notifier.dart';
import 'package:tmail_ui_user/features/delegation/presentation/utils/shown_account_shortcut_block.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/action/dashboard_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/shown_account_input_blocker.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/action/thread_detail_ui_action.dart';

class _RecordingMailboxDashBoardController extends Mock implements MailboxDashBoardController {
  final actions = <UIAction>[];
  final threadDetailActions = <ThreadDetailUIAction>[];

  @override
  InternalFinalCallback<void> get onStart => InternalFinalCallback<void>(callback: () {});

  @override
  InternalFinalCallback<void> get onDelete => InternalFinalCallback<void>(callback: () {});

  @override
  void dispatchAction(UIAction action) => actions.add(action);

  @override
  void dispatchThreadDetailUIAction(ThreadDetailUIAction action) => threadDetailActions.add(action);
}

const _buttonKey = Key('shown-mailbox-button');

class _Taps {
  int count = 0;

  void record() => count++;
}

Widget _dashboard(ProviderContainer container, VoidCallback onTap, {bool showsBlocker = true}) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      home: showsBlocker
          ? ShownAccountInputBlocker(
              child: TextButton(key: _buttonKey, onPressed: onTap, child: const Text('Open')),
            )
          : const SizedBox.shrink(),
    ),
  );
}

/// Like the mail list, whose shortcuts (N opens a composer) listen on a focused node.
Widget _shortcutDashboard(ProviderContainer container, VoidCallback onKey) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      home: ShownAccountInputBlocker(
        child: Focus(
          autofocus: true,
          onKeyEvent: (_, event) {
            if (event is KeyDownEvent) onKey();
            return KeyEventResult.handled;
          },
          child: const Text('mail list'),
        ),
      ),
    ),
  );
}

void main() {
  late ProviderContainer container;
  late _Taps taps;

  setUp(() {
    container = ProviderContainer();
    addTearDown(container.dispose);
    addTearDown(() => shownAccountShortcutBlocked.value = false);
    taps = _Taps();
  });

  testWidgets('lets taps through while no switch blocks them', (tester) async {
    await tester.pumpWidget(_dashboard(container, taps.record));

    await tester.tap(find.byKey(_buttonKey));

    expect(taps.count, 1);
  });

  testWidgets('absorbs taps while a switch blocks them', (tester) async {
    await tester.pumpWidget(_dashboard(container, taps.record));
    container.read(shownAccountInputBlockProvider.notifier).block();
    await tester.pump();

    await tester.tap(find.byKey(_buttonKey), warnIfMissed: false);

    expect(taps.count, 0);
  });

  testWidgets('lets taps through again once the switch unblocks them', (tester) async {
    await tester.pumpWidget(_dashboard(container, taps.record));
    container.read(shownAccountInputBlockProvider.notifier).block();
    await tester.pump();
    container.read(shownAccountInputBlockProvider.notifier).unblock();
    await tester.pump();

    await tester.tap(find.byKey(_buttonKey));

    expect(taps.count, 1);
  });

  testWidgets('a block left by a session ended during a switch is gone for the next dashboard',
      (tester) async {
    await tester.pumpWidget(_dashboard(container, taps.record));
    container.read(shownAccountInputBlockProvider.notifier).block();
    await tester.pump();

    await tester.pumpWidget(_dashboard(container, taps.record, showsBlocker: false));
    await tester.pump();
    await tester.pumpWidget(_dashboard(container, taps.record));
    await tester.tap(find.byKey(_buttonKey));

    expect(taps.count, 1);
  });

  testWidgets('lets key presses reach the shown mailbox while no switch blocks them', (tester) async {
    await tester.pumpWidget(_shortcutDashboard(container, taps.record));
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.keyN);

    expect(taps.count, 1);
  });

  testWidgets('keeps key presses from the shown mailbox while a switch blocks them', (tester) async {
    await tester.pumpWidget(_shortcutDashboard(container, taps.record));
    await tester.pump();
    container.read(shownAccountInputBlockProvider.notifier).block();
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.keyN);

    expect(taps.count, 0);
  });

  testWidgets('asks the dashboard to reclaim mail-list shortcut focus after unblock',
      (tester) async {
    final dashboard = _RecordingMailboxDashBoardController();
    Get.put<MailboxDashBoardController>(dashboard);
    addTearDown(Get.reset);

    await tester.pumpWidget(_shortcutDashboard(container, taps.record));
    await tester.pump();
    container.read(shownAccountInputBlockProvider.notifier).block();
    await tester.pump();
    container.read(shownAccountInputBlockProvider.notifier).unblock();

    // Reclaim is post-frame so the sync shortcut gate is already clear.
    expect(
      dashboard.actions.whereType<ReclaimMailListKeyboardShortcutFocusAction>(),
      isEmpty,
    );
    await tester.pump();
    expect(
      dashboard.actions.whereType<ReclaimMailListKeyboardShortcutFocusAction>(),
      hasLength(1),
    );
    expect(shownAccountShortcutBlocked.value, isFalse);
  });

  testWidgets(
      'does not reclaim focus while the loading dialog still keeps input blocked',
      (tester) async {
    final dashboard = _RecordingMailboxDashBoardController();
    Get.put<MailboxDashBoardController>(dashboard);
    addTearDown(Get.reset);

    await tester.pumpWidget(_shortcutDashboard(container, taps.record));
    await tester.pump();
    container.read(shownAccountInputBlockProvider.notifier).block();
    container
        .read(accountSwitchLoadingDialogVisibleProvider.notifier)
        .setVisible(true);
    await tester.pump();
    container.read(shownAccountInputBlockProvider.notifier).unblock();
    await tester.pump();

    expect(
      dashboard.actions.whereType<ReclaimMailListKeyboardShortcutFocusAction>(),
      isEmpty,
    );
    expect(shownAccountShortcutBlocked.value, isTrue);

    container
        .read(accountSwitchLoadingDialogVisibleProvider.notifier)
        .setVisible(false);
    await tester.pump();

    expect(
      dashboard.actions.whereType<ReclaimMailListKeyboardShortcutFocusAction>(),
      hasLength(1),
    );
    expect(shownAccountShortcutBlocked.value, isFalse);
  });

  testWidgets('lets key presses reach the shown mailbox again once the switch unblocks them', (tester) async {
    await tester.pumpWidget(_shortcutDashboard(container, taps.record));
    await tester.pump();
    container.read(shownAccountInputBlockProvider.notifier).block();
    await tester.pump();
    container.read(shownAccountInputBlockProvider.notifier).unblock();
    await tester.pump();
    // Reclaim is dispatched to ThreadController. This harness has no thread
    // focus node, so restore the list Focus for the key assertion.
    Focus.of(tester.element(find.text('mail list'))).requestFocus();
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.keyN);

    expect(taps.count, 1);
  });

  testWidgets('a button focused before the switch is not activated by Enter during it', (tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: ShownAccountInputBlocker(
            child: TextButton(
              key: _buttonKey,
              autofocus: true,
              onPressed: taps.record,
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(FocusManager.instance.primaryFocus?.hasFocus, isTrue);

    container.read(shownAccountInputBlockProvider.notifier).block();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);

    expect(taps.count, 0);
  });

  testWidgets('asks the dashboard to drop debounced mail-list shortcuts when a switch blocks',
      (tester) async {
    final dashboard = _RecordingMailboxDashBoardController();
    Get.put<MailboxDashBoardController>(dashboard);
    addTearDown(Get.reset);

    await tester.pumpWidget(_dashboard(container, taps.record));
    container.read(shownAccountInputBlockProvider.notifier).block();
    await tester.pump();

    expect(
      dashboard.actions.whereType<DropPendingMailListShortcutsAction>(),
      hasLength(1),
    );
    expect(dashboard.threadDetailActions.whereType<DropPendingMailViewShortcutsAction>(), hasLength(1));
  });

  testWidgets('sets the sync shortcut gate as soon as block flips, before ExcludeFocus rebuilds',
      (tester) async {
    await tester.pumpWidget(_shortcutDashboard(container, taps.record));
    await tester.pump();
    expect(shownAccountShortcutBlocked.value, isFalse);

    // No pump: gate must flip in the listenManual callback, not on the next frame.
    container.read(shownAccountInputBlockProvider.notifier).block();

    expect(shownAccountShortcutBlocked.value, isTrue);
  });

  testWidgets('keeps the dashboard blocked while the loading dialog stays for min-visible',
      (tester) async {
    await tester.pumpWidget(_shortcutDashboard(container, taps.record));
    await tester.pump();
    container.read(shownAccountInputBlockProvider.notifier).block();
    container.read(accountSwitchLoadingDialogVisibleProvider.notifier).setVisible(true);
    await tester.pump();

    container.read(shownAccountInputBlockProvider.notifier).unblock();
    await tester.pump();
    expect(shownAccountShortcutBlocked.value, isTrue);

    await tester.sendKeyEvent(LogicalKeyboardKey.keyN);
    expect(taps.count, 0);

    container.read(accountSwitchLoadingDialogVisibleProvider.notifier).setVisible(false);
    await tester.pump();
    expect(shownAccountShortcutBlocked.value, isFalse);

    // Harness has no ThreadController focus reclaim target.
    Focus.of(tester.element(find.text('mail list'))).requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.keyN);
    expect(taps.count, 1);
  });
}
