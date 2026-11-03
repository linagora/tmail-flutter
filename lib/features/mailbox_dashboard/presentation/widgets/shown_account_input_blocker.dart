import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/shown_account_input_block_notifier.dart';

/// So no tap or key press on the old list goes out with the new account.
class ShownAccountInputBlocker extends ConsumerStatefulWidget {
  final Widget child;

  const ShownAccountInputBlocker({super.key, required this.child});

  @override
  ConsumerState<ShownAccountInputBlocker> createState() => _ShownAccountInputBlockerState();
}

class _ShownAccountInputBlockerState extends ConsumerState<ShownAccountInputBlocker> {
  FocusNode? _focusBeforeBlock;

  @override
  Widget build(BuildContext context) {
    ref.listen<bool>(shownAccountInputBlockProvider, (_, isBlocked) {
      if (isBlocked) {
        _focusBeforeBlock = FocusManager.instance.primaryFocus;
      } else {
        _restoreFocus();
      }
    });
    final isBlocked = ref.watch(shownAccountInputBlockProvider);
    // Shortcuts such as N, which opens a composer, listen on a focused node that taps never reach.
    return ExcludeFocus(
      excluding: isBlocked,
      child: AbsorbPointer(absorbing: isBlocked, child: widget.child),
    );
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
