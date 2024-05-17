import 'package:tmail_ui_user/features/email/domain/model/event_action.dart';
import 'package:tmail_ui_user/features/email/domain/state/calendar_event_reply_state.dart';

class CalendarEventMaybeReplying extends CalendarEventReplying {}

class CalendarEventMaybeSuccess extends CalendarEventReplySuccess {

  CalendarEventMaybeSuccess(super.calendarEventMaybeResponse, super.emailId);

  @override
  EventActionType getEventActionType() => EventActionType.maybe;
}

class CalendarEventMaybeFailure extends CalendarEventReplyFailure {
  CalendarEventMaybeFailure({super.exception});
}