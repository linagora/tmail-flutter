import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/calendar_event.dart';

class ParseCalendarEventLoading extends LoadingState {}

class ParseCalendarEventSuccess extends UIState {

  final List<CalendarEvent> calendarEventList;

  ParseCalendarEventSuccess(this.calendarEventList);

  @override
  List<Object> get props => [calendarEventList];
}

class ParseCalendarEventFailure extends FeatureFailure {
  ParseCalendarEventFailure(dynamic exception) : super(exception: exception);
}