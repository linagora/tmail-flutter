import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/shown_account_input_block_notifier.dart';
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
  FocusNode? _focusBeforeBlock;
  ProviderSubscription<bool>? _blockSubscription;

  @override
  void initState() {
    super.initState();
    // Drop debounced shortcuts as soon as block() flips, not on the next frame.
    _blockSubscription = ref.listenManual(shownAccountInputBlockProvider, _onBlockChanged);
  }

  @override
  void dispose() {
    _blockSubscription?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isBlocked = ref.watch(shownAccountInputBlockProvider);
    // Shortcuts such as N, which opens a composer, listen on a focused node that taps never reach.
    return ExcludeFocus(
      excluding: isBlocked,
      child: AbsorbPointer(absorbing: isBlocked, child: widget.child),
    );
  }

  void _onBlockChanged(bool? previous, bool isBlocked) {
    if (isBlocked) {
      _focusBeforeBlock = FocusManager.instance.primaryFocus;
      _dropDebouncedShortcuts();
    } else {
      _restoreFocus();
    }
  }

  /// Drops mail-list and opened-email shortcuts already in the 300 ms debounce.
  void _dropDebouncedShortcuts() {
    if (!Get.isRegistered<MailboxDashBoardController>()) return;
    final dashboard = Get.find<MailboxDashBoardController>();
    dashboard.dispatchAction(DropPendingMailListShortcutsAction());
    dashboard.dispatchThreadDetailUIAction(DropPendingMailViewShortcutsAction());
  }

  /// Once the subtree can take focus again, so the mail list shortcuts work without a click.
  void _restoreFocus() {
    final focus = _focusBeforeBlock;
    _focusBeforeBlock = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && focus != null && focus.context != null) focus.requestFocus();
    });
  }
}
