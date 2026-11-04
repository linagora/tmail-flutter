import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/update_vacation_state.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/manage_account_dashboard_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/vacation/vacation_controller.dart';

import '../base/core_robot.dart';

class VacationAssertionRobot extends CoreRobot {
  VacationAssertionRobot(super.$);

  Future<void> expectSaveRejected() async {
    await $.pump(const Duration(seconds: 2));
    // Rules out the start and end date guards, so only the message check can have refused the save.
    final presentation = Get.find<VacationController>().vacationPresentation.value;
    expect(presentation.isEnabled, isTrue);
    expect(presentation.fromDate, isNotNull);
    expect(presentation.vacationStopEnabled, isFalse);
    // BaseController.onData keeps the last emitted state, so any update that ran leaves one of these.
    final state = Get.find<VacationController>().viewState.value.fold(
      (failure) => failure,
      (success) => success,
    );
    expect(state, isNot(isA<LoadingUpdateVacation>()));
    expect(state, isNot(isA<UpdateVacationSuccess>()));
    expect(state, isNot(isA<UpdateVacationFailure>()));
    expect(
      Get.find<ManageAccountDashBoardController>().vacationResponse.value?.isEnabled,
      isNot(true),
    );
  }
}
