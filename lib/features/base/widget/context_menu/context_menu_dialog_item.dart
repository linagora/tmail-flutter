import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tmail_ui_user/features/base/widget/context_menu/context_menu_item_action.dart';

class ContextMenuDialogItem extends StatelessWidget {
  final ContextMenuItemAction menuAction;
  final OnContextMenuActionClick onContextMenuActionClick;

  const ContextMenuDialogItem({
    super.key,
    required this.menuAction,
    required this.onContextMenuActionClick,
  });

  @override
  Widget build(BuildContext context) {
    Widget? iconWidget;
    Widget? selectedIconWidget;
    bool isSelected = false;
    bool isArrangeRTL = true;

    if (menuAction is ContextMenuItemActionRequiredIcon) {
      final specificMenuAction =
          menuAction as ContextMenuItemActionRequiredIcon;
      iconWidget = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: SvgPicture.asset(
          specificMenuAction.actionIcon,
          width: 20,
          height: 20,
          colorFilter: specificMenuAction.actionIconColor.asFilter(),
          fit: BoxFit.fill,
        ),
      );
    } else if (menuAction is ContextMenuItemActionRequiredSelectedIcon) {
      final specificMenuAction =
          menuAction as ContextMenuItemActionRequiredSelectedIcon;
      selectedIconWidget = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: SvgPicture.asset(
          specificMenuAction.selectedIcon,
          width: 20,
          height: 20,
          colorFilter: specificMenuAction.selectedIconColor.asFilter(),
          fit: BoxFit.fill,
        ),
      );
      isSelected = specificMenuAction.selectedAction == menuAction.action;
      isArrangeRTL = specificMenuAction.isArrangeRTL;
    } else if (menuAction is ContextMenuItemActionRequiredFull) {
      final specificMenuAction =
          menuAction as ContextMenuItemActionRequiredFull;
      iconWidget = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: SvgPicture.asset(
          specificMenuAction.actionIcon,
          width: 20,
          height: 20,
          colorFilter: specificMenuAction.actionIconColor.asFilter(),
          fit: BoxFit.fill,
        ),
      );
      selectedIconWidget = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: SvgPicture.asset(
          specificMenuAction.selectedIcon,
          width: 20,
          height: 20,
          colorFilter: specificMenuAction.selectedIconColor.asFilter(),
          fit: BoxFit.fill,
        ),
      );
      isSelected = specificMenuAction.selectedAction == menuAction.action;
      isArrangeRTL = specificMenuAction.isArrangeRTL;
    }

    final leadingWidget =
        iconWidget ?? (isArrangeRTL ? const SizedBox(width: 24) : null);

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () => menuAction.onClick(onContextMenuActionClick),
        child: SizedBox(
          height: 48,
          child: Row(
            children: [
              if (leadingWidget != null) leadingWidget,
              if (!isArrangeRTL && selectedIconWidget != null)
                selectedIconWidget,
              Expanded(
                child: Text(
                  menuAction.actionName,
                  style: ThemeUtils.textStyleInter400.copyWith(
                    color: menuAction.actionNameColor,
                    letterSpacing: -0.15,
                    fontSize: 16,
                    height: 21.01 / 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isArrangeRTL && isSelected && selectedIconWidget != null)
                selectedIconWidget
              else
                const SizedBox(width: 24),
            ],
          ),
        ),
      ),
    );
  }
}
