import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/utc_date.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';

class EmailFixtures {
  static final email1 = Email(
      EmailId(Id("382312d0-fa5c-11eb-b647-2fef1ee78d9e")),
      preview: "Dear QA,I attached image here",
      hasAttachment: false,
      subject: "test inline image",
      from: {EmailAddress("DatPH", "dphamhoang@linagora.com")},
      sentAt: UTCDate(DateTime.parse("2021-08-11T04:25:34Z")),
      receivedAt: UTCDate(DateTime.parse("2021-08-11T04:25:55Z")),
      keywords: {KeyWordIdentifier.emailSeen : true},
      to: {EmailAddress("DatVu", "tdvu@linagora.com")},
  );

  static final email2 = Email(
      EmailId(Id("bc8a5320-fa58-11eb-b647-2fef1ee78d9e")),
      preview: "This event is about to begin Noti check TimeFriday 23 October 2020 12:00 - 12:30 Europe/Paris (See in Calendar)Location1 thai ha (See in Map)Attendees - User A <usera@qa.open-paas.org> (Organizer) - Lê Nguyễn <userb@qa.open-paas.org> - User C <userc@qa.ope",
      hasAttachment: false,
      subject: "Notification: Noti check",
      from: {EmailAddress(null, "noreply@qa.open-paas.org")},
      sentAt: UTCDate(DateTime.parse("2021-08-10T09:45:01Z")),
      receivedAt: UTCDate(DateTime.parse("2021-08-11T04:00:59Z")),
      to: {EmailAddress("DatVu", "tdvu@facebook.com")},
  );

  static final email3 = Email(
      EmailId(Id("ba7e0860-fa58-11eb-b647-2fef1ee78d9e")),
      preview: "This event is about to begin Recurrencr TimeWednesday 26 August 2020 05:30 - 06:30 Europe/Paris (See in Calendar)Location1 thai ha (See in Map)Attendees - userb@qa.open-paas.org <userb@qa.open-paas.org> (Organizer) - User A <usera@qa.open-paas.org> Resourc",
      hasAttachment: false,
      subject: "Notification: Recurrencr",
      from: {EmailAddress(null, "noreply@qa.open-paas.org")},
      sentAt: UTCDate(DateTime.parse("2021-08-11T03:00:00Z")),
      receivedAt: UTCDate(DateTime.parse("2021-08-11T04:00:55Z")),
      keywords: {KeyWordIdentifier.emailFlagged : true},
      to: {EmailAddress("DatVu", "tdvu@gmail.com")},
  );

  static final email4 = Email(
      EmailId(Id("d9b3b880-fa6f-11eb-b647-2fef1ee78d9e")),
      preview: "alo -- desktop signature",
      hasAttachment: true,
      subject: "test attachment",
      from: {EmailAddress("Haaheoo", "userc@qa.open-paas.org")},
      sentAt: UTCDate(DateTime.parse("2021-08-11T06:46:25Z")),
      receivedAt: UTCDate(DateTime.parse("2021-08-11T06:46:26Z")),
      keywords: {KeyWordIdentifier.emailFlagged : true},
      to: {EmailAddress("DatVu", "tdvu@icloud.com")},
  );

  static final email5 = Email(
      EmailId(Id("637f1ef0-fa5d-11eb-b647-2fef1ee78d9e")),
      preview: "Dear, test inline Thanks and BRs-- desktop signature",
      hasAttachment: false,
      subject: "test inline image",
      from: {EmailAddress("Haaheoo", "userc@qa.open-paas.org")},
      sentAt: UTCDate(DateTime.parse("2021-08-11T04:34:13Z")),
      receivedAt: UTCDate(DateTime.parse("2021-08-11T04:34:17Z")),
      keywords: {KeyWordIdentifier.emailSeen : true},
      to: {EmailAddress("DatVu", "tdvu@yahoo.com")},
  );
}