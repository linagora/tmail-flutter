
import 'package:flutter/material.dart';
import 'package:jmap_dart_client/jmap/mail/vacation/vacation_response.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/vacation/vacation_presentation.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/vacation/vacation_responder_status.dart';

extension VacationResponseExtension on VacationResponse {

  VacationPresentation toVacationPresentation() {
    return VacationPresentation(
      status: isEnabled == true
          ? VacationResponderStatus.activated
          : VacationResponderStatus.deactivated,
      startDate: fromDate?.value.toUtc(),
      startTime: fromDate?.value != null
          ? TimeOfDay.fromDateTime(fromDate!.value.toUtc())
          : null,
      endDate: toDate?.value.toUtc(),
      endTime: toDate?.value != null
          ? TimeOfDay.fromDateTime(toDate!.value.toUtc())
          : null,
      messageBody: textBody ?? htmlBody,
      vacationStopEnabled: toDate != null
    );
  }
}