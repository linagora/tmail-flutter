import 'package:jmap_dart_client/jmap/mail/calendar/attendance/calendar_event_attendance.dart';

/// Where the reader stands with an invitation.
class CalendarEventCardViewState {
  /// The address the card answers on behalf of (display / calendar URL).
  final String ownEmailAddress;

  /// "Me" match set of the shown mailbox (aliases included). Empty falls back
  /// to `{ownEmailAddress}`.
  final Set<String> ownerEmailAddresses;

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
    this.ownerEmailAddresses = const {},
    this.listEmailAddressSender = const [],
    this.attendanceStatus,
    this.replying = false,
    this.hasScheduleConflict = false,
  });

  Set<String> get meAddresses => ownerEmailAddresses.isNotEmpty
      ? ownerEmailAddresses
      : {if (ownEmailAddress.isNotEmpty) ownEmailAddress};
}
