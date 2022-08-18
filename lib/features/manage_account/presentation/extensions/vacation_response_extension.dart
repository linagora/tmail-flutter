
import 'package:core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:jmap_dart_client/jmap/core/utc_date.dart';
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

  bool get vacationResponderIsReady {
    if (isEnabled == true) {
      final currentDate = DateTime.now().toUtc();
      log('VacationResponseExtension::vacationResponderEnabled(): currentDate: $currentDate');
      final startDate = fromDate?.value.toUtc();
      log('VacationResponseExtension::vacationResponderEnabled(): startDate: $startDate');
      if (startDate?.isBefore(currentDate) == true ||
          startDate?.isAtSameMomentAs(currentDate) == true) {
        return true;
      } else {
        return false;
      }
    }
    return false;
  }

  VacationResponse copyWith({
    bool? isEnabled,
    UTCDate? fromDate,
    UTCDate? toDate,
    String? subject,
    String? textBody,
    String? htmlBody
  }) {
    return VacationResponse(
      isEnabled: isEnabled ?? this.isEnabled,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      subject: subject ?? this.subject,
      textBody: textBody ?? this.textBody,
      htmlBody: htmlBody ?? this.htmlBody
    );
  }
}