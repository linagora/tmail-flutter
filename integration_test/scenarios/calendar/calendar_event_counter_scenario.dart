import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/calendar_event/calendar_event_card_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../base/base_test_scenario.dart';
import '../../mixin/open_calendar_event_scenario_mixin.dart';
import '../../robots/search_robot.dart';
import '../../robots/thread_robot.dart';

class CalendarEventCounterScenario extends BaseTestScenario
    with OpenCalendarEventScenarioMixin {
  const CalendarEventCounterScenario(super.$, super.robots);

  @override
  Future<void> runTestLogic() async {
    final threadRobot = ThreadRobot($);
    final searchRobot = SearchRobot($);
    final appLocalizations = AppLocalizations();

    await openCalendarEvent(
      threadRobot: threadRobot,
      searchRobot: searchRobot,
      appLocalizations: appLocalizations,
    );
    await _expectProposedEventChangesTextVisible(appLocalizations);
  }

  Future<void> _expectProposedEventChangesTextVisible(
    AppLocalizations appLocalizations,
  ) async {
    // The activity badge splits the actor from the message, so the run is
    // matched by its message half rather than the joined sentence.
    final proposedEventChangesText = $(CalendarEventCardWidget).$(
      find.textContaining(
        appLocalizations.messageEventActionBannerAttendeeCounter.trim(),
      ),
    );
    await proposedEventChangesText.scrollTo(scrollDirection: AxisDirection.down);
    await expectViewVisible(proposedEventChangesText);
  }
}