import 'package:flutter/material.dart';
import 'package:labels/extensions/label_extension.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/email_subject_widget.dart';
import 'package:tmail_ui_user/features/labels/presentation/widgets/label_widget.dart';

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
  Future<void> expectLabelShownOnEmailSubject(String labelDisplayName) async {
    final labelOnSubject = $(EmailSubjectWidget).$(LabelWidget).which<LabelWidget>(
      (widget) => widget.label.safeDisplayName == labelDisplayName,
    );
    await waitForCondition(() => labelOnSubject.evaluate().isNotEmpty);
  }
}
