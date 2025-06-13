import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tmail_ui_user/features/base/model/popup_menu_item_action.dart';

class PopupMenuItemActionWidget extends StatelessWidget {
  final PopupMenuItemAction menuAction;
  final OnPopupMenuActionClick menuActionClick;

  const PopupMenuItemActionWidget({
    super.key,
    required this.menuAction,
    required this.menuActionClick,
  });

  @override
  Widget build(BuildContext context) {
    Widget? iconWidget;

    if (menuAction is PopupMenuItemActionRequiredIcon) {
      final specificMenuAction = menuAction as PopupMenuItemActionRequiredIcon;
      iconWidget = Padding(
        padding: const EdgeInsetsDirectional.only(end: 16),
        child: SvgPicture.asset(
          specificMenuAction.actionIcon,
          width: specificMenuAction.actionIconSize,
          height: specificMenuAction.actionIconSize,
          colorFilter: specificMenuAction.actionIconColor.asFilter(),
          fit: BoxFit.fill,
        ),
      );
    }

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () => menuAction.onClick(menuActionClick),
        child: Container(
          height: 48,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              if (iconWidget != null) iconWidget,
              Expanded(
                child: Text(
                  menuAction.getActionNameWithLimitation(),
                  style: ThemeUtils.textStyleBodyBody3(
                    color: menuAction.actionNameColor,
                  ),
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
