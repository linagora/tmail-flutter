
import 'package:jmap_dart_client/jmap/mail/calendar/properties/calendar_organizer.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';

extension CalendarOrganierExtension on CalendarOrganizer {
  EmailAddress toEmailAddress() {
    return EmailAddress(
      name, mailto?.value,
    );
  }
}