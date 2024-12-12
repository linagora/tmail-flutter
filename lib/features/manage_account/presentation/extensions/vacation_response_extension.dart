
import 'package:flutter/material.dart';
import 'package:jmap_dart_client/jmap/core/utc_date.dart';
import 'package:jmap_dart_client/jmap/mail/vacation/vacation_response.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/vacation/vacation_presentation.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/vacation/vacation_responder_status.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

extension VacationResponseExtension on VacationResponse {

  VacationPresentation toVacationPresentation() {
    return VacationPresentation(
      status: isEnabled == true
          ? VacationResponderStatus.activated
          : VacationResponderStatus.deactivated,
      startDate: fromDate?.value.toLocal(),
      startTime: fromDate?.value != null
          ? TimeOfDay.fromDateTime(fromDate!.value.toLocal())
          : null,
      endDate: toDate?.value.toLocal(),
      endTime: toDate?.value != null
          ? TimeOfDay.fromDateTime(toDate!.value.toLocal())
          : null,
      messageHtmlText: htmlBody,
      subject: subject,
      vacationStopEnabled: toDate != null
    );
  }

  bool get vacationResponderIsValid {
    return vacationResponderIsReady && !vacationResponderIsStopped;
  }

  bool get vacationResponderIsReady {
    if (isEnabled == true) {
      final currentDate = DateTime.now();
      final startDate = fromDate?.value.toLocal();
      if (startDate != null && (startDate.isBefore(currentDate) ||
          startDate.isAtSameMomentAs(currentDate))) {
        return true;
      } else {
        return false;
      }
    }
    return false;
  }

  bool get vacationResponderIsWaiting {
    if (isEnabled == true) {
      final currentDate = DateTime.now();
      final startDate = fromDate?.value.toLocal();
      if (startDate != null && startDate.isAfter(currentDate)) {
        return true;
      } else {
        return false;
      }
    }
    return false;
  }

  bool get vacationResponderIsStopped {
    if (isEnabled == true) {
      final currentDate = DateTime.now();
      final endDate = toDate?.value.toLocal();
      if (endDate != null && endDate.isBefore(currentDate)) {
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
    String? htmlBody
  }) {
    return VacationResponse(
      isEnabled: isEnabled ?? this.isEnabled,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      subject: subject ?? this.subject,
      htmlBody: htmlBody ?? this.htmlBody
    );
  }
  
  String getNotificationMessage(BuildContext context) {
    if (vacationResponderIsValid) {
      return AppLocalizations.of(context).yourVacationResponderIsEnabled;
    } else if (vacationResponderIsWaiting) {
      return AppLocalizations.of(context).messageEnableVacationResponderAutomatically(
          fromDate.formatDateToLocal(
              pattern: 'MMM d, y h:mm a',
              locale: Localizations.localeOf(context).toLanguageTag()));
    } else if (vacationResponderIsStopped) {
      return AppLocalizations.of(context).messageDisableVacationResponderAutomatically(
          toDate.formatDateToLocal(
              pattern: 'MMM d, y h:mm a',
              locale: Localizations.localeOf(context).toLanguageTag()));
    } else {
      return '';
    }
  }
}