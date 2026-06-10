import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/base/widget/context_menu/context_menu_dialog_item.dart';
import 'package:tmail_ui_user/features/base/widget/popup_menu/popup_menu_item_action_widget.dart';

import '../../base/core_robot.dart';

class LabelListContextMenuRobot extends CoreRobot {
  LabelListContextMenuRobot(super.$);

  Future<void> selectLabelByName(String name) async {
    if ($(ContextMenuDialogItem).evaluate().isNotEmpty) {
      await _selectLabelFromBottomSheet(name);
    } else {
      await _selectLabelFromPopupMenu(name);
    }
  }

  // Mobile: bottom sheet uses ContextMenuDialogItem.
  Future<void> _selectLabelFromBottomSheet(String name) async {
    final item = $(ContextMenuDialogItem).$(name);
    await $.scrollUntilVisible(finder: item);
    await item.tap();
  }

  // Web: showMenu popup uses PopupMenuItemActionWidget.
  Future<void> _selectLabelFromPopupMenu(String name) async {
    final item = $(PopupMenuItemActionWidget).$(name);
    await $.waitUntilVisible(item);
    await item.tap();
  }
}
