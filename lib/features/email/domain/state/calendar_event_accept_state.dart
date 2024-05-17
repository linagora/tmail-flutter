import 'package:tmail_ui_user/features/email/domain/model/event_action.dart';
import 'package:tmail_ui_user/features/email/domain/state/calendar_event_reply_state.dart';

class CalendarEventAccepting extends CalendarEventReplying {}

class CalendarEventAccepted extends CalendarEventReplySuccess {

  CalendarEventAccepted(super.calendarEventAcceptResponse, super.emailId);

  @override
  EventActionType getEventActionType() => EventActionType.yes;
}

class CalendarEventAcceptFailure extends CalendarEventReplyFailure {
  CalendarEventAcceptFailure({super.exception});
}