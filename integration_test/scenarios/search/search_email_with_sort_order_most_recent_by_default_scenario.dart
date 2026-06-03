import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/search_filters/search_filter_button.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../base/base_test_scenario.dart';
import '../../models/provisioning_email.dart';

class SearchEmailWithSortOrderMostRecentByDefaultScenario
    extends BaseTestScenario {
  const SearchEmailWithSortOrderMostRecentByDefaultScenario(super.$, super.robots);

  static const queryString = 'Most recent by default';
  static const listUsername = ['Alice', 'Brian', 'Charlotte', 'David', 'Emma'];

  @override
  Future<void> runTestLogic() async {
    final commonRobot = robots.commonRobot();
    final threadRobot = robots.threadRobot();
    final searchRobot = robots.searchRobot();

    final listProvisioningEmail = listUsername
        .map((username) => ProvisioningEmail(
              toEmail: '${username.toLowerCase()}@example.com',
              subject: queryString,
              content: '$queryString to user $username',
            ))
        .toList();

    await commonRobot.provisionEmail(listProvisioningEmail);
    await $.pumpAndSettle();

    await threadRobot.tapOnSearchField();

    await searchRobot.enterKeyword(queryString);
    await searchRobot.tapOnShowAllResultsText();
    await _expectSearchResultEmailListVisible();

    await searchRobot.scrollToEndListSearchFilter();
    await _expectMostRecentSortOrderButtonVisible();
  }

  Future<void> _expectSearchResultEmailListVisible() async {
    await expectViewVisible($(#search_email_list_notification_listener));
  }

  Future<void> _expectMostRecentSortOrderButtonVisible() async {
    await expectViewVisible(
      $(SearchFilterButton).$(AppLocalizations().mostRecent),
    );
  }
}
