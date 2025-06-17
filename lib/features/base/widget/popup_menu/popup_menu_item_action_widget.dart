import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
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
    Widget? selectedIconWidget;
    bool isSelected = false;

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
    } else if (menuAction is PopupMenuItemActionRequiredSelectedIcon) {
      final specificMenuAction =
          menuAction as PopupMenuItemActionRequiredSelectedIcon;
      selectedIconWidget = Padding(
        padding: const EdgeInsetsDirectional.only(start: 16),
        child: SvgPicture.asset(
          specificMenuAction.selectedIcon,
          width: specificMenuAction.selectedIconSize,
          height: specificMenuAction.selectedIconSize,
          colorFilter: specificMenuAction.selectedIconColor.asFilter(),
          fit: BoxFit.fill,
        ),
      );
      isSelected = specificMenuAction.selectedAction == menuAction.action;
    } else if (menuAction is PopupMenuItemActionRequiredFull) {
      final specificMenuAction = menuAction as PopupMenuItemActionRequiredFull;
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
      selectedIconWidget = Padding(
        padding: const EdgeInsetsDirectional.only(start: 16),
        child: SvgPicture.asset(
          specificMenuAction.selectedIcon,
          width: specificMenuAction.selectedIconSize,
          height: specificMenuAction.selectedIconSize,
          colorFilter: specificMenuAction.selectedIconColor.asFilter(),
          fit: BoxFit.fill,
        ),
      );
      isSelected = specificMenuAction.selectedAction == menuAction.action;
    } else if (menuAction
        is PopupMenuItemActionRequiredIconWithMultipleSelected) {
      final specificMenuAction =
          menuAction as PopupMenuItemActionRequiredIconWithMultipleSelected;
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
      selectedIconWidget = Padding(
        padding: const EdgeInsetsDirectional.only(start: 16),
        child: SvgPicture.asset(
          specificMenuAction.selectedIcon,
          width: specificMenuAction.selectedIconSize,
          height: specificMenuAction.selectedIconSize,
          colorFilter: specificMenuAction.selectedIconColor.asFilter(),
          fit: BoxFit.fill,
        ),
      );
      isSelected =
          specificMenuAction.selectedActions.contains(menuAction.action);
    }

    return PointerInterceptor(
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () => menuAction.onClick(menuActionClick),
          hoverColor: AppColor.popupMenuItemHovered,
          child: Container(
            height: 48,
            width: double.infinity,
            padding: menuAction.itemPadding,
            child: Row(
              children: [
                if (iconWidget != null) iconWidget,
                Expanded(
                  child: Text(
                    menuAction.actionName,
                    style: ThemeUtils.textStyleBodyBody3(
                      color: menuAction.actionNameColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isSelected && selectedIconWidget != null)
                  selectedIconWidget,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
