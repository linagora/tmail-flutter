import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/account_switch_loading_dialog_visible_notifier.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/shown_account_input_block_notifier.dart';
import 'package:tmail_ui_user/features/delegation/presentation/utils/shown_account_shortcut_block.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/action/dashboard_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/action/thread_detail_ui_action.dart';

/// So no tap or key press on the old list goes out with the new account.
class ShownAccountInputBlocker extends ConsumerStatefulWidget {
  final Widget child;

  const ShownAccountInputBlocker({super.key, required this.child});

  @override
  ConsumerState<ShownAccountInputBlocker> createState() => _ShownAccountInputBlockerState();
}

class _ShownAccountInputBlockerState extends ConsumerState<ShownAccountInputBlocker> {
  ProviderSubscription<bool>? _blockSubscription;
  ProviderSubscription<bool>? _dialogVisibleSubscription;

  @override
  void initState() {
    super.initState();
    // Drop debounced shortcuts as soon as block() flips, not on the next frame.
    _blockSubscription = ref.listenManual(shownAccountInputBlockProvider, (_, __) {
      _syncEffectiveBlock();
    });
    _dialogVisibleSubscription =
        ref.listenManual(accountSwitchLoadingDialogVisibleProvider, (_, __) {
      _syncEffectiveBlock();
    });
    _syncEffectiveBlock();
  }

  @override
  void dispose() {
    _blockSubscription?.close();
    _dialogVisibleSubscription?.close();
    if (shownAccountShortcutBlocked.value) {
      shownAccountShortcutBlocked.value = false;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isBlocked = ref.watch(shownAccountInputBlockProvider) ||
        ref.watch(accountSwitchLoadingDialogVisibleProvider);
    // Shortcuts such as N, which opens a composer, listen on a focused node that taps never reach.
    return ExcludeFocus(
      excluding: isBlocked,
      child: AbsorbPointer(absorbing: isBlocked, child: widget.child),
    );
  }

  void _syncEffectiveBlock() {
    final shouldBlock = ref.read(shownAccountInputBlockProvider) ||
        ref.read(accountSwitchLoadingDialogVisibleProvider);
    final wasBlocked = shownAccountShortcutBlocked.value;
    if (shouldBlock == wasBlocked) return;

    if (shouldBlock) {
      // Reject new key-downs before ExcludeFocus rebuilds. Do not save/restore
      // a pre-switch FocusNode: the dashboard tree is replaced and that node
      // goes stale (ModalScope on web). Reclaim after unblock instead.
      FocusManager.instance.primaryFocus?.unfocus();
      _dropDebouncedShortcuts();
      shownAccountShortcutBlocked.value = true;
    } else {
      shownAccountShortcutBlocked.value = false;
      _reclaimMailListShortcutFocus();
    }
  }

  /// Drops mail-list and opened-email shortcuts already in the 300 ms debounce.
  void _dropDebouncedShortcuts() {
    if (!Get.isRegistered<MailboxDashBoardController>()) return;
    final dashboard = Get.find<MailboxDashBoardController>();
    dashboard.dispatchAction(DropPendingMailListShortcutsAction());
    dashboard.dispatchThreadDetailUIAction(DropPendingMailViewShortcutsAction());
  }

  /// Thread/search controllers own the shortcut [FocusNode]. Reclaim after the
  /// next frame so [shownAccountShortcutBlocked] is already false.
  void _reclaimMailListShortcutFocus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || shownAccountShortcutBlocked.value) return;
      if (!Get.isRegistered<MailboxDashBoardController>()) return;
      Get.find<MailboxDashBoardController>().dispatchAction(
        ReclaimMailListKeyboardShortcutFocusAction(),
      );
    });
  }
}
