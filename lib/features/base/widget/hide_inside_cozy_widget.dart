import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tmail_ui_user/main/providers/cozy/inside_cozy_provider.dart';

/// Builds [child] only once the app is known to run outside Cozy, for actions
/// Twake Workplace already owns (e.g. sign out in its top bar).
class HideInsideCozyWidget extends ConsumerWidget {
  const HideInsideCozyWidget({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isInsideCozy = ref.watch(insideCozyProvider).value;
    return isInsideCozy == false ? child : const SizedBox.shrink();
  }
}
