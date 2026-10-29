import 'package:jmap_dart_client/jmap/mail/vacation/vacation_response.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';

import '../../../base/base_test_scenario.dart';
import '../../../robots/vacation_assertion_robot.dart';
import '../../../robots/web/web_vacation_robot.dart';
import '../../../utils/vacation_provisioner.dart';

class SaveVacationWithBlankStoredMessageScenario extends BaseTestScenario {
  const SaveVacationWithBlankStoredMessageScenario(super.$, super.robots);

  @override
  Future<void> runTestLogic() async {
    final vacationRobot = WebVacationRobot($);
    final vacationAssertionRobot = VacationAssertionRobot($);

    await robots.commonRobot().waitForMailboxReady();
    await VacationProvisioner().provision(
      VacationResponse(isEnabled: false, htmlBody: '<div><br></div>'),
    );

    await robots.mailboxMenuRobot().openSetting();
    await robots.settingsRobot().openSettingsDetail(AccountMenuItem.vacation);
    await vacationRobot.turnOnResponder();
    await vacationRobot.pickStartDate();
    await vacationRobot.pickStartTime();
    await vacationRobot.tapSave();

    await vacationAssertionRobot.expectEmptyMessageToastVisible();
  }
}
