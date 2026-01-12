import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/base/widget/context_menu/context_menu_dialog_item.dart';

import '../../base/core_robot.dart';

class LabelActionTypeContextMenuRobot extends CoreRobot {
  LabelActionTypeContextMenuRobot(super.$);

  Future<void> selectActionByName(String name) async {
    final item = $(ContextMenuDialogItem).$(name);
    await $.scrollUntilVisible(finder: item);
    await item.tap();
  }
}
