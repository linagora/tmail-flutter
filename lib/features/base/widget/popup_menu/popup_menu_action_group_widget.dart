import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/base/extensions/popup_menu_action_list_extension.dart';
import 'package:tmail_ui_user/features/base/mixin/popup_context_menu_action_mixin.dart';
import 'package:tmail_ui_user/features/base/model/popup_menu_item_action.dart';
import 'package:tmail_ui_user/features/base/widget/popup_menu/popup_menu_item_action_widget.dart';
import 'package:tmail_ui_user/features/base/widget/popup_menu/popup_submenu_controller.dart';

typedef OnPopupMenuActionSelected = void Function(PopupMenuItemAction action);

class PopupMenuActionGroupWidget with PopupContextMenuActionMixin {
  final List<PopupMenuItemAction> actions;
  final OnPopupMenuActionSelected onActionSelected;
  final double dividerOpacity;
  final PopupSubmenuController? submenuController;

  PopupMenuActionGroupWidget({
    required this.actions,
    required this.onActionSelected,
    this.dividerOpacity = 0.12,
    this.submenuController,
  });

  Future<void> show(
    BuildContext context,
    RelativeRect position,
  ) async {
    final groupedActions = actions.groupByCategory();
    final entries = groupedActions.entries.toList();

    final popupMenuItems = <PopupMenuEntry>[
      for (var i = 0; i < entries.length; i++) ...[
        ...entries[i].value.map(
              (menuAction) => PopupMenuItem(
                key: menuAction.key != null ? Key(menuAction.key!) : null,
                padding: EdgeInsets.zero,
                child: PopupMenuItemActionWidget(
                  menuAction: menuAction,
                  menuActionClick: (menuAction) {
                    submenuController?.hide();
                    Navigator.pop(context);
                    onActionSelected(menuAction);
                  },
                  onHoverShowSubmenu: submenuController != null && menuAction.submenu != null
                    ? (itemKey) => _showPopupSubmenu(
                        context: context,
                        itemKey: itemKey,
                        submenuController: submenuController!,
                        submenu: menuAction.submenu!,
                      )
                    : null,
                  onHoverOtherItem: submenuController?.hide,
                ),
              ),
            ),
        if (i < entries.length - 1)
          PopupMenuDivider(
            height: 1,
            color: AppColor.gray424244.withValues(alpha: dividerOpacity),
          ),
      ],
    ];

    try {
      await openPopupMenuAction(context, position, popupMenuItems);
    } finally {
      submenuController?.hide();
    }
  }

  void _showPopupSubmenu({
    required BuildContext context,
    required GlobalKey itemKey,
    required PopupSubmenuController submenuController,
    required Widget submenu,
}) {
    final renderObject = itemKey.currentContext?.findRenderObject();
    if (renderObject is! RenderBox) return;
    final renderBox = renderObject;

    final offset = renderBox.localToGlobal(Offset.zero);
    final rect = offset & renderBox.size;

    submenuController.show(
      context: context,
      anchor: rect,
      submenu: submenu,
    );
  }
}
