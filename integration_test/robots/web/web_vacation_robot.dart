import 'package:flutter/foundation.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';

import '../vacation_robot.dart';

class WebVacationRobot extends VacationRobot {
  WebVacationRobot(super.$);

  @override
  Future<void> tapSave() async {
    // Web desktop: scrollTo drives the first Scrollable on screen, not the form holding the button.
    final saveButton = $(const ValueKey(UiKeys.vacationSaveButton));
    await $.tester.ensureVisible(saveButton);
    await saveButton.tap();
  }
}
