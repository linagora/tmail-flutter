
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/model/email_receive_time_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_sort_order_type.dart';
import 'package:tmail_ui_user/features/search/email/presentation/search_email_view.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/email_tile_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../base/base_test_scenario.dart';
import '../models/provisioning_email.dart';
import '../robots/search_robot.dart';
import '../robots/thread_robot.dart';

class SearchEmailByDatetimeAndSortOrderRelevanceScenario extends BaseTestScenario {

  const SearchEmailByDatetimeAndSortOrderRelevanceScenario(super.$);

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

    await provisionEmail(listProvisioningEmail);
    await $.pumpAndSettle();

    final threadRobot = ThreadRobot($);
    await threadRobot.openSearchView();
    await _expectSearchViewVisible();

    final searchRobot = SearchRobot($);
    await searchRobot.enterQueryString(queryString);
    await _expectSuggestionSearchListViewVisible();

    await searchRobot.scrollToDateTimeButtonFilter();
    await _expectDateTimeSearchFilterButtonVisible();

    await Future.delayed(const Duration(seconds: 2));

    await searchRobot.openDateTimeBottomDialog();
    await _expectDateTimeFilterContextMenuVisible();

    final appLocalizations = AppLocalizations();
    await searchRobot.selectDateTime(
      EmailReceiveTimeType.last7Days.getTitleByAppLocalizations(appLocalizations),
    );
    await _expectSearchResultEmailListVisible();

    await Future.delayed(const Duration(seconds: 2));

    await searchRobot.scrollToEndListSearchFilter();
    await _expectSortBySearchFilterButtonVisible();

    await searchRobot.openSortOrderBottomDialog();
    await _expectSortFilterContextMenuVisible();
    await searchRobot.selectSortOrder(
      EmailSortOrderType.relevance.getTitleByAppLocalizations(appLocalizations),
    );
    await _expectSearchResultEmailListVisible();

    await _expectEmailListDisplayedCorrectly(listProvisioningEmail);
  }


  Future<void> _expectSearchViewVisible() async {
    await expectViewVisible($(SearchEmailView));
  }

  Future<void> _expectSuggestionSearchListViewVisible() async {
    await expectViewVisible($(#suggestion_search_list_view));
  }

  Future<void> _expectDateTimeSearchFilterButtonVisible() async {
    await expectViewVisible($(#mobile_dateTime_search_filter_button));
  }

  Future<void> _expectDateTimeFilterContextMenuVisible() async {
    await expectViewVisible($(#date_time_filter_context_menu));
  }
  
  Future<void> _expectSearchResultEmailListVisible() async {
    await expectViewVisible($(#search_email_list_notification_listener));
  }

  Future<void> _expectSortFilterContextMenuVisible() async {
    await expectViewVisible($(#sort_filter_context_menu));
  }

  Future<void> _expectEmailListDisplayedCorrectly(List<ProvisioningEmail> listProvisioningEmail) async {
    expect(find.byType(EmailTileBuilder), findsNWidgets(listProvisioningEmail.length));
  }

  Future<void> _expectSortBySearchFilterButtonVisible() async {
    await expectViewVisible($(#mobile_sortBy_search_filter_button));
  }
}