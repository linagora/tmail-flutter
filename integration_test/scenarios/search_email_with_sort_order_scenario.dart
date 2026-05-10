
import 'package:core/domain/extensions/list_datetime_extension.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_sort_order_type.dart';
import 'package:tmail_ui_user/features/search/email/presentation/search_email_view.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/email_tile_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../base/base_test_scenario.dart';
import '../robots/search_robot.dart';
import '../robots/thread_robot.dart';

class SearchEmailWithSortOrderScenario extends BaseTestScenario {
  const SearchEmailWithSortOrderScenario(super.$, super.robots);

  static const queryString = 'hello';
  static const listUsername = ['Alice', 'Brian', 'Charlotte', 'David', 'Emma'];

  @override
  Future<void> runTestLogic() async {
    final threadRobot = ThreadRobot($);
    await threadRobot.openSearchView();
    await _expectSearchViewVisible();

    final searchRobot = SearchRobot($);
    await searchRobot.enterQueryString(queryString);
    await _expectSuggestionSearchListViewVisible();

    await searchRobot.scrollToEndListSearchFilter();
    await _expectSortBySearchFilterButtonVisible();

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
    required SearchRobot searchRobot,
    required EmailSortOrderType sortOrderType,
    required AppLocalizations appLocalizations,
  }) async {
    await Future.delayed(const Duration(seconds: 2));

    await searchRobot.openSortOrderBottomDialog();
    await _expectSortFilterContextMenuVisible();

    await searchRobot.selectSortOrder(sortOrderType.getTitleByAppLocalizations(appLocalizations));
    await _expectSearchResultEmailListVisible();
    await _expectEmailListDisplayedCorrectly(listUsername: listUsername);

    await _validateSortOrder(sortOrderType);
  }

  Future<void> _validateSortOrder(EmailSortOrderType sortOrderType) async {
    final validators = <EmailSortOrderType, Future<void> Function()>{
      EmailSortOrderType.mostRecent: _expectEmailListSortedCorrectByMostRecent,
      EmailSortOrderType.oldest: _expectEmailListSortedCorrectByOldest,
      EmailSortOrderType.senderAscending: () => _expectEmailListSortedByStringProperty(
        listUsername: listUsername,
        ascending: true,
        getValue: (tile) => tile.presentationEmail.firstEmailAddressInFrom,
        buildExpected: (username) => '${username.toLowerCase()}@example.com',
      ),
      EmailSortOrderType.senderDescending: () => _expectEmailListSortedByStringProperty(
        listUsername: listUsername,
        ascending: false,
        getValue: (tile) => tile.presentationEmail.firstEmailAddressInFrom,
        buildExpected: (username) => '${username.toLowerCase()}@example.com',
      ),
      EmailSortOrderType.subjectAscending: () => _expectEmailListSortedByStringProperty(
        listUsername: listUsername,
        ascending: true,
        getValue: (tile) => tile.presentationEmail.subject,
        buildExpected: (username) => '$username send Bob',
      ),
      EmailSortOrderType.subjectDescending: () => _expectEmailListSortedByStringProperty(
        listUsername: listUsername,
        ascending: false,
        getValue: (tile) => tile.presentationEmail.subject,
        buildExpected: (username) => '$username send Bob',
      ),
      EmailSortOrderType.sizeAscending: () => _expectEmailListSortedBySize(ascending: true),
      EmailSortOrderType.sizeDescending: () => _expectEmailListSortedBySize(ascending: false),
    };
    final validator = validators[sortOrderType];
    if (validator != null) await validator();
  }

  Future<void> _expectSearchViewVisible() async {
    await expectViewVisible($(SearchEmailView));
  }

  Future<void> _expectSuggestionSearchListViewVisible() async {
    await expectViewVisible($(#suggestion_search_list_view));
  }

  Future<void> _expectSortBySearchFilterButtonVisible() async {
    await expectViewVisible($(#mobile_sortBy_search_filter_button));
  }
  
  Future<void> _expectSortFilterContextMenuVisible() async {
    await expectViewVisible($(#sort_filter_context_menu));
  }
  
  Future<void> _expectSearchResultEmailListVisible() async {
    await expectViewVisible($(#search_email_list_notification_listener));
  }

  Future<void> _expectEmailListDisplayedCorrectly({
    required List<String> listUsername,
  }) async {
    expect(find.byType(EmailTileBuilder), findsNWidgets(listUsername.length));
  }

  Future<void> _expectEmailListSortedByStringProperty({
    required List<String> listUsername,
    required bool ascending,
    required String? Function(EmailTileBuilder) getValue,
    required String Function(String) buildExpected,
  }) async {
    final listEmailTile = $.tester
      .widgetList<EmailTileBuilder>(find.byType(EmailTileBuilder));
    final orderedList = ascending ? listUsername : listUsername.reversed.toList();
    for (int i = 0; i < orderedList.length; i++) {
      final emailTile = listEmailTile.elementAt(i);
      expect(getValue(emailTile), equals(buildExpected(orderedList[i])));
    }
  }

  Future<void> _expectEmailListSortedCorrectByMostRecent() async {
    final listEmailTile = $.tester
      .widgetList<EmailTileBuilder>(find.byType(EmailTileBuilder));

    final listReceiveAtTime = listEmailTile
      .map((emailTile) => emailTile.presentationEmail.receivedAt?.value)
      .nonNulls
      .toList();

    expect(listReceiveAtTime.isSortedByMostRecent(), isTrue);
  }

  Future<void> _expectEmailListSortedCorrectByOldest() async {
    final listEmailTile = $.tester
      .widgetList<EmailTileBuilder>(find.byType(EmailTileBuilder));

    final listReceiveAtTime = listEmailTile
      .map((emailTile) => emailTile.presentationEmail.receivedAt?.value)
      .nonNulls
      .toList();

    expect(listReceiveAtTime.isSortedByOldestFirst(), isTrue);
  }

  Future<void> _expectEmailListSortedBySize({required bool ascending}) async {
    final sizeList = $.tester
      .widgetList<EmailTileBuilder>(find.byType(EmailTileBuilder))
      .map((emailTile) => emailTile.presentationEmail.size)
      .nonNulls
      .toList();
    expect(_isSortedAscending(sizeList), equals(ascending));
  }

  bool _isSortedAscending(List<UnsignedInt> list) {
    for (int i = 0; i < list.length - 1; i++) {
      if (list[i].value > list[i + 1].value) {
        return false;
      }
    }
    return true;
  }
}