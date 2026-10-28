import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/shown_account_input_block_notifier.dart';

/// So no action on the old list goes out with the new account.
class ShownAccountInputBlocker extends ConsumerWidget {
  final Widget child;

  const ShownAccountInputBlocker({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AbsorbPointer(
      absorbing: ref.watch(shownAccountInputBlockProvider),
      child: child,
    );
  }
}
