import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/sidebar/sidebar_label_item.dart';

import '../../base/core_robot.dart';

class LabelRobot extends CoreRobot {
  LabelRobot(super.$);

  Future<void> longPressLabelWithName(String name) async {
    final item = $(SidebarLabelItem).$(name);
    await $.scrollUntilVisible(finder: item);
    await item.longPress();
  }

  Future<void> tapCreateNewLabelButton() async {
    await $(const ValueKey(UiKeys.addNewLabelButton)).tap();
  }

  Future<void> openLabelByName(String name) async {
    final item = $(SidebarLabelItem).$(name);
    await $.scrollUntilVisible(finder: item);
    await item.tap();
  }
}
