import 'package:tmail_ui_user/features/email/presentation/email_view.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/calendar_event/calendar_event_action_banner_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/calendar_event/calendar_event_action_button_widget.dart';
import 'package:tmail_ui_user/features/search/email/presentation/search_email_view.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../base/base_test_scenario.dart';
import '../../robots/search_robot.dart';
import '../../robots/thread_robot.dart';

class CalendarEventCounterScenario extends BaseTestScenario {
  const CalendarEventCounterScenario(super.$);
  
  @override
  Future<void> runTestLogic() async {
    const emailSubject = 'Proposed new time';

    final threadRobot = ThreadRobot($);
    final searchRobot = SearchRobot($);
    final appLocalizations = AppLocalizations();
    
    await threadRobot.openSearchView();
    await _expectSearchViewVisible();

    await searchRobot.enterQueryString(emailSubject);
    await searchRobot.tapOnShowAllResultsText();
    await _expectSearchResultEmailListVisible();

    await searchRobot.openEmailWithSubject(emailSubject);
    await _expectEmailViewVisible();
    await _expectYesButtonVisible(appLocalizations);
    await _expectMailToAttendeesButtonVisible(appLocalizations);
    await _expectNoButtonInvisible(appLocalizations);
    await _expectMaybeButtonInvisible(appLocalizations);
    await _expectProposedEventChangesTextVisible(appLocalizations);
  }

  Future<void> _expectSearchViewVisible() async {
    await expectViewVisible($(SearchEmailView));
  }

  Future<void> _expectSearchResultEmailListVisible() async {
    await expectViewVisible($(#search_email_list_notification_listener));
  }

  Future<void> _expectEmailViewVisible() async {
    await expectViewVisible($(EmailView));
  }
  
  Future<void> _expectYesButtonVisible(
    AppLocalizations appLocalizations,
  ) async {
    final yesButton = $(CalendarEventActionButtonWidget)
      .$(appLocalizations.yes);
    await yesButton.scrollTo();
    await expectViewVisible(yesButton);
  }

  Future<void> _expectMailToAttendeesButtonVisible(
    AppLocalizations appLocalizations,
  ) async {
    final mailToAttendeesButton = $(CalendarEventActionButtonWidget)
      .$(appLocalizations.mailToAttendees);
    await mailToAttendeesButton.scrollTo();
    await expectViewVisible(mailToAttendeesButton);
  }

  Future<void> _expectNoButtonInvisible(
    AppLocalizations appLocalizations,
  ) async {
    final noButton = $(CalendarEventActionButtonWidget)
      .$(appLocalizations.no);
    await expectViewInvisible(noButton);
  }

  Future<void> _expectMaybeButtonInvisible(
    AppLocalizations appLocalizations,
  ) async {
    final maybeButton = $(CalendarEventActionButtonWidget)
      .$(appLocalizations.maybe);
    await expectViewInvisible(maybeButton);
  }

  Future<void> _expectProposedEventChangesTextVisible(
    AppLocalizations appLocalizations,
  ) async {
    final proposedEventChangesText = $(CalendarEventActionBannerWidget)
      .$(appLocalizations.anAttendee
        + appLocalizations.messageEventActionBannerAttendeeCounter);
    await proposedEventChangesText.scrollTo();
    await expectViewVisible(proposedEventChangesText);
  }
}