import '../../base/test_base.dart';
import '../../scenarios/calendar/mail_to_attendees_event_email_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should fill subject with reply prefix '
        'when user taps mail to attendees button '
        'on calendar event email',
    scenarioBuilder: ($, robots) => MailToAttendeesEventEmailScenario($, robots),
  );
}
