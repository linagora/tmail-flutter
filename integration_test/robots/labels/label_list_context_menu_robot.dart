import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/base/widget/context_menu/context_menu_dialog_item.dart';
import 'package:tmail_ui_user/features/base/widget/popup_menu/popup_menu_item_action_widget.dart';

import '../../base/core_robot.dart';

class LabelListContextMenuRobot extends CoreRobot {
  LabelListContextMenuRobot(super.$);

  Future<void> selectLabelByName(String name) async {
    // Mobile: bottom sheet uses ContextMenuDialogItem.
    // Web: showMenu popup uses PopupMenuItemActionWidget.
    if ($(ContextMenuDialogItem).evaluate().isNotEmpty) {
      final item = $(ContextMenuDialogItem).$(name);
      await $.scrollUntilVisible(finder: item);
      await item.tap();
    } else {
      final item = $(PopupMenuItemActionWidget).$(name);
      await $.waitUntilVisible(item);
      await item.tap();
    }
  }
}
