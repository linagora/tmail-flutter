import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patrol/patrol.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';
import 'package:tmail_ui_user/features/base/widget/label_border_button_field.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/vacation/vacation_controller.dart';

import '../base/core_robot.dart';
import '../utils/wait_for_condition.dart';

class VacationRobot extends CoreRobot {
  VacationRobot(super.$);

  Future<void> waitForMobileEditorReady() async {
    // The editor sits in an AbsorbPointer while the responder is off, so it is never hit-testable here.
    await waitForCondition(() =>
        $(const ValueKey(UiKeys.vacationMessageEditorMobile)).exists &&
        Get.find<VacationController>().richTextControllerForMobile?.htmlEditorApi != null);
  }

  Future<void> waitForStoredMessageLoaded() async {
    // The web editor may normalize the stored body, so only wait for it to be non-empty.
    await waitForCondition(
      () => Get.find<VacationController>().vacationMessageHtmlText?.isNotEmpty == true,
    );
  }

  Future<void> turnOnResponder() async {
    await $(const ValueKey(UiKeys.vacationResponderSwitch)).$(InkWell).tap();
  }

  Future<void> pickStartDate() async {
    await $(LabelBorderButtonField<DateTime>).first.tap();
    await _confirmPicker($(DatePickerDialog));
  }

  Future<void> pickStartTime() async {
    await $(LabelBorderButtonField<TimeOfDay>).first.tap();
    await _confirmPicker($(TimePickerDialog));
  }

  Future<void> tapSave() async {
    await $(const ValueKey(UiKeys.vacationSaveButton)).scrollTo().tap();
  }

  Future<void> _confirmPicker(PatrolFinder dialog) async {
    await dialog.waitUntilVisible();
    final okLabel = MaterialLocalizations.of(dialog.evaluate().first).okButtonLabel;
    await dialog.$(okLabel).tap();
  }
}
