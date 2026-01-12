import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:scribe/scribe.dart';

class AiScribeMobileActionsItem extends StatelessWidget {
  final AiScribeContextMenuAction menuAction;
  final ImagePaths imagePaths;
  final ValueChanged<AiScribeCategoryContextMenuAction>? onCategorySelected;
  final ValueChanged<AiScribeContextMenuAction> onActionSelected;

  const AiScribeMobileActionsItem({
    super.key,
    required this.menuAction,
    required this.imagePaths,
    this.onCategorySelected,
    required this.onActionSelected,
  });

  @override
  Widget build(BuildContext context) {
    // When category
    final hasSubmenu = menuAction.hasSubmenu;
    if (hasSubmenu) {
      return AiScribeMenuItem(
        menuAction: menuAction,
        imagePaths: imagePaths,
        onSelectAction: (menuAction) {
          if (menuAction is AiScribeCategoryContextMenuAction) {
            onCategorySelected?.call(menuAction);
          } else {
            onActionSelected.call(menuAction);
          }
        }
      );
    }

    // When action alongside category
    final submenuActions = menuAction.submenuActions;
    if (submenuActions != null && submenuActions.isNotEmpty) {
      if (submenuActions.length == 1) {
        return AiScribeSubmenuItem(
          menuAction: submenuActions.first,
          onSelectAction: onActionSelected,
        );
      }
    }

    // When action inside category
    return AiScribeMenuItem(
      menuAction: menuAction,
      imagePaths: imagePaths,
      onSelectAction: onActionSelected,
    );
  }
}
