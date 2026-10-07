import 'package:flutter/material.dart';
import 'package:model/email/email_action_type.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';

import '../base/core_robot.dart';
import 'abstract/abstract_email_label_robot.dart';

class EmailLabelRobot extends CoreRobot implements AbstractEmailLabelRobot {
  EmailLabelRobot(super.$);

  static final labelAsActionKey =
      ValueKey('${EmailActionType.labelAs.name}_action');

  @override
  Future<void> openLabelPicker() async {
    await $(const ValueKey(UiKeys.emailDetailedMoreButton)).tap();
    await $(labelAsActionKey).tap();
  }

  @override
  Future<void> selectLabel(String labelDisplayName) async {
    await $(const ValueKey(UiKeys.addLabelToEmailModal))
        .$(labelDisplayName)
        .tap();
  }
}
