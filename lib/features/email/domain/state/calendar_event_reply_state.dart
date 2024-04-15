import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/core/method/response/calendar_event_reply_response.dart';

class CalendarEventReplying extends LoadingState {}

class CalendarEventReplySuccess extends UIState {
  final CalendarEventReplyResponse calendarEventReplyResponse;

  CalendarEventReplySuccess(this.calendarEventReplyResponse);

  @override
  List<Object?> get props => [calendarEventReplyResponse];
}

class CalendarEventReplyFailure extends FeatureFailure {
  CalendarEventReplyFailure({super.exception});
}