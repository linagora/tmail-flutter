import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';
import 'package:tmail_ui_user/features/labels/presentation/widgets/label_list_context_menu.dart';

import '../email_label_robot.dart';

/// Web desktop: "Label as" opens a label submenu on mouse hover instead of the
/// add-label modal, so the mouse pointer stays on it until a label is picked.
class WebEmailLabelRobot extends EmailLabelRobot {
  WebEmailLabelRobot(super.$);

  TestGesture? _mousePointer;

  @override
  Future<void> openLabelPicker() async {
    await $(const ValueKey(UiKeys.emailDetailedMoreButton)).tap();

    final labelAsAction = $(EmailLabelRobot.labelAsActionKey);
    await labelAsAction.waitUntilExists();

    final mousePointer =
        await $.tester.createGesture(kind: PointerDeviceKind.mouse);
    await mousePointer.addPointer(location: Offset.zero);
    _mousePointer = mousePointer;
    await mousePointer.moveTo($.tester.getCenter(labelAsAction));
    await $.pump();
  }

  @override
  Future<void> selectLabel(String labelDisplayName) async {
    try {
      await $(LabelListContextMenu).$(labelDisplayName).tap();
    } finally {
      await _mousePointer?.removePointer();
      _mousePointer = null;
    }
  }
}
