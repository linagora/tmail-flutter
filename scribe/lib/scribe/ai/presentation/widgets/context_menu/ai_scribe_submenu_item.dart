import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scribe/scribe.dart';

class AiScribeSubmenuItem extends StatelessWidget {
  final AiScribeContextMenuAction menuAction;
  final ValueChanged<AiScribeContextMenuAction> onSelectAction;

  const AiScribeSubmenuItem({
    super.key,
    required this.menuAction,
    required this.onSelectAction,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () => onSelectAction(menuAction),
        hoverColor: AppColor.grayBackgroundColor,
        child: Container(
          height: AIScribeSizes.menuItemHeight,
          padding: AIScribeSizes.menuItemPadding,
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
            ],
          ),
        ),
      ),
    );
  }
}
