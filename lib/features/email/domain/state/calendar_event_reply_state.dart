import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/core/method/response/calendar_event_reply_response.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/features/email/domain/model/event_action.dart';

class CalendarEventReplying extends LoadingState {}

abstract class CalendarEventReplySuccess extends UIState {
  final EmailId emailId;
  final CalendarEventReplyResponse calendarEventReplyResponse;

  CalendarEventReplySuccess(this.calendarEventReplyResponse, this.emailId);

  @override
  List<Object?> get props => [calendarEventReplyResponse, emailId];

  EventActionType getEventActionType();
}

class CalendarEventReplyFailure extends FeatureFailure {
  CalendarEventReplyFailure({super.exception});
}