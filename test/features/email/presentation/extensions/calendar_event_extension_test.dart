import 'package:date_format/date_format.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:date_format/date_format.dart' as date_format;
import 'package:jmap_dart_client/jmap/core/utc_date.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/calendar_event.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/properties/attendee/calendar_attendee.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/properties/attendee/calendar_attendee_mail_to.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/properties/calendar_organizer.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/properties/event_method.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/properties/mail_address.dart';
import 'package:linagora_design_flutter/linagora_design_flutter.dart';
import 'package:tmail_ui_user/features/email/domain/model/event_action.dart';
import 'package:tmail_ui_user/features/email/presentation/extensions/calendar_event_extension.dart';

void main() {
  const ownerEmail = 'user@example.com';
  final matchingParticipant = CalendarAttendee(
    mailto: CalendarAttendeeMailTo(MailAddress(ownerEmail)),
  );
  final nonMatchingParticipant = CalendarAttendee(
    mailto: CalendarAttendeeMailTo(MailAddress('someone@else.com')),
  );

  group('calendar_event_extension::formatDateTime::test', () {
    final dateTime = DateTime(2021, 10, 10, 10, 30, 00, 00, 00);

    const locale = date_format.EnglishDateLocale();
    const expectedFormattedDateTime = 'Sunday, October 10, 2021 10:30 AM';
    const expectedFormattedTime = '10:30 AM';

    test('formatDateTime should return a string with format DD, MM dd, yyy hh:nn am', () {
      final calendarEvent = CalendarEvent(startDate: dateTime);

      final formattedDateTime = calendarEvent.formatDateTime(locale, dateTime);

      expect(formattedDateTime, expectedFormattedDateTime);
    });

    test('formatTime should return a string with format hh:nn', () {
      final calendarEvent = CalendarEvent(startDate: dateTime);

      final formattedTime = calendarEvent.formatTime(locale, dateTime);

      expect(formattedTime, expectedFormattedTime);
    });
  });

  group('calendar_event_extension::dateTimeEventAsString::test', () {
    void expectAllDayEvent({
      required DateTime endDate,
      required String expectedFormattedDateString,
    }) {
      final startDate = DateTime(2021, 10, 10, 00, 00, 00, 00, 00);
      final calendarEvent = CalendarEvent(
        startDate: startDate,
        endDate: endDate,
        startUtcDate: UTCDate(startDate),
        endUtcDate: UTCDate(endDate),
      );

      final formattedDateString = calendarEvent.getDateTimeEvent(
        timeZone: 'GMT+0',
        dateLocale: const EnglishDateLocale(),
      );

      expect(formattedDateString, expectedFormattedDateString);
    }

    test('dateTimeEventAsString should return string with format start date - end date (timezone offset) and date formatted as DD, MM dd, YYYY for all-day event for many days', () {
      expectAllDayEvent(
        endDate: DateTime(2021, 10, 25, 00, 00, 00, 00, 00),
        expectedFormattedDateString:
            'Sunday, October 10, 2021 - Sunday, October 24, 2021 (GMT+0)',
      );
    });

    test('dateTimeEventAsString should return string with format date (timezone offset) and date formatted as DD, MM dd, YYYY for all-day event for one day', () {
      expectAllDayEvent(
        endDate: DateTime(2021, 10, 11, 00, 00, 00, 00, 00),
        expectedFormattedDateString: 'Sunday, October 10, 2021 (GMT+0)',
      );
    });
  });

  group('calendar_event_extension::getDateTimeParts::test', () {
    CalendarEvent buildEvent(DateTime start, DateTime end) => CalendarEvent(
      startDate: start,
      endDate: end,
      startUtcDate: UTCDate(start),
      endUtcDate: UTCDate(end),
    );

    LinagoraEventDateTime partsOf(CalendarEvent event) => event.getDateTimeParts(
      timeZone: 'GMT+0',
      dateLocale: const EnglishDateLocale(),
    );

    test('SHOULD split the day from the clock time for a same-day event', () {
      final parts = partsOf(
        buildEvent(DateTime(2021, 10, 10, 8), DateTime(2021, 10, 10, 9)),
      );

      expect(parts.date, 'Sunday, October 10, 2021');
      expect(parts.time, '08:00 AM - 09:00 AM');
    });

    test('SHOULD keep an all-day event whole', () {
      final parts = partsOf(
        buildEvent(DateTime(2021, 10, 10), DateTime(2021, 10, 11)),
      );

      expect(parts.date, 'Sunday, October 10, 2021 (GMT+0)');
      expect(parts.time, isNull);
    });

    test('SHOULD keep a range spanning several days whole', () {
      final parts = partsOf(
        buildEvent(DateTime(2021, 10, 10, 8), DateTime(2021, 10, 11, 9)),
      );

      expect(parts.time, isNull);
      expect(parts.date, contains(' - '));
    });

    // An event can carry a duration instead of an end date, leaving one side
    // of the range empty.
    test('SHOULD split an event that carries only a start date', () {
      final start = DateTime(2021, 10, 10, 8);
      final parts = partsOf(CalendarEvent(
        startDate: start,
        startUtcDate: UTCDate(start),
      ));

      expect(parts.date, 'Sunday, October 10, 2021');
      expect(parts.time, '08:00 AM');
    });

    test('SHOULD split an event that carries only an end date', () {
      final end = DateTime(2021, 10, 10, 9);
      final parts = partsOf(CalendarEvent(
        endDate: end,
        endUtcDate: UTCDate(end),
      ));

      expect(parts.date, 'Sunday, October 10, 2021');
      expect(parts.time, '09:00 AM');
    });

    test('SHOULD read as the line it replaces', () {
      final event = buildEvent(
        DateTime(2021, 10, 10, 8),
        DateTime(2021, 10, 10, 9),
      );

      expect(
        partsOf(event).joined,
        event.getDateTimeEvent(
          timeZone: 'GMT+0',
          dateLocale: const EnglishDateLocale(),
        ),
      );
    });
  });

  group('isDisplayedEventReplyAction', () {
    test('returns true when all conditions are met and user is in participants', () {
      final event = CalendarEvent(
        method: EventMethod.request,
        organizer: CalendarOrganizer(mailto: MailAddress(ownerEmail)),
        participants: [matchingParticipant],
      );

      expect(event.isDisplayedEventReplyAction(ownerEmail), isTrue);
    });

    test('returns false when method is null', () {
      final event = CalendarEvent(
        method: null,
        organizer: CalendarOrganizer(mailto: MailAddress(ownerEmail)),
        participants: [matchingParticipant],
      );

      expect(event.isDisplayedEventReplyAction(ownerEmail), isFalse);
    });

    test('returns false when method is not repliable', () {
      final event = CalendarEvent(
        method: EventMethod.cancel,
        organizer: CalendarOrganizer(mailto: MailAddress(ownerEmail)),
        participants: [matchingParticipant],
      );

      expect(event.isDisplayedEventReplyAction(ownerEmail), isFalse);
    });

    test('returns false when organizer is null', () {
      final event = CalendarEvent(
        method: EventMethod.request,
        organizer: null,
        participants: [matchingParticipant],
      );

      expect(event.isDisplayedEventReplyAction(ownerEmail), isFalse);
    });

    test('returns false when participants is empty', () {
      final event = CalendarEvent(
        method: EventMethod.request,
        organizer: CalendarOrganizer(mailto: MailAddress(ownerEmail)),
        participants: [],
      );

      expect(event.isDisplayedEventReplyAction(ownerEmail), isFalse);
    });

    test('returns false when participants is null', () {
      final event = CalendarEvent(
        method: EventMethod.request,
        organizer: CalendarOrganizer(mailto: MailAddress(ownerEmail)),
        participants: null,
      );

      expect(event.isDisplayedEventReplyAction(ownerEmail), isFalse);
    });

    test('returns false when user is NOT listed in participants', () {
      final event = CalendarEvent(
        method: EventMethod.request,
        organizer: CalendarOrganizer(mailto: MailAddress(ownerEmail)),
        participants: [nonMatchingParticipant],
      );

      expect(event.isDisplayedEventReplyAction(ownerEmail), isFalse);
    });
  });

  group('calendar_event_extension::getEventActionTypesIsDisplayed:', () {
    void expectActions({
      required EventMethod method,
      required List<CalendarAttendee> participants,
      required List<EventActionType> expectedActions,
    }) {
      final event = CalendarEvent(
        method: method,
        organizer: CalendarOrganizer(mailto: MailAddress(ownerEmail)),
        participants: participants,
      );

      expect(
        event.getEventActionTypesIsDisplayed(ownerEmail),
        expectedActions,
      );
    }

    test('Should returns yes/maybe/no + mailToAttendees when method is request and user is in participants', () {
      expectActions(
        method: EventMethod.request,
        participants: [matchingParticipant],
        expectedActions: [
          EventActionType.yes,
          EventActionType.maybe,
          EventActionType.no,
          EventActionType.mailToAttendees,
        ],
      );
    });

    test('Should returns acceptCounter + mailToAttendees when method is counter and user is in participants', () {
      expectActions(
        method: EventMethod.counter,
        participants: [matchingParticipant],
        expectedActions: [
          EventActionType.acceptCounter,
          EventActionType.mailToAttendees,
        ],
      );
    });

    test('Should returns only mailToAttendees when method is not repliable but organizer is present', () {
      expectActions(
        method: EventMethod.cancel,
        participants: [matchingParticipant],
        expectedActions: [EventActionType.mailToAttendees],
      );
    });

    test('Should returns only mailToAttendees when user is NOT in participants but organizer is present', () {
      expectActions(
        method: EventMethod.request,
        participants: [nonMatchingParticipant],
        expectedActions: [EventActionType.mailToAttendees],
      );
    });

    test('Should returns empty list when no organizer and no participants', () {
      final event = CalendarEvent(
        method: EventMethod.request,
        organizer: null,
        participants: null,
      );

      final actions = event.getEventActionTypesIsDisplayed(ownerEmail);

      expect(actions, []);
    });
  });
}
