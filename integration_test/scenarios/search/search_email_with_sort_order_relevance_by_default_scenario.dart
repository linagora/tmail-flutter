import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/search_filters/search_filter_button.dart';
import 'package:tmail_ui_user/features/search/email/presentation/search_email_view.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../base/base_test_scenario.dart';
import '../../models/provisioning_email.dart';
import '../../robots/search_robot.dart';
import '../../robots/thread_robot.dart';

class SearchEmailWithSortOrderRelevanceByDefaultScenario
    extends BaseTestScenario {
  const SearchEmailWithSortOrderRelevanceByDefaultScenario(super.$);

  static const queryString = 'Relevance by default';
  static const listUsername = ['Alice', 'Brian', 'Charlotte', 'David', 'Emma'];

  @override
  Future<void> runTestLogic() async {
    final listProvisioningEmail = listUsername
        .map((username) => ProvisioningEmail(
              toEmail: '${username.toLowerCase()}@example.com',
              subject: queryString,
              content: '$queryString to user $username',
            ))
        .toList();

    await provisionEmail(listProvisioningEmail);
    await $.pumpAndSettle();

    final threadRobot = ThreadRobot($);
    await threadRobot.openSearchView();
    await _expectSearchViewVisible();

    final searchRobot = SearchRobot($);
    await searchRobot.enterQueryString(queryString);
    await searchRobot.tapOnShowAllResultsText();
    await _expectSearchResultEmailListVisible();

    await searchRobot.scrollToEndListSearchFilter();
    await _expectRelevanceSortOrderButtonVisible();
  }

  Future<void> _expectSearchViewVisible() async {
    await expectViewVisible($(SearchEmailView));
  }

  Future<void> _expectSearchResultEmailListVisible() async {
    await expectViewVisible($(#search_email_list_notification_listener));
  }

  Future<void> _expectRelevanceSortOrderButtonVisible() async {
    await expectViewVisible(
      $(SearchFilterButton).$(AppLocalizations().relevance),
    );
  }
}
