import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/attendance/calendar_event_attendance.dart';

/// Where the reader stands with an invitation.
class CalendarEventCardViewState with EquatableMixin {
  /// The address the card answers on behalf of.
  final String ownEmailAddress;

  /// Addresses the carrying email was sent from, used to resolve which
  /// attendee an activity message is about.
  final List<String> listEmailAddressSender;

  /// The answer already on record, or null while none has been given.
  final AttendanceStatus? attendanceStatus;

  /// Whether an answer is in flight, which holds the response pills.
  final bool replying;

  /// Whether the reader is busy elsewhere at this time.
  final bool hasScheduleConflict;

  const CalendarEventCardViewState({
    required this.ownEmailAddress,
    this.listEmailAddressSender = const [],
    this.attendanceStatus,
    this.replying = false,
    this.hasScheduleConflict = false,
  });

  @override
  List<Object?> get props => [
    ownEmailAddress,
    listEmailAddressSender,
    attendanceStatus,
    replying,
    hasScheduleConflict,
  ];
}
