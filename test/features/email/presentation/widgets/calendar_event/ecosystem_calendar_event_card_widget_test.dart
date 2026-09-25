import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/calendar_event.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/properties/attendee/calendar_attendee.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/properties/attendee/calendar_attendee_mail_to.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/properties/calendar_organizer.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/properties/event_id.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/properties/event_method.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/properties/mail_address.dart';
import 'package:tmail_ui_user/features/email/presentation/model/calendar_event_card_actions.dart';
import 'package:tmail_ui_user/features/email/presentation/model/calendar_event_card_view_state.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/calendar_event/ecosystem_calendar_event_card_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/api_url_linagora_ecosystem.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/linagora_ecosystem.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/linagora_ecosystem_identifier.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/providers/active_ecosystem_provider.dart';
import 'package:tmail_ui_user/features/paywall/presentation/providers/premium_cta_provider.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../../../../fixtures/widget_fixtures.dart';

void main() {
  _registerAvailableEcosystemTests();
  _registerUnavailableEcosystemTest();
}

void _registerAvailableEcosystemTests() {
  final testCases = <_AvailableEcosystemCase>[
    (
      description: 'canonical calendar URL template',
      template: 'https://calendar.{domainName}/app/events/{UID}',
      expected: 'https://calendar.example.invalid/app/events/event-42',
    ),
    (
      description: 'lowercase localPart template without a scheme',
      template: '{localpart}-calendar.example.invalid',
      expected: 'https://reader-calendar.example.invalid/events/event-42',
    ),
  ];

  for (final testCase in testCases) {
    testWidgets(
      'SHOULD use ${testCase.description} to open the event',
      (tester) => _expectCalendarUrlOpens(tester, testCase),
    );
  }
}

Future<void> _expectCalendarUrlOpens(
  WidgetTester tester,
  _AvailableEcosystemCase testCase,
) async {
  final accountId = AccountId(Id('account-id'));
  const jmapUrl = 'https://jmap.example.invalid';
  final observedKeys = <(AccountId?, String?)>[];
  final openedLinks = <String>[];
  final container = ProviderContainer(overrides: [
    activeEcosystemProvider.overrideWith((ref, args) {
      observedKeys.add(args);
      return EcosystemAvailable(LinagoraEcosystem({
        LinagoraEcosystemIdentifier.calendarUrlTemplate:
            ApiUrlLinagoraEcosystem(testCase.template),
      }));
    }),
  ]);
  addTearDown(container.dispose);

  await tester.pumpWidget(WidgetFixtures.makeTestableWidget(
    providerContainer: container,
    child: _card(
      accountId: accountId,
      jmapUrl: jmapUrl,
      openedLinks: openedLinks,
    ),
  ));
  await tester.pumpAndSettle();

  await tester.tap(find.text(AppLocalizations().seeInYourCalendar));
  await tester.pump();

  expect(observedKeys, [(accountId, jmapUrl)]);
  expect(openedLinks, [testCase.expected]);
}

void _registerUnavailableEcosystemTest() {
  testWidgets(
    'SHOULD hide the calendar action WHEN the active ecosystem is unavailable',
    (tester) async {
      final container = ProviderContainer(overrides: [
        activeEcosystemProvider.overrideWith((ref, args) =>
            const EcosystemUnavailable(
              EcosystemUnavailableReason.loadFailed,
            )),
      ]);
      addTearDown(container.dispose);

      await tester.pumpWidget(WidgetFixtures.makeTestableWidget(
        providerContainer: container,
        child: _card(
          accountId: AccountId(Id('account-id')),
          jmapUrl: 'https://jmap.example.invalid',
          openedLinks: [],
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text(AppLocalizations().seeInYourCalendar), findsNothing);
    },
  );
}

typedef _AvailableEcosystemCase = ({
  String description,
  String template,
  String expected,
});

EcosystemCalendarEventCardWidget _card({
  required AccountId accountId,
  required String jmapUrl,
  required List<String> openedLinks,
}) {
  return EcosystemCalendarEventCardWidget(
    accountId: accountId,
    jmapUrl: jmapUrl,
    calendarEvent: CalendarEvent(
      eventId: EventId('event-42'),
      method: EventMethod.request,
      organizer: CalendarOrganizer(
        mailto: MailAddress('organizer@example.invalid'),
      ),
      participants: [
        CalendarAttendee(
          mailto: CalendarAttendeeMailTo(
            MailAddress('reader@example.invalid'),
          ),
        ),
      ],
    ),
    viewState: const CalendarEventCardViewState(
      ownEmailAddress: 'reader@example.invalid',
      listEmailAddressSender: [],
      replying: false,
      hasScheduleConflict: false,
    ),
    actions: CalendarEventCardActions(
      onReply: (_) {},
      onMailToAttendees: () {},
      onOpenLink: openedLinks.add,
    ),
  );
}
