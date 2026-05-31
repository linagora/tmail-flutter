
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_sort_order_type.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../base/base_test_scenario.dart';
import '../robots/abstract/abstract_search_robot.dart';

class SearchEmailWithSortOrderScenario extends BaseTestScenario {
  const SearchEmailWithSortOrderScenario(super.$, super.robots);

  static const queryString = 'hello';
  static const listUsername = ['Alice', 'Brian', 'Charlotte', 'David', 'Emma'];

  @override
  Future<void> runTestLogic() async {
    final searchRobot = robots.searchRobot();
    await searchRobot.tapOnSearchField();

    await searchRobot.enterKeyword(queryString);
    await searchRobot.tapOnShowAllResultsText();

    await searchRobot.scrollToEndListSearchFilter();
    await searchRobot.expectSortBySearchFilterButtonVisible();

    final appLocalizations = AppLocalizations();

    for (var sortOrderType in EmailSortOrderType.values) {
      await _performSelectSortOrderAndValidateSearchResult(
        searchRobot: searchRobot,
        sortOrderType: sortOrderType,
        appLocalizations: appLocalizations,
      );
    }
  }

  Future<void> _performSelectSortOrderAndValidateSearchResult({
    required AbstractSearchRobot searchRobot,
    required EmailSortOrderType sortOrderType,
    required AppLocalizations appLocalizations,
  }) async {
    await Future.delayed(const Duration(seconds: 2));

    await searchRobot.openSortOrderMenu();
    await searchRobot.expectSortOrderMenuVisible();
    await searchRobot.selectSortOrder(sortOrderType.getTitleByAppLocalizations(appLocalizations));

    // Relevance ordering is non-deterministic; verify only that the tap succeeded.
    if (sortOrderType == EmailSortOrderType.relevance) return;

    await searchRobot.expectSearchResultEmailListVisible();
    await searchRobot.expectEmailListCount(listUsername.length);

    switch (sortOrderType) {
      case EmailSortOrderType.mostRecent:
        await searchRobot.expectEmailListSortedByMostRecent();
        break;
      case EmailSortOrderType.oldest:
        await searchRobot.expectEmailListSortedByOldest();
        break;
      case EmailSortOrderType.senderAscending:
        await searchRobot.expectEmailListSortedBySenderAscending(listUsername);
        break;
      case EmailSortOrderType.senderDescending:
        await searchRobot.expectEmailListSortedBySenderDescending(listUsername);
        break;
      case EmailSortOrderType.subjectAscending:
        await searchRobot.expectEmailListSortedBySubjectAscending(listUsername);
        break;
      case EmailSortOrderType.subjectDescending:
        await searchRobot.expectEmailListSortedBySubjectDescending(listUsername);
        break;
      case EmailSortOrderType.relevance:
        break;
      case EmailSortOrderType.sizeAscending:
        await searchRobot.expectEmailListSortedBySizeAscending();
        break;
      case EmailSortOrderType.sizeDescending:
        await searchRobot.expectEmailListSortedBySizeDescending();
        break;
    }
  }
}
