import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/base/extensions/context_menu_action_list_extension.dart';
import 'package:tmail_ui_user/features/base/widget/context_menu/context_menu_dialog_item.dart';
import 'package:tmail_ui_user/features/base/widget/context_menu/context_menu_item_action.dart';

class ContextMenuDialogView extends StatelessWidget {
  final List<ContextMenuItemAction> actions;
  final OnContextMenuActionClick onContextMenuActionClick;
  final bool useGroupedActions;

  const ContextMenuDialogView({
    super.key,
    required this.actions,
    required this.onContextMenuActionClick,
    this.useGroupedActions = false,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> childrenWidget = [];

    if (useGroupedActions) {
      final groupedActions = actions.groupByCategory();
      final entries = groupedActions.entries.toList();
      childrenWidget = [
        for (var i = 0; i < entries.length; i++)
          ...[
            ...entries[i].value.map((menuAction) => ContextMenuDialogItem(
              key: menuAction.key != null ? Key(menuAction.key!) : null,
              menuAction: menuAction,
              onContextMenuActionClick: onContextMenuActionClick,
            )),
            if (i < entries.length - 1)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Divider(
                  height: 1,
                  color: AppColor.gray424244.withValues(alpha: 0.12),
                ),
              ),
          ],
      ];
    } else {
      childrenWidget = actions
          .map((menuAction) => ContextMenuDialogItem(
                key: menuAction.key != null ? Key(menuAction.key!) : null,
                menuAction: menuAction,
                onContextMenuActionClick: onContextMenuActionClick,
              ))
          .toList();
    }

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: childrenWidget,
      ),
    );
  }
}
