import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/base/extensions/popup_menu_action_list_extension.dart';
import 'package:tmail_ui_user/features/base/mixin/popup_context_menu_action_mixin.dart';
import 'package:tmail_ui_user/features/base/model/popup_menu_item_action.dart';
import 'package:tmail_ui_user/features/base/widget/popup_menu/popup_menu_item_action_widget.dart';

typedef OnPopupMenuActionSelected = void Function(PopupMenuItemAction action);

class PopupMenuActionGroupWidget with PopupContextMenuActionMixin {
  final List<PopupMenuItemAction> actions;
  final OnPopupMenuActionSelected onActionSelected;
  final double dividerOpacity;

  const PopupMenuActionGroupWidget({
    required this.actions,
    required this.onActionSelected,
    this.dividerOpacity = 0.12,
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
                    Navigator.pop(context);
                    onActionSelected(menuAction);
                  },
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

    return openPopupMenuAction(context, position, popupMenuItems);
  }
}
