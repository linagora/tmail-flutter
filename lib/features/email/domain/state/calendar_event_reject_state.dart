import 'package:jmap_dart_client/jmap/mail/calendar/reply/calendar_event_reject_response.dart';
import 'package:tmail_ui_user/features/email/domain/state/calendar_event_reply_state.dart';

class CalendarEventRejecting extends CalendarEventReplying {}

class CalendarEventRejected extends CalendarEventReplySuccess {
  final CalendarEventRejectResponse calendarEventRejectResponse;
  
  CalendarEventRejected(this.calendarEventRejectResponse)
    : super(calendarEventRejectResponse);
}

class CalendarEventRejectFailure extends CalendarEventReplyFailure {
  CalendarEventRejectFailure({super.exception});
}