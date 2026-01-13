import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:scribe/scribe.dart';

typedef OnHoverAction = void Function(bool);

class AiScribeMenuItem extends StatelessWidget {
  final GlobalKey? itemKey;
  final AiScribeContextMenuAction menuAction;
  final ValueChanged<AiScribeContextMenuAction> onSelectAction;
  final ImagePaths imagePaths;
  final OnHoverAction? onHover;

  const AiScribeMenuItem({
    super.key,
    this.itemKey,
    required this.menuAction,
    required this.onSelectAction,
    required this.imagePaths,
    this.onHover,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () => onSelectAction(menuAction),
        hoverColor: AppColor.grayBackgroundColor,
        onHover: onHover,
        child: Container(
          key: itemKey,
          height: AIScribeSizes.menuItemHeight,
          padding: AIScribeSizes.menuCategoryItemPadding,
          alignment: AlignmentDirectional.centerStart,
          child: Row(
            children: [
              if (menuAction.actionIcon != null)
                AiScribeMenuIcon(iconPath: menuAction.actionIcon!),
              AiScribeMenuText(text: menuAction.actionName),
              if (menuAction.hasSubmenu)
                AiScribeMenuSubmenuIcon(imagePaths: imagePaths),
            ],
          ),
        ),
      ),
    );
  }
}
