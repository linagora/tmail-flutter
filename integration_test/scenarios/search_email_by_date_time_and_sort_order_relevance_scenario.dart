
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_receive_time_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_sort_order_type.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/email_tile_builder.dart'
  if (dart.library.html) 'package:tmail_ui_user/features/thread/presentation/widgets/email_tile_web_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../base/base_test_scenario.dart';
import '../models/provisioning_email.dart';

class SearchEmailByDatetimeAndSortOrderRelevanceScenario extends BaseTestScenario {

  const SearchEmailByDatetimeAndSortOrderRelevanceScenario(super.$, super.robots);

  static const queryString = 'relevance';
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

    await robots.commonRobot().provisionEmail(listProvisioningEmail);
    await $.pumpAndSettle();

    final searchRobot = robots.searchRobot();
    await searchRobot.tapOnSearchField();

    await searchRobot.enterKeyword(queryString);
    await searchRobot.tapOnShowAllResultsText();

    await searchRobot.scrollToDateTimeButtonFilter();
    await searchRobot.expectDateTimeSearchFilterButtonVisible();

    await searchRobot.openDateTimeBottomDialog();
    await searchRobot.expectDateTimeFilterContextMenuVisible();

    final appLocalizations = AppLocalizations();
    await searchRobot.selectDateTime(
      EmailReceiveTimeType.last7Days.getTitleByAppLocalizations(appLocalizations),
    );
    await searchRobot.expectSearchResultEmailListVisible();

    await searchRobot.scrollToEndListSearchFilter();
    await searchRobot.expectSortBySearchFilterButtonVisible();

    await searchRobot.openSortOrderMenu();
    await searchRobot.expectSortOrderMenuVisible();
    await searchRobot.selectSortOrder(
      EmailSortOrderType.relevance.getTitleByAppLocalizations(appLocalizations),
    );
    await searchRobot.expectSearchResultEmailListVisible();

    await _expectEmailListDisplayedCorrectly(listProvisioningEmail);
  }

  Future<void> _expectEmailListDisplayedCorrectly(List<ProvisioningEmail> listProvisioningEmail) async {
    expect(find.byType(EmailTileBuilder), findsNWidgets(listProvisioningEmail.length));
  }
}
