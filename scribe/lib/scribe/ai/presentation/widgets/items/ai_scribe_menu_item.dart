import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 12),
                  child: SvgPicture.asset(
                    menuAction.actionIcon!,
                    width: 20,
                    height: 20,
                    fit: BoxFit.fill,
                    colorFilter:
                        AppColor.gray424244.withValues(alpha: 0.72).asFilter(),
                  ),
                ),
              Flexible(
                child: Text(
                  menuAction.actionName,
                  style: AIScribeTextStyles.menuItem,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (menuAction.hasSubmenu)
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 3),
                  child: SvgPicture.asset(
                    imagePaths.icArrowRight,
                    width: 16,
                    height: 16,
                    fit: BoxFit.fill,
                    colorFilter: AppColor.gray777778.asFilter(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
