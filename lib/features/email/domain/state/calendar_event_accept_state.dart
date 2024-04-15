import 'package:tmail_ui_user/features/email/domain/state/calendar_event_reply_state.dart';

class CalendarEventAccepting extends CalendarEventReplying {}

class CalendarEventAccepted extends CalendarEventReplySuccess {
  
  CalendarEventAccepted(super.calendarEventAcceptResponse);
}

class CalendarEventAcceptFailure extends CalendarEventReplyFailure {
  CalendarEventAcceptFailure({super.exception});
}