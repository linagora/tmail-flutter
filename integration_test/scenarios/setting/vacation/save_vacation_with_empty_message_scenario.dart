import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';

import '../../../base/base_test_scenario.dart';
import '../../../robots/vacation_assertion_robot.dart';
import '../../../robots/vacation_robot.dart';

class SaveVacationWithEmptyMessageScenario extends BaseTestScenario {
  const SaveVacationWithEmptyMessageScenario(super.$, super.robots);

  @override
  Future<void> runTestLogic() async {
    final vacationRobot = VacationRobot($);
    final vacationAssertionRobot = VacationAssertionRobot($);

    await robots.mailboxMenuRobot().openSetting();
    await robots.settingsRobot().openSettingsDetail(AccountMenuItem.vacation);
    await vacationRobot.waitForMobileEditorReady();

    await vacationRobot.turnOnResponder();
    await vacationRobot.pickStartDate();
    await vacationRobot.pickStartTime();
    await vacationRobot.tapSave();

    await vacationAssertionRobot.expectEmptyMessageToastVisible();
    vacationAssertionRobot.expectSavedToastAbsent();
    vacationAssertionRobot.expectResponderNotEnabled();
  }
}
