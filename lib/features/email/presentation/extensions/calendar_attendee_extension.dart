
import 'package:jmap_dart_client/jmap/mail/calendar/properties/attendee/calendar_attendee.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';

extension CalendarAttendeeExtension on CalendarAttendee {
  EmailAddress toEmailAddress() {
    return EmailAddress(
      name?.name,
      mailto?.mailAddress.value,
    );
  }
}