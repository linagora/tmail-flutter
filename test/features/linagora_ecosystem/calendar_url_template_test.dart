import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/calendar_url_template.dart';

void main() {
  group('CalendarUrlTemplate::resolveEventUrl', () {
    group('UID placeholder', () {
      final uidPlaceholderCases = <_IdentityUrlCase>[
        (
          description: 'resolve the canonical template',
          template: 'https://{localPart}.{domainName}/events/{UID}',
          ownerEmail: 'john.doe@example.com',
          domainName: null,
          expected: 'https://johndoe.example.com/events/event-42',
        ),
        (
          description: 'resolve only the localPart placeholder',
          template: 'https://{localPart}.example.com/events/{UID}',
          ownerEmail: 'john.doe@example.com',
          domainName: null,
          expected: 'https://johndoe.example.com/events/event-42',
        ),
        (
          description: 'resolve only the domainName placeholder',
          template: 'https://calendar.{domainName}/events/{UID}',
          ownerEmail: 'john.doe@example.com',
          domainName: 'tenant.example.com',
          expected: 'https://calendar.tenant.example.com/events/event-42',
        ),
        (
          description: 'resolve a lowercase UID placeholder',
          template: 'https://calendar.example.com/events/{uid}',
          ownerEmail: 'john.doe@example.com',
          domainName: null,
          expected: 'https://calendar.example.com/events/event-42',
        ),
        (
          description: 'resolve a mixed-case UID placeholder',
          template: 'https://calendar.example.com/events/{uId}',
          ownerEmail: 'john.doe@example.com',
          domainName: null,
          expected: 'https://calendar.example.com/events/event-42',
        ),
        (
          description: 'resolve a UID placeholder without events path',
          template: 'https://calendar.example.com/calendar/{UID}/details',
          ownerEmail: 'john.doe@example.com',
          domainName: null,
          expected: 'https://calendar.example.com/calendar/event-42/details',
        ),
        (
          description: 'resolve a UID placeholder inside the host',
          template: 'https://calendar-{UID}.example.com/details',
          ownerEmail: 'john.doe@example.com',
          domainName: null,
          expected: 'https://calendar-event-42.example.com/details',
        ),
        (
          description: 'resolve a UID placeholder inside a path segment',
          template:
              'https://calendar.example.com/items/prefix-{UID}-suffix/details',
          ownerEmail: 'john.doe@example.com',
          domainName: null,
          expected:
              'https://calendar.example.com/items/prefix-event-42-suffix/details',
        ),
        (
          description: 'resolve a path after the UID placeholder',
          template: 'https://calendar.example.com/events/{UID}/details/',
          ownerEmail: 'john.doe@example.com',
          domainName: null,
          expected: 'https://calendar.example.com/events/event-42/details/',
        ),
        (
          description: 'resolve multiple UID placeholders',
          template: 'https://calendar-{UID}.example.com/events/{uid}',
          ownerEmail: 'john.doe@example.com',
          domainName: null,
          expected: 'https://calendar-event-42.example.com/events/event-42',
        ),
        (
          description: 'resolve additional query and fragment strings',
          template:
              'https://calendar.example.com/events/{UID}?source={uid}#details',
          ownerEmail: 'john.doe@example.com',
          domainName: null,
          expected:
              'https://calendar.example.com/events/event-42?source=event-42#details',
        ),
        (
          description: 'preserve plain UID text',
          template: 'https://calendar.example.com/uid/myuid/{UID}',
          ownerEmail: 'john.doe@example.com',
          domainName: null,
          expected: 'https://calendar.example.com/uid/myuid/event-42',
        ),
        (
          description: 'resolve the documented prefixed host template',
          template:
              'https://dab-{localPart}.{domainName}/events/{UID}/details/',
          ownerEmail: 'john.doe@example.com',
          domainName: null,
          expected: 'https://dab-johndoe.example.com/events/event-42/details/',
        ),
        (
          description: 'use an explicit domainName',
          template: 'https://{localPart}.{domainName}/events/{UID}',
          ownerEmail: 'john.doe@example.com',
          domainName: ' tenant.example.com ',
          expected: 'https://johndoe.tenant.example.com/events/event-42',
        ),
        (
          description: 'resolve encoded identity placeholders',
          template:
              'https://%7BlocalPart%7D.%7BdomainName%7D/events/{UID}',
          ownerEmail: 'john.doe@example.com',
          domainName: null,
          expected: 'https://johndoe.example.com/events/event-42',
        ),
        (
          description: 'resolve the encoded domainPart alias',
          template: 'https://%7BlocalPart%7D.%7BdomainPart%7D/events/{UID}',
          ownerEmail: 'john.doe@example.com',
          domainName: null,
          expected: 'https://johndoe.example.com/events/event-42',
        ),
        (
          description: 'resolve the encoded lowercase localPart placeholder',
          template:
              'https://%7Blocalpart%7D-calendar.example.com/events/{UID}',
          ownerEmail: 'john.doe@example.com',
          domainName: null,
          expected:
              'https://johndoe-calendar.example.com/events/event-42',
        ),
        (
          description: 'resolve mixed-case identity placeholders',
          template:
              'https://{LoCaLpArT}.{DoMaInNaMe}/events/{UID}',
          ownerEmail: 'john.doe@example.com',
          domainName: null,
          expected: 'https://johndoe.example.com/events/event-42',
        ),
        (
          description: 'resolve encoded mixed-case identity placeholders',
          template:
              'https://%7BLoCaLpArT%7D.%7BDoMaInNaMe%7D/events/{UID}',
          ownerEmail: 'john.doe@example.com',
          domainName: null,
          expected: 'https://johndoe.example.com/events/event-42',
        ),
        (
          description: 'resolve repeated mixed identity placeholders',
          template:
              'https://{localPart}.%7BdomainName%7D/users/{localPart}/%7BdomainName%7D/events/{UID}',
          ownerEmail: 'john.doe@example.com',
          domainName: null,
          expected:
              'https://johndoe.example.com/users/johndoe/example.com/events/event-42',
        ),
        (
          description:
              'not reinterpret a placeholder-like localPart as UID',
          template:
              'https://calendar.example.com/users/{localPart}/events/{UID}',
          ownerEmail: '{uid}@example.com',
          domainName: null,
          expected:
              'https://calendar.example.com/users/%7Buid%7D/events/event-42',
        ),
        (
          description: 'return null for a blank explicit domainName',
          template: 'https://{localPart}.{domainName}/events/{UID}',
          ownerEmail: 'john.doe@example.com',
          domainName: '   ',
          expected: null,
        ),
      ];

      _registerIdentityUrlTests(uidPlaceholderCases);

      final eventUidCases = <_EventUidCase>[
        (
          description: 'encode a slash as one path segment',
          template: 'https://calendar.example.com/events/{UID}',
          uid: 'event/42',
          expected: 'https://calendar.example.com/events/event%2F42',
        ),
        (
          description: 'encode a question mark',
          template: 'https://calendar.example.com/events/{UID}',
          uid: 'event?42',
          expected: 'https://calendar.example.com/events/event%3F42',
        ),
        (
          description: 'encode a fragment marker',
          template: 'https://calendar.example.com/events/{UID}',
          uid: 'event#42',
          expected: 'https://calendar.example.com/events/event%2342',
        ),
        (
          description: 'encode an internal space',
          template: 'https://calendar.example.com/events/{UID}',
          uid: 'event 42',
          expected: 'https://calendar.example.com/events/event%2042',
        ),
        (
          description: 'encode Unicode',
          template: 'https://calendar.example.com/events/{UID}',
          uid: 'event-📅',
          expected:
              'https://calendar.example.com/events/event-%F0%9F%93%85',
        ),
        (
          description: 'preserve surrounding spaces with a UID placeholder',
          template: 'https://calendar.example.com/events/{UID}',
          uid: ' event-42 ',
          expected: 'https://calendar.example.com/events/%20event-42%20',
        ),
        (
          description: 'preserve surrounding spaces when appending the UID',
          template: 'https://calendar.example.com/events',
          uid: ' event-42 ',
          expected: 'https://calendar.example.com/events/%20event-42%20',
        ),
        (
          description: 'reject dot with a UID placeholder',
          template: 'https://calendar.example.com/events/{UID}',
          uid: '.',
          expected: null,
        ),
        (
          description: 'reject dot when appending the UID',
          template: 'https://calendar.example.com/events',
          uid: '.',
          expected: null,
        ),
        (
          description: 'reject dot-dot with a UID placeholder',
          template: 'https://calendar.example.com/events/{UID}',
          uid: '..',
          expected: null,
        ),
        (
          description: 'reject dot-dot when appending the UID',
          template: 'https://calendar.example.com/events',
          uid: '..',
          expected: null,
        ),
      ];

      for (final testCase in eventUidCases) {
        test(
          'SHOULD ${testCase.description}',
          () => _expectEventUidCase(testCase),
        );
      }

      test('SHOULD preserve an encoded UID literal', () {
        expect(
          const CalendarUrlTemplate(
            'https://calendar.example.com/events/{UID}/%7Buid%7D',
          ).resolveEventUrl(
            const CalendarEventUrlRequest(eventUid: 'event-42'),
          ),
          'https://calendar.example.com/events/event-42/%7Buid%7D',
        );
      });
    });

    group('missing UID placeholder', () {
      final baseUrlCases = [
        (
          description: 'origin',
          template: 'https://calendar.example.com',
          expected: 'https://calendar.example.com/events/event-42',
        ),
        (
          description: 'qualified host without scheme',
          template: 'calendar.example.com',
          expected: 'https://calendar.example.com/events/event-42',
        ),
        (
          description: 'scheme-relative URL',
          template: '//calendar.example.com',
          expected: 'https://calendar.example.com/events/event-42',
        ),
        (
          description: 'existing path',
          template: 'https://calendar.example.com/calendar/',
          expected:
              'https://calendar.example.com/calendar/events/event-42',
        ),
        (
          description: 'events path',
          template: 'https://calendar.example.com/events/',
          expected: 'https://calendar.example.com/events/event-42',
        ),
        (
          description: 'events path with extra trailing slash',
          template: 'https://calendar.example.com/events//',
          expected: 'https://calendar.example.com/events/event-42',
        ),
        (
          description: 'query and fragment',
          template:
              'https://calendar.example.com/calendar?view=month#section',
          expected:
              'https://calendar.example.com/calendar/events/event-42?view=month#section',
        ),
        (
          description: 'explicit localhost URL',
          template: 'http://localhost:3000/calendar',
          expected: 'http://localhost:3000/calendar/events/event-42',
        ),
      ];

      for (final testCase in baseUrlCases) {
        test('SHOULD append the event path to ${testCase.description}', () {
          expect(
            CalendarUrlTemplate(testCase.template).resolveEventUrl(
              const CalendarEventUrlRequest(eventUid: 'event-42'),
            ),
            testCase.expected,
          );
        });
      }

      final identityBaseUrlCases = <_IdentityUrlCase>[
        (
          description: 'resolve canonical identity placeholders before appending',
          template: 'https://dab-{localPart}.{domainName}/calendar',
          ownerEmail: 'john.doe@example.com',
          domainName: null,
          expected:
              'https://dab-johndoe.example.com/calendar/events/event-42',
        ),
        (
          description: 'resolve lowercase localPart without a scheme before appending',
          template: '{localpart}-calendar.domain.com',
          ownerEmail: 'john.doe@example.com',
          domainName: null,
          expected: 'https://johndoe-calendar.domain.com/events/event-42',
        ),
      ];

      _registerIdentityUrlTests(identityBaseUrlCases);

      test('SHOULD treat an encoded UID placeholder as a literal', () {
        expect(
          const CalendarUrlTemplate(
            'https://calendar.example.com/%7Buid%7D',
          ).resolveEventUrl(
            const CalendarEventUrlRequest(eventUid: 'event-42'),
          ),
          'https://calendar.example.com/%7Buid%7D/events/event-42',
        );
      });
    });

    group('invalid input or configuration', () {
      final invalidCases = <({
        String description,
        String template,
        String? eventUid,
        String? ownerEmail,
      })>[
        (
          description: 'template is empty',
          template: '',
          eventUid: 'event-42',
          ownerEmail: null,
        ),
        (
          description: 'template is blank',
          template: '   ',
          eventUid: 'event-42',
          ownerEmail: null,
        ),
        (
          description: 'event UID is missing',
          template: 'https://calendar.example.com',
          eventUid: null,
          ownerEmail: null,
        ),
        (
          description: 'event UID is blank',
          template: 'https://calendar.example.com',
          eventUid: '   ',
          ownerEmail: null,
        ),
        (
          description: 'public URL uses HTTP',
          template: 'http://calendar.example.com',
          eventUid: 'event-42',
          ownerEmail: null,
        ),
        (
          description: 'URL is an unqualified host',
          template: 'calendar',
          eventUid: 'event-42',
          ownerEmail: null,
        ),
        (
          description: 'URL uses an unsafe scheme',
          template: 'javascript:alert(1)',
          eventUid: 'event-42',
          ownerEmail: null,
        ),
        (
          description: 'URL contains user info',
          template: 'https://user@calendar.example.com',
          eventUid: 'event-42',
          ownerEmail: null,
        ),
        (
          description: 'URL contains an invalid port',
          template: 'https://calendar.example.com:65536',
          eventUid: 'event-42',
          ownerEmail: null,
        ),
        (
          description: 'URL is fully encoded',
          template: 'https%3A%2F%2Fcalendar.example.com%2Fevents',
          eventUid: 'event-42',
          ownerEmail: null,
        ),
        (
          description: 'URL contains a malformed percent escape',
          template: 'https://calendar.example.com/%ZZ',
          eventUid: 'event-42',
          ownerEmail: null,
        ),
        (
          description: 'identity placeholder cannot be resolved',
          template: 'https://{localPart}.example.com/events/{UID}',
          eventUid: 'event-42',
          ownerEmail: null,
        ),
        (
          description: 'placeholder is unsupported',
          template: 'https://calendar.{domain}/events/{UID}',
          eventUid: 'event-42',
          ownerEmail: 'john.doe@example.com',
        ),
        (
          description: 'placeholder is malformed',
          template: 'https://calendar.example.com/events/{UID',
          eventUid: 'event-42',
          ownerEmail: null,
        ),
        (
          description: 'placeholder markers are mixed',
          template: 'https://calendar.example.com/events/{UID%7D',
          eventUid: 'event-42',
          ownerEmail: null,
        ),
      ];

      for (final testCase in invalidCases) {
        test('SHOULD return null WHEN ${testCase.description}', () {
          expect(
            CalendarUrlTemplate(testCase.template).resolveEventUrl(
              CalendarEventUrlRequest(
                eventUid: testCase.eventUid,
                ownerEmail: testCase.ownerEmail,
              ),
            ),
            isNull,
          );
        });
      }
    });
  });
}

typedef _IdentityUrlCase = ({
  String description,
  String template,
  String ownerEmail,
  String? domainName,
  String? expected,
});

typedef _EventUidCase = ({
  String description,
  String template,
  String uid,
  String? expected,
});

void _registerIdentityUrlTests(List<_IdentityUrlCase> testCases) {
  for (final testCase in testCases) {
    test('SHOULD ${testCase.description}', () {
      expect(
        CalendarUrlTemplate(testCase.template).resolveEventUrl(
          CalendarEventUrlRequest(
            eventUid: 'event-42',
            ownerEmail: testCase.ownerEmail,
            domainName: testCase.domainName,
          ),
        ),
        testCase.expected,
      );
    });
  }
}

void _expectEventUidCase(_EventUidCase testCase) {
  expect(
    CalendarUrlTemplate(testCase.template).resolveEventUrl(
      CalendarEventUrlRequest(eventUid: testCase.uid),
    ),
    testCase.expected,
  );
}
