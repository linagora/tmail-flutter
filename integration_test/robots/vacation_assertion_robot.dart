import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/manage_account_dashboard_controller.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../base/core_robot.dart';

class VacationAssertionRobot extends CoreRobot {
  VacationAssertionRobot(super.$);

  Future<void> expectEmptyMessageToastVisible() async {
    await $(find.text(AppLocalizations().errorMessageWhenMessageVacationIsEmpty))
        .waitUntilVisible();
  }

  void expectSavedToastAbsent() {
    expect($(find.text(AppLocalizations().vacationSettingSaved)), findsNothing);
  }

  void expectResponderNotEnabled() {
    expect(
      Get.find<ManageAccountDashBoardController>().vacationResponse.value?.isEnabled,
      isNot(true),
    );
  }
}
