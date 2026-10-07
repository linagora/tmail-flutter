import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/base/widget/popup_menu/popup_menu_item_action_widget.dart';
import 'package:tmail_ui_user/features/labels/presentation/widgets/label_list_context_menu.dart';

import '../email_label_robot.dart';

/// Web desktop: the more menu is a popup where "Label as" opens a label
/// submenu on mouse hover, so the mouse pointer stays on it until a label is
/// picked. Narrow web layouts open a bottom sheet and the add-label modal,
/// like mobile.
class WebEmailLabelRobot extends EmailLabelRobot {
  WebEmailLabelRobot(super.$);

  TestGesture? _mousePointer;

  @override
  Future<void> openLabelPicker() async {
    await tapMoreButton();

    final labelAsAction = $(EmailLabelRobot.labelAsActionKey);
    await labelAsAction.waitUntilExists();
    if ($(PopupMenuItemActionWidget).evaluate().isEmpty) {
      await labelAsAction.tap();
      return;
    }

    final mousePointer =
        await $.tester.createGesture(kind: PointerDeviceKind.mouse);
    await mousePointer.addPointer(location: Offset.zero);
    _mousePointer = mousePointer;
    await mousePointer.moveTo($.tester.getCenter(labelAsAction));
    await $.pump();
  }

  @override
  Future<void> selectLabel(String labelDisplayName) async {
    final mousePointer = _mousePointer;
    if (mousePointer == null) return super.selectLabel(labelDisplayName);

    try {
      await $(LabelListContextMenu).$(labelDisplayName).tap();
    } finally {
      await mousePointer.removePointer();
      _mousePointer = null;
    }
  }
}
