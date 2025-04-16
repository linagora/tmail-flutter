import 'package:core/presentation/state/success.dart';
import 'package:tmail_ui_user/features/email/domain/model/event_action.dart';
import 'package:tmail_ui_user/features/email/domain/state/calendar_event_reply_state.dart';

class CalendarEventCounterAccepting extends LoadingState {}

class CalendarEventCounterAccepted extends CalendarEventReplySuccess {
  CalendarEventCounterAccepted(super.calendarEventAcceptResponse, super.emailId);

  @override
  EventActionType getEventActionType() => EventActionType.acceptCounter;
}

class CalendarEventCounterAcceptFailure extends CalendarEventReplyFailure {
  CalendarEventCounterAcceptFailure({super.exception});
}