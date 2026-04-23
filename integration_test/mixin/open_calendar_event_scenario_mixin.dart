import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/email/presentation/email_view.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/calendar_event/calendar_event_action_button_widget.dart';
import 'package:tmail_ui_user/features/search/email/presentation/search_email_view.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../base/base_scenario.dart';
import '../robots/search_robot.dart';
import '../robots/thread_robot.dart';

mixin OpenCalendarEventScenarioMixin on BaseScenario {
  static const eventEmailSubject = 'Proposed new time';

  Future<void> openCalendarEvent({
    required ThreadRobot threadRobot,
    required SearchRobot searchRobot,
    required AppLocalizations appLocalizations,
  }) async {
    await threadRobot.openSearchView();
    await _expectSearchViewVisible();

    await searchRobot.enterQueryString(eventEmailSubject);
    await searchRobot.tapOnShowAllResultsText();
    await _expectSearchResultEmailListVisible();

    await searchRobot.openEmailWithSubject(eventEmailSubject);
    await _expectEmailViewVisible();
    await _expectYesButtonVisible(appLocalizations);
    await _expectMailToAttendeesButtonVisible(appLocalizations);
    await _expectNoButtonInvisible(appLocalizations);
    await _expectMaybeButtonInvisible(appLocalizations);
  }

  Future<void> _expectSearchViewVisible() async {
    await expectViewVisible($(SearchEmailView));
  }

  Future<void> _expectSearchResultEmailListVisible() async {
    await expectViewVisible($(#search_email_list_notification_listener));
  }

  Future<void> _expectEmailViewVisible() async {
    await expectViewVisible($(EmailView), alignment: Alignment.topCenter);
  }

  Future<void> _expectYesButtonVisible(
    AppLocalizations appLocalizations,
  ) async {
    final yesButton =
        $(CalendarEventActionButtonWidget).$(appLocalizations.yes);
    await yesButton.scrollTo(scrollDirection: AxisDirection.down);
    await expectViewVisible(yesButton);
  }

  Future<void> _expectMailToAttendeesButtonVisible(
    AppLocalizations appLocalizations,
  ) async {
    final mailToAttendeesButton =
        $(CalendarEventActionButtonWidget).$(appLocalizations.mailToAttendees);
    await mailToAttendeesButton.scrollTo(scrollDirection: AxisDirection.down);
    await expectViewVisible(mailToAttendeesButton);
  }

  Future<void> _expectNoButtonInvisible(
    AppLocalizations appLocalizations,
  ) async {
    final noButton = $(CalendarEventActionButtonWidget).$(appLocalizations.no);
    await expectViewInvisible(noButton);
  }

  Future<void> _expectMaybeButtonInvisible(
    AppLocalizations appLocalizations,
  ) async {
    final maybeButton =
        $(CalendarEventActionButtonWidget).$(appLocalizations.maybe);
    await expectViewInvisible(maybeButton);
  }
}
