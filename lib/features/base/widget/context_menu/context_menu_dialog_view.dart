import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/base/widget/context_menu/context_menu_dialog_item.dart';
import 'package:tmail_ui_user/features/base/widget/context_menu/context_menu_item_action.dart';

class ContextMenuDialogView extends StatelessWidget {
  final List<ContextMenuItemAction> actions;
  final OnContextMenuActionClick onContextMenuActionClick;

  const ContextMenuDialogView({
    super.key,
    required this.actions,
    required this.onContextMenuActionClick,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: actions.map((menuAction) => ContextMenuDialogItem(
          menuAction: menuAction,
          onContextMenuActionClick: onContextMenuActionClick,
        )).toList(),
      ),
    );
  }
}
