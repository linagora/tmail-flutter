
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/vacation/vacation_responder_status.dart';

class VacationPresentation {
  final VacationResponderStatus status;
  final DateTime? startDate;
  final TimeOfDay? startTime;
  final DateTime? endDate;
  final TimeOfDay? endTime;
  final String? messageBody;
  final bool vacationStopEnabled;

  VacationPresentation({
    this.status = VacationResponderStatus.deactivated,
    this.startDate,
    this.startTime,
    this.endDate,
    this.endTime,
    this.messageBody,
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
     bool? vacationStopEnabled,
  }) {
    return VacationPresentation(
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      startTime: startTime ?? this.startTime,
      endDate: endDate ?? this.endDate,
      endTime: endTime ?? this.endTime,
      messageBody: messageBody ?? this.messageBody,
      vacationStopEnabled: vacationStopEnabled ?? this.vacationStopEnabled
    );
  }
}