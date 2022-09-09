
import 'package:core/utils/app_logger.dart';
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
      startDate: fromDate?.value.toUtc(),
      startTime: fromDate?.value != null
          ? TimeOfDay.fromDateTime(fromDate!.value.toUtc())
          : null,
      endDate: toDate?.value.toUtc(),
      endTime: toDate?.value != null
          ? TimeOfDay.fromDateTime(toDate!.value.toUtc())
          : null,
      messageBody: textBody ?? htmlBody,
      subject: subject,
      vacationStopEnabled: toDate != null
    );
  }

  bool get vacationResponderIsValid {
    return vacationResponderIsReady && !vacationResponderIsStopped;
  }

  bool get vacationResponderIsReady {
    if (isEnabled == true) {
      final currentDate = DateTime.now().toUtc();
      log('VacationResponseExtension::vacationResponderEnabled(): currentDate: $currentDate');
      final startDate = fromDate?.value.toUtc();
      log('VacationResponseExtension::vacationResponderEnabled(): startDate: $startDate');
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
      final currentDate = DateTime.now().toUtc();
      log('VacationResponseExtension::vacationResponderIsWaiting(): currentDate: $currentDate');
      final startDate = fromDate?.value.toUtc();
      log('VacationResponseExtension::vacationResponderIsWaiting(): startDate: $startDate');
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
      final currentDate = DateTime.now().toUtc();
      log('VacationResponseExtension::vacationResponderIsStopped(): currentDate: $currentDate');
      final endDate = toDate?.value.toUtc();
      log('VacationResponseExtension::vacationResponderIsStopped(): endDate: $endDate');
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
  
  String getNotificationMessage(BuildContext context) {
    if (vacationResponderIsValid) {
      return AppLocalizations.of(context).yourVacationResponderIsEnabled;
    } else if (vacationResponderIsWaiting) {
      return AppLocalizations.of(context).messageEnableVacationResponderAutomatically(
          fromDate.formatDate(
              pattern: 'MMM d, y h:mm a',
              locale: Localizations.localeOf(context).toLanguageTag()));
    } else if (vacationResponderIsStopped) {
      return AppLocalizations.of(context).messageDisableVacationResponderAutomatically(
          toDate.formatDate(
              pattern: 'MMM d, y h:mm a',
              locale: Localizations.localeOf(context).toLanguageTag()));
    } else {
      return '';
    }
  }
}