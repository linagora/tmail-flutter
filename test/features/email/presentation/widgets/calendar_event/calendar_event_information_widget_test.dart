import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/calendar_event.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/properties/attendee/calendar_attendee.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/properties/attendee/calendar_attendee_mail_to.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/properties/calendar_organizer.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/properties/mail_address.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/calendar_event/calendar_event_information_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../../../../fixtures/widget_fixtures.dart';

void main() {
  group('CalendarEventInformationWidget::', () {
    testWidgets(
      'Should show warning message\n'
      'when user is not in the participants\n'
      'and is not the organizer',
    (tester) async {
      // Arrange
      const ownEmail = 'user@example.com';
      final calendarEvent = CalendarEvent(
        organizer: CalendarOrganizer(
          mailto: MailAddress('organizer@example.com'),
        ),
        participants: [
          CalendarAttendee(
            mailto: CalendarAttendeeMailTo(MailAddress('participant@example.com')),
          )
        ],
      );

      // Act
      await tester.pumpWidget(
        WidgetFixtures.makeTestableWidget(
          child: Scaffold(
            body: CalendarEventInformationWidget(
              calendarEvent: calendarEvent,
              onCalendarEventReplyActionClick: (_) {},
              calendarEventReplying: false,
              isFree: false,
              ownEmailAddress: ownEmail,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(
        find.text(AppLocalizations().youAreNotInvitedToThisEventPleaseContactTheOrganizer),
        findsOneWidget,
      );
    });

    testWidgets(
      'Should NOT show warning message\n'
      'when user is in participants',
    (tester) async {
      // Arrange
      const ownEmail = 'user@example.com';
      final calendarEvent = CalendarEvent(
        organizer: CalendarOrganizer(
          mailto: MailAddress('organizer@example.com'),
        ),
        participants: [
          CalendarAttendee(
            mailto: CalendarAttendeeMailTo(MailAddress('participant@example.com')),
          ),
          CalendarAttendee(
            mailto: CalendarAttendeeMailTo(MailAddress(ownEmail)),
          ),
        ],
      );

      // Act
      await tester.pumpWidget(
        WidgetFixtures.makeTestableWidget(
          child: Scaffold(
            body: CalendarEventInformationWidget(
              calendarEvent: calendarEvent,
              onCalendarEventReplyActionClick: (_) {},
              calendarEventReplying: false,
              isFree: false,
              ownEmailAddress: ownEmail,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(
        find.text(AppLocalizations().youAreNotInvitedToThisEventPleaseContactTheOrganizer),
        findsNothing,
      );
    });

    testWidgets(
      'Should NOT show warning message\n'
      'when user is the organizer',
    (tester) async {
      // Arrange
      const ownEmail = 'user@example.com';
      final calendarEvent = CalendarEvent(
        organizer: CalendarOrganizer(
          mailto: MailAddress(ownEmail),
        ),
        participants: [
          CalendarAttendee(
            mailto: CalendarAttendeeMailTo(MailAddress('participant@example.com')),
          ),
        ],
      );

      // Act
      await tester.pumpWidget(
        WidgetFixtures.makeTestableWidget(
          child: Scaffold(
            body: CalendarEventInformationWidget(
              calendarEvent: calendarEvent,
              onCalendarEventReplyActionClick: (_) {},
              calendarEventReplying: false,
              isFree: false,
              ownEmailAddress: ownEmail,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(
        find.text(AppLocalizations().youAreNotInvitedToThisEventPleaseContactTheOrganizer),
        findsNothing,
      );
    });
  });
}
