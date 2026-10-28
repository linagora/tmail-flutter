import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/manage_account_dashboard_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../../base/base_test_scenario.dart';
import '../../../robots/vacation_robot.dart';

class SaveVacationWithEmptyMessageScenario extends BaseTestScenario {
  const SaveVacationWithEmptyMessageScenario(super.$, super.robots);

  @override
  Future<void> runTestLogic() async {
    final vacationRobot = VacationRobot($);
    final appLocalizations = AppLocalizations();

    await robots.mailboxMenuRobot().openSetting();
    await robots.settingsRobot().openSettingsDetail(AccountMenuItem.vacation);
    await vacationRobot.waitForMobileEditorReady();

    await vacationRobot.turnOnResponder();
    await vacationRobot.pickStartDate();
    await vacationRobot.pickStartTime();
    await vacationRobot.tapSave();

    await expectViewVisible(
      $(find.text(appLocalizations.errorMessageWhenMessageVacationIsEmpty)),
    );
    await expectViewInvisible($(find.text(appLocalizations.vacationSettingSaved)));
    expect(
      Get.find<ManageAccountDashBoardController>().vacationResponse.value?.isEnabled,
      isNot(true),
    );
  }
}
