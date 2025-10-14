import 'package:jmap_dart_client/jmap/mail/vacation/vacation_response.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/vacation_response_extension.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/manage_account_dashboard_controller.dart';

extension HandleVacationResponseExtension on ManageAccountDashBoardController {
  void syncVacationResponse(VacationResponse? newVacation) {
    if (newVacation?.vacationResponderIsStopped == true) {
      automaticallyDeactivateVacation(newVacation!);
    } else {
      setUpVacation(newVacation);
    }
  }

  void setUpVacation(VacationResponse? newVacation) {
    vacationResponse.value = newVacation;
  }

  void automaticallyDeactivateVacation(VacationResponse vacationResponse) {
    disableVacationResponder(vacationResponse, isAuto: true);
  }
}
