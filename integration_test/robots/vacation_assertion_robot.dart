import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../base/core_robot.dart';

class VacationAssertionRobot extends CoreRobot {
  VacationAssertionRobot(super.$);

  Future<void> expectEmptyMessageToastVisible() async {
    await $(find.text(AppLocalizations().errorMessageWhenMessageVacationIsEmpty))
        .waitUntilVisible();
  }
}
