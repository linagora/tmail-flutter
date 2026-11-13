import 'package:flutter/material.dart';

class ComposerOverflowAction {
  final Widget button;
  final Widget menuItem;

  const ComposerOverflowAction({required this.button, required this.menuItem});
}

typedef OverflowTrailingBuilder = Widget Function(List<Widget> overflowMenuItems);

/// Shows [actions] left to right; those that don't fit go, in order, to [trailingBuilder].
class ComposerOverflowActionBar extends StatelessWidget {
  final List<ComposerOverflowAction> actions;
  final OverflowTrailingBuilder trailingBuilder;
  final double slotWidth;
  final double reservedWidth;

  const ComposerOverflowActionBar({
    super.key,
    required this.actions,
    required this.trailingBuilder,
    required this.slotWidth,
    required this.reservedWidth,
  });

  @visibleForTesting
  static int visibleCount({
    required double maxWidth,
    required int actionCount,
    required double slotWidth,
    required double reservedWidth,
  }) {
    if (!maxWidth.isFinite) return actionCount;
    final fit = ((maxWidth - reservedWidth) / slotWidth).floor();
    return fit.clamp(0, actionCount);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final count = visibleCount(
          maxWidth: constraints.maxWidth,
          actionCount: actions.length,
          slotWidth: slotWidth,
          reservedWidth: reservedWidth,
        );
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            for (final action in actions.take(count)) action.button,
            trailingBuilder([
              for (final action in actions.skip(count)) action.menuItem,
            ]),
          ],
        );
      },
    );
  }
}
