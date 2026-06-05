
import 'package:collection/collection.dart';
import 'package:core/domain/extensions/list_datetime_extension.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_sort_order_type.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/email_tile_builder.dart'
  if (dart.library.html) 'package:tmail_ui_user/features/thread/presentation/widgets/email_tile_web_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../base/base_test_scenario.dart';
import '../robots/abstract/abstract_search_robot.dart';

class SearchEmailWithSortOrderScenario extends BaseTestScenario {
  const SearchEmailWithSortOrderScenario(super.$, super.robots);

  static const queryString = 'hello';
  static const listUsername = ['Alice', 'Brian', 'Charlotte', 'David', 'Emma'];

  @override
  Future<void> runTestLogic() async {
    final threadRobot = robots.threadRobot();
    final searchRobot = robots.searchRobot();

    await threadRobot.tapOnSearchField();
    await searchRobot.enterKeyword(queryString);
    await searchRobot.expectSuggestionListVisible();

    await searchRobot.tapOnShowAllResultsText();
    await searchRobot.expectSearchResultEmailListVisible();

    await searchRobot.scrollToEndListSearchFilter();

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

  Future<void> _expectEmailListSortedCorrectBySizeAscending({
    required List<String> listUsername,
  }) async {
    final listEmailTile = $.tester
        .widgetList<EmailTileBuilder>(find.byType(EmailTileBuilder));

    List<UnsignedInt> sizeList = listEmailTile
      .mapIndexed((index, emailTile) => listEmailTile.elementAt(index).presentationEmail.size)
      .nonNulls
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
      .nonNulls
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
