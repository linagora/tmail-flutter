
import 'package:collection/collection.dart';
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
  const SearchEmailWithSortOrderScenario(super.$);

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

    switch (sortOrderType) {
      case EmailSortOrderType.mostRecent:
        await _expectEmailListSortedCorrectByMostRecent();
        break;
      case EmailSortOrderType.oldest:
        await _expectEmailListSortedCorrectByOldest();
        break;
      case EmailSortOrderType.senderAscending:
        await _expectEmailListSortedCorrectBySenderAscending(listUsername: listUsername);
        break;
      case EmailSortOrderType.senderDescending:
        await _expectEmailListSortedCorrectBySenderDescending(listUsername: listUsername);
        break;
      case EmailSortOrderType.subjectAscending:
        await _expectEmailListSortedCorrectBySubjectAscending(listUsername: listUsername);
        break;
      case EmailSortOrderType.subjectDescending:
        await _expectEmailListSortedCorrectBySubjectDescending(listUsername: listUsername);
        break;
      case EmailSortOrderType.relevance:
        break;
      case EmailSortOrderType.sizeAscending:
        await _expectEmailListSortedCorrectBySizeAscending(listUsername: listUsername);
        break;
      case EmailSortOrderType.sizeDescending:
        await _expectEmailListSortedCorrectBySizeDescending(listUsername: listUsername);
        break;
    }
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

  Future<void> _expectEmailListSortedCorrectBySenderAscending({
    required List<String> listUsername,
  }) async {
    final listEmailTile = $.tester
      .widgetList<EmailTileBuilder>(find.byType(EmailTileBuilder));

    for (int i = 0; i < listUsername.length; i++) {
      EmailTileBuilder emailTile = listEmailTile.elementAt(i);
      final senderName = emailTile.presentationEmail.firstEmailAddressInFrom;
      expect(senderName, equals('${listUsername[i].toLowerCase()}@example.com'));
    }
  }

  Future<void> _expectEmailListSortedCorrectBySenderDescending({
    required List<String> listUsername,
  }) async {
    final listEmailTile = $.tester
      .widgetList<EmailTileBuilder>(find.byType(EmailTileBuilder));

    final reversedListUsername = listUsername.reversed.toList();

    for (int i = 0; i < reversedListUsername.length; i++) {
      EmailTileBuilder emailTile = listEmailTile.elementAt(i);
      final senderName = emailTile.presentationEmail.firstEmailAddressInFrom;
      expect(senderName, equals('${reversedListUsername[i].toLowerCase()}@example.com'));
    }
  }

  Future<void> _expectEmailListSortedCorrectBySubjectAscending({
    required List<String> listUsername,
  }) async {
    final listEmailTile = $.tester
      .widgetList<EmailTileBuilder>(find.byType(EmailTileBuilder));

    for (int i = 0; i < listUsername.length; i++) {
      EmailTileBuilder emailTile = listEmailTile.elementAt(i);
      final subject = emailTile.presentationEmail.subject;
      expect(subject, equals('${listUsername[i]} send Bob'));
    }
  }

  Future<void> _expectEmailListSortedCorrectBySubjectDescending({
    required List<String> listUsername,
  }) async {
    final listEmailTile = $.tester
      .widgetList<EmailTileBuilder>(find.byType(EmailTileBuilder));

    final reversedListUsername = listUsername.reversed.toList();

    for (int i = 0; i < reversedListUsername.length; i++) {
      EmailTileBuilder emailTile = listEmailTile.elementAt(i);
      final subject = emailTile.presentationEmail.subject;
      expect(subject, equals('${reversedListUsername[i]} send Bob'));
    }
  }

  Future<void> _expectEmailListSortedCorrectByMostRecent() async {
    final listEmailTile = $.tester
      .widgetList<EmailTileBuilder>(find.byType(EmailTileBuilder));

    final listReceiveAtTime = listEmailTile
      .map((emailTile) => emailTile.presentationEmail.receivedAt?.value)
      .whereNotNull()
      .toList();

    expect(listReceiveAtTime.isSortedByMostRecent(), isTrue);
  }

  Future<void> _expectEmailListSortedCorrectByOldest() async {
    final listEmailTile = $.tester
      .widgetList<EmailTileBuilder>(find.byType(EmailTileBuilder));

    final listReceiveAtTime = listEmailTile
      .map((emailTile) => emailTile.presentationEmail.receivedAt?.value)
      .whereNotNull()
      .toList();

    expect(listReceiveAtTime.isSortedByOldestFirst(), isTrue);
  }

  Future<void> _expectEmailListSortedCorrectBySizeAscending({
    required List<String> listUsername,
  }) async {
    final listEmailTile = $.tester
        .widgetList<EmailTileBuilder>(find.byType(EmailTileBuilder));

    List<UnsignedInt> sizeList = listEmailTile
      .mapIndexed((index, emailTile) => listEmailTile.elementAt(index).presentationEmail.size)
      .whereNotNull()
      .toList();

    expect(_isSortedAscending(sizeList), isTrue);
  }

  Future<void> _expectEmailListSortedCorrectBySizeDescending({
    required List<String> listUsername,
  }) async {
    final listEmailTile = $.tester
        .widgetList<EmailTileBuilder>(find.byType(EmailTileBuilder));

    List<UnsignedInt> sizeList = listEmailTile
      .mapIndexed((index, emailTile) => listEmailTile.elementAt(index).presentationEmail.size)
      .whereNotNull()
      .toList();

    expect(_isSortedAscending(sizeList), isFalse);
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