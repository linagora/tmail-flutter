import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/calendar_event.dart';
import 'package:tmail_ui_user/features/email/domain/model/event_action.dart';

class ParseCalendarEventLoading extends LoadingState {}

class ParseCalendarEventSuccess extends UIState {

  final List<CalendarEvent> calendarEventList;
  final List<EventAction> eventActionList;

  ParseCalendarEventSuccess(this.calendarEventList, this.eventActionList);

  @override
  List<Object> get props => [calendarEventList, eventActionList];
}

class ParseCalendarEventFailure extends FeatureFailure {
  ParseCalendarEventFailure(dynamic exception) : super(exception: exception);
}