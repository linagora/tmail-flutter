import 'package:jmap_dart_client/jmap/mail/calendar/properties/attendee/calendar_attendee.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/properties/calendar_organizer.dart';

extension ListAttendeeExtension on List<CalendarAttendee> {

  String get mailtoAsString {
    return map((attendee) => attendee.mailto?.mailAddress.value)
      .nonNulls
      .join(', ');
  }

  List<CalendarAttendee> withoutOrganizer(CalendarOrganizer? organizer) {
    if (organizer == null) {
      return this;
    }
    return where((attendee) => attendee.mailto?.mailAddress != organizer.mailto)
      .nonNulls
      .toList();
  }
}