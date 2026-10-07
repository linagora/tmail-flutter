import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../base/core_robot.dart';
import '../utils/wait_for_condition.dart';
import 'abstract/abstract_email_assertion_robot.dart';

class EmailAssertionRobot extends CoreRobot
    implements AbstractEmailAssertionRobot {
  EmailAssertionRobot(super.$);

  @override
  Future<void> expectLabelPickerVisible() async {
    await $.waitUntilVisible($(const ValueKey(UiKeys.addLabelToEmailModal)));
  }

  @override
  Future<void> expectLabelAddedToast(String labelDisplayName) async {
    final message = AppLocalizations()
        .addLabelToEmailSuccessfullyMessage(labelDisplayName);
    await waitForCondition(() => $(message).evaluate().isNotEmpty);
  }
}
