import 'package:jmap_dart_client/jmap/mail/calendar/reply/calendar_event_maybe_response.dart';
import 'package:tmail_ui_user/features/email/domain/state/calendar_event_reply_state.dart';

class CalendarEventMaybeReplying extends CalendarEventReplying {}

class CalendarEventMaybeSuccess extends CalendarEventReplySuccess {
  final CalendarEventMaybeResponse calendarEventMaybeResponse;
  
  CalendarEventMaybeSuccess(this.calendarEventMaybeResponse)
    : super(calendarEventMaybeResponse);
}

class CalendarEventMaybeFailure extends CalendarEventReplyFailure {
  CalendarEventMaybeFailure({super.exception});
}