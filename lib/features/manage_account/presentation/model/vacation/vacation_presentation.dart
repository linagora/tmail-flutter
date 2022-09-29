
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:jmap_dart_client/jmap/core/utc_date.dart';
import 'package:jmap_dart_client/jmap/mail/vacation/vacation_response.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/datetime_extension.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/vacation/vacation_responder_status.dart';

class VacationPresentation with EquatableMixin {
  final VacationResponderStatus status;
  final DateTime? startDate;
  final TimeOfDay? startTime;
  final DateTime? endDate;
  final TimeOfDay? endTime;
  final String? messagePlainText;
  final String? messageHtmlText;
  final String? subject;
  final bool vacationStopEnabled;

  VacationPresentation({
    this.status = VacationResponderStatus.deactivated,
    this.startDate,
    this.startTime,
    this.endDate,
    this.endTime,
    this.messagePlainText,
    this.messageHtmlText,
    this.subject,
    this.vacationStopEnabled = false,
  });

  factory VacationPresentation.initialize() {
    return VacationPresentation();
  }

  VacationPresentation copyWidth({
     VacationResponderStatus? status,
     DateTime? startDate,
     TimeOfDay? startTime,
     DateTime? endDate,
     TimeOfDay? endTime,
     String? messagePlainText,
     String? messageHtmlText,
     String? subject,
     bool? vacationStopEnabled,
  }) {
    return VacationPresentation(
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      startTime: startTime ?? this.startTime,
      endDate: endDate ?? this.endDate,
      endTime: endTime ?? this.endTime,
      messagePlainText: messagePlainText ?? this.messagePlainText,
      messageHtmlText: messageHtmlText ?? this.messageHtmlText,
      subject: subject ?? this.subject,
      vacationStopEnabled: vacationStopEnabled ?? this.vacationStopEnabled
    );
  }

  bool get startDateIsNull => startDate == null;

  bool get starTimeIsNull => startTime == null;

  bool get endDateIsNull => endDate == null;

  bool get endTimeIsNull => endTime == null;

  DateTime? get fromDate => startDate.applied(startTime);

  DateTime? get toDate => endDate.applied(endTime);

  bool get isEnabled => status == VacationResponderStatus.activated;

  @override
  List<Object?> get props => [
    status,
    startDate,
    startTime,
    endDate,
    endTime,
    vacationStopEnabled,
    messagePlainText,
    messageHtmlText,
    subject,
  ];
}

extension VacationPresentationExtension on VacationPresentation {
  VacationResponse toVacationResponse() {
    return VacationResponse(
      isEnabled: isEnabled,
      fromDate: fromDate != null ? UTCDate(fromDate!.toUtc()) : null,
      toDate: toDate != null ? UTCDate(toDate!.toUtc()) : null,
      textBody: messagePlainText,
      htmlBody: messageHtmlText,
      subject: subject,
    );
  }
}