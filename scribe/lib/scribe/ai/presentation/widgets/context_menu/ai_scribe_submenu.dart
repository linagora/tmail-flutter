import 'package:flutter/material.dart';
import 'package:scribe/scribe.dart';

class AiScribeSubmenu extends StatelessWidget {
  final List<AiScribeContextMenuAction> menuActions;
  final ValueChanged<AiScribeContextMenuAction> onSelectAction;

  const AiScribeSubmenu({
    super.key,
    required this.menuActions,
    required this.onSelectAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AIScribeColors.background,
        borderRadius: const BorderRadius.all(
          Radius.circular(AIScribeSizes.menuRadius),
        ),
        boxShadow: AIScribeShadows.modal,
      ),
      clipBehavior: Clip.antiAlias,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: menuActions.length,
        itemBuilder: (_, index) {
          final action = menuActions[index];
          return AiScribeSubmenuItem(
            menuAction: action,
            onSelectAction: onSelectAction,
          );
        },
      ),
    );
  }
}
