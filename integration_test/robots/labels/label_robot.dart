import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/labels/label_list_item.dart';

import '../../base/core_robot.dart';

class LabelRobot extends CoreRobot {
  LabelRobot(super.$);

  Future<void> longPressLabelWithName(String name) async {
    final item = $(LabelListItem).$(name);
    await $.scrollUntilVisible(finder: item);
    await item.longPress();
  }

  Future<void> tapCreateNewLabelButton() async {
    await $(#labels_bar_widget_add_new_label_button).tap();
  }
}
