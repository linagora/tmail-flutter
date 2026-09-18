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

    final allDayCases = [
      (
        description: 'keep a one-day all-day event whole',
        endDate: DateTime(2021, 10, 11),
        expectedDate: 'Sunday, October 10, 2021 (GMT+0)',
      ),
      (
        description: 'keep a multi-day all-day event whole',
        endDate: DateTime(2021, 10, 25),
        expectedDate:
            'Sunday, October 10, 2021 - Sunday, October 24, 2021 (GMT+0)',
      ),
    ];

    for (final testCase in allDayCases) {
      test('SHOULD ${testCase.description}', () {
        final parts = partsOf(
          buildEvent(DateTime(2021, 10, 10), testCase.endDate),
        );

        expect(parts.date, testCase.expectedDate);
        expect(parts.time, isNull);
      });
    }

    test('SHOULD keep a range spanning several days whole', () {
      final parts = partsOf(
        buildEvent(DateTime(2021, 10, 10, 8), DateTime(2021, 10, 11, 9)),
      );

      expect(parts.time, isNull);
      expect(parts.date, contains(' - '));
    });

    // Preserve the previous formatter's fallback when one boundary is absent.
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

    final actionCases = [
      (
        description:
            'return yes/maybe/no + mailToAttendees for a request to the user',
        method: EventMethod.request,
        participants: [matchingParticipant],
        expectedActions: [
          EventActionType.yes,
          EventActionType.maybe,
          EventActionType.no,
          EventActionType.mailToAttendees,
        ],
      ),
      (
        description:
            'return acceptCounter + mailToAttendees for a counter to the user',
        method: EventMethod.counter,
        participants: [matchingParticipant],
        expectedActions: [
          EventActionType.acceptCounter,
          EventActionType.mailToAttendees,
        ],
      ),
      (
        description: 'return only mailToAttendees for a non-repliable method',
        method: EventMethod.cancel,
        participants: [matchingParticipant],
        expectedActions: [EventActionType.mailToAttendees],
      ),
      (
        description:
            'return only mailToAttendees when the user is not a participant',
        method: EventMethod.request,
        participants: [nonMatchingParticipant],
        expectedActions: [EventActionType.mailToAttendees],
      ),
    ];

    for (final testCase in actionCases) {
      test('SHOULD ${testCase.description}', () {
        expectActions(
          method: testCase.method,
          participants: testCase.participants,
          expectedActions: testCase.expectedActions,
        );
      });
    }

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
