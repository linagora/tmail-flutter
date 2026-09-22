import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/extensions/calendar_url_extension.dart';

void main() {
  group('CalendarUrlExtension::resolveCalendarEventUrl', () {
    final validCases = [
      (
        description: 'an HTTPS origin',
        calendarUrl: 'https://calendar.example.com',
        expected: 'https://calendar.example.com/events/event-42',
      ),
      (
        description: 'a scheme-relative URL',
        calendarUrl: '//calendar.example.com/calendar',
        expected: 'https://calendar.example.com/calendar/events/event-42',
      ),
      (
        description: 'a qualified domain without a scheme',
        calendarUrl: 'calendar.example.com',
        expected: 'https://calendar.example.com/events/event-42',
      ),
      (
        description: 'an existing events path',
        calendarUrl: 'https://calendar.example.com/events/',
        expected: 'https://calendar.example.com/events/event-42',
      ),
      (
        description: 'an existing events path ending with two slashes',
        calendarUrl: 'https://calendar.example.com/events//',
        expected: 'https://calendar.example.com/events/event-42',
      ),
      (
        description: 'an encoded path segment',
        calendarUrl: 'https://calendar.example.com/calendar%20app',
        expected: 'https://calendar.example.com/calendar%20app/events/event-42',
      ),
      (
        description: 'an encoded slash inside a path segment',
        calendarUrl: 'https://calendar.example.com/tenant%2Fcalendar',
        expected:
            'https://calendar.example.com/tenant%2Fcalendar/events/event-42',
      ),
      (
        description: 'a fully encoded URL',
        calendarUrl:
            'https%3A%2F%2Fcalendar.example.com%2Fevents%2F',
        expected: 'https://calendar.example.com/events/event-42',
      ),
      (
        description: 'localhost without a scheme',
        calendarUrl: 'localhost:3000/calendar/',
        expected: 'http://localhost:3000/calendar/events/event-42',
      ),
    ];

    for (final testCase in validCases) {
      test('SHOULD resolve the event URL FROM ${testCase.description}', () {
        expect(
          testCase.calendarUrl.resolveCalendarEventUrl('event-42')?.toString(),
          testCase.expected,
        );
      });
    }

    test('SHOULD trim inputs and encode the UID as one path segment', () {
      expect(
        '  HTTPS://calendar.example.com:8443/calendar/  '
            .resolveCalendarEventUrl(' event/42 ')
            ?.toString(),
        'https://calendar.example.com:8443/calendar/events/event%2F42',
      );
    });

    final invalidCases = [
      (description: 'calendar URL is missing', calendarUrl: null, uid: 'event-42'),
      (description: 'calendar URL is blank', calendarUrl: '   ', uid: 'event-42'),
      (
        description: 'a public calendar URL uses HTTP',
        calendarUrl: 'http://calendar.example.com',
        uid: 'event-42',
      ),
      (
        description: 'calendar URL uses an unsafe scheme',
        calendarUrl: 'javascript:alert(1)',
        uid: 'event-42',
      ),
      (
        description: 'encoded calendar URL uses an unsafe scheme',
        calendarUrl: 'javascript%3Aalert%281%29',
        uid: 'event-42',
      ),
      (
        description: 'calendar URL contains malformed encoding',
        calendarUrl: 'https%3A%2F%2Fcalendar.example.com%ZZ',
        uid: 'event-42',
      ),
      (
        description: 'calendar URL contains a query',
        calendarUrl: 'https://calendar.example.com?tenant=one',
        uid: 'event-42',
      ),
      (
        description: 'calendar URL contains a fragment',
        calendarUrl: 'https://calendar.example.com#calendar',
        uid: 'event-42',
      ),
      (
        description: 'calendar URL is encoded twice',
        calendarUrl:
            'https%253A%252F%252Fcalendar.example.com%252Fevents%252F',
        uid: 'event-42',
      ),
      (
        description: 'event UID is missing',
        calendarUrl: 'https://calendar.example.com',
        uid: null,
      ),
      (
        description: 'event UID is blank',
        calendarUrl: 'https://calendar.example.com',
        uid: '   ',
      ),
    ];

    for (final testCase in invalidCases) {
      test('SHOULD return null WHEN ${testCase.description}', () {
        expect(
          testCase.calendarUrl.resolveCalendarEventUrl(testCase.uid),
          isNull,
        );
      });
    }
  });
}
