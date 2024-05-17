import 'package:tmail_ui_user/features/email/domain/model/event_action.dart';
import 'package:tmail_ui_user/features/email/domain/state/calendar_event_reply_state.dart';

class CalendarEventRejecting extends CalendarEventReplying {}

class CalendarEventRejected extends CalendarEventReplySuccess {

  CalendarEventRejected(super.calendarEventRejectResponse, super.emailId);

  @override
  EventActionType getEventActionType() => EventActionType.no;
}

class CalendarEventRejectFailure extends CalendarEventReplyFailure {
  CalendarEventRejectFailure({super.exception});
}