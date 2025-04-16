import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/attendance/calendar_event_attendance.dart';
import 'package:tmail_ui_user/features/email/domain/state/calendar_event_accept_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/calendar_event_counter_accept_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/calendar_event_maybe_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/calendar_event_reject_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/parse_calendar_event_state.dart';
import 'package:tmail_ui_user/features/email/presentation/controller/single_email_controller.dart';

extension UpdateAttendanceStatusExtension on SingleEmailController {
  void updateAttendanceStatus(UIState viewState) {
    attendanceStatus.value = switch (viewState) {
      ParseCalendarEventSuccess(
        blobCalendarEventList: final blobCalendarEventList,
      ) => blobCalendarEventList.firstOrNull?.attendanceStatus,
      CalendarEventAccepted() => AttendanceStatus.accepted,
      CalendarEventMaybeSuccess() => AttendanceStatus.tentativelyAccepted,
      CalendarEventRejected() => AttendanceStatus.rejected,
      CalendarEventCounterAccepted() => AttendanceStatus.accepted,
      _ => attendanceStatus.value,
    };
  }
}