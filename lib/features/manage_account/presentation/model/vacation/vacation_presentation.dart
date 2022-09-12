
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
  final String? messageBody;
  final String? subject;
  final bool vacationStopEnabled;

  VacationPresentation({
    this.status = VacationResponderStatus.deactivated,
    this.startDate,
    this.startTime,
    this.endDate,
    this.endTime,
    this.messageBody,
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
     String? messageBody,
     String? subject,
     bool? vacationStopEnabled,
  }) {
    return VacationPresentation(
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      startTime: startTime ?? this.startTime,
      endDate: endDate ?? this.endDate,
      endTime: endTime ?? this.endTime,
      messageBody: messageBody ?? this.messageBody,
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
    messageBody,
    subject,
  ];
}

extension VacationPresentationExtension on VacationPresentation {
  VacationResponse toVacationResponse() {
    return VacationResponse(
      isEnabled: isEnabled,
      fromDate: fromDate != null ? UTCDate(fromDate!) : null,
      toDate: toDate != null ? UTCDate(toDate!) : null,
      textBody: messageBody,
      subject: subject,
    );
  }
}