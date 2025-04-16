import '../../base/test_base.dart';
import '../../scenarios/calendar/calendar_event_counter_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should see yes and mail to attendees buttons '
      'and should not see no and maybe buttons '
      'when user view calendar event counter email',
    scenarioBuilder: ($) => CalendarEventCounterScenario($),
  );
}