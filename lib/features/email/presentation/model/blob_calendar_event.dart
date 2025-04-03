import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/attendance/calendar_event_attendance.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/calendar_event.dart';

class BlobCalendarEvent with EquatableMixin {
  final Id blobId;
  final List<CalendarEvent> calendarEventList;
  final bool isFree;
  final AttendanceStatus? attendanceStatus;

  BlobCalendarEvent({
    required this.blobId,
    required this.calendarEventList,
    this.isFree = true,
    this.attendanceStatus,
  });

  @override
  List<Object?> get props => [
    blobId,
    calendarEventList,
    isFree,
    attendanceStatus,
  ];
}