import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/calendar_event.dart';
import 'package:tmail_ui_user/features/email/domain/model/event_action.dart';

class ParseCalendarEventLoading extends LoadingState {}

class ParseCalendarEventSuccess extends UIState {

  final Map<Id, List<CalendarEvent>> calendarEventMap;
  final List<EventAction> eventActionList;

  ParseCalendarEventSuccess(this.calendarEventMap, this.eventActionList);

  @override
  List<Object> get props => [calendarEventMap, eventActionList];
}

class ParseCalendarEventFailure extends FeatureFailure {
  ParseCalendarEventFailure(dynamic exception) : super(exception: exception);
}