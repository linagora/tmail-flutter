
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_receive_time_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_sort_order_type.dart';
import 'package:tmail_ui_user/features/search/email/presentation/search_email_view.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/email_tile_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../base/base_scenario.dart';
import '../models/provisioning_email.dart';
import '../robots/search_robot.dart';
import '../robots/thread_robot.dart';
import '../utils/scenario_utils_mixin.dart';
import 'login_with_basic_auth_scenario.dart';

class SearchEmailByDatetimeAndSortOrderRelevanceScenario extends BaseScenario
    with ScenarioUtilsMixin {

  const SearchEmailByDatetimeAndSortOrderRelevanceScenario(
    super.$, 
    {
      required this.loginWithBasicAuthScenario,
      required this.queryString,
      required this.listProvisioningEmail,
    }
  );

  final LoginWithBasicAuthScenario loginWithBasicAuthScenario;
  final String queryString;
  final List<ProvisioningEmail> listProvisioningEmail;

  @override
  Future<void> execute() async {
    await loginWithBasicAuthScenario.execute();

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

    await searchRobot.openSortOrderBottomDialog();
    await _expectSortFilterContextMenuVisible();
    await searchRobot.selectSortOrder(
      EmailSortOrderType.relevance.getTitleByAppLocalizations(appLocalizations),
    );
    await _expectSearchResultEmailListVisible();

    await _expectEmailListDisplayedCorrectly();
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

  Future<void> _expectEmailListDisplayedCorrectly() async {
    expect(find.byType(EmailTileBuilder), findsNWidgets(listProvisioningEmail.length));
  }
}