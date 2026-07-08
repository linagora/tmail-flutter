import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';

import '../base/core_robot.dart';
import 'abstract/abstract_email_twp_warning_robot.dart';

class EmailTwpWarningRobot extends CoreRobot
    implements AbstractEmailTwpWarningRobot {
  EmailTwpWarningRobot(super.$);

  @override
  Future<void> tapDismissWarning() async {
    await $(const Key('${UiKeys.twpWarningDismissButtonPrefix}0')).tap();
    await $.pumpAndSettle();
  }
}
