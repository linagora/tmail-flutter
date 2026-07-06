import 'package:core/presentation/views/text/rich_text_builder.dart';
import 'package:core/presentation/views/text/text_field_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:collection/collection.dart';
import 'package:core/domain/extensions/list_datetime_extension.dart';
import 'package:core/presentation/views/search/search_bar_view.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';
import 'package:tmail_ui_user/features/search/email/presentation/search_email_view.dart';
import 'package:tmail_ui_user/features/thread/presentation/thread_view.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/email_tile_builder.dart'
  if (dart.library.html) 'package:tmail_ui_user/features/thread/presentation/widgets/email_tile_web_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import 'package:patrol/patrol.dart';

import '../base/core_robot.dart';
import '../extensions/patrol_finder_extension.dart';
import '../utils/test_timeouts.dart';
import '../utils/wait_for_condition.dart';
import 'abstract/abstract_search_result_assertion_robot.dart';
import 'abstract/abstract_search_robot.dart';
import 'abstract/abstract_search_suggestion_robot.dart';
import 'search_result_assertion_robot.dart';
import 'search_suggestion_robot.dart';

class SearchRobot extends CoreRobot implements AbstractSearchRobot {
  @override
  final AbstractSearchSuggestionRobot suggestion;

  @override
  final AbstractSearchResultAssertionRobot assertion;

  SearchRobot(
    PatrolIntegrationTester $, {
    AbstractSearchSuggestionRobot? suggestionRobot,
    AbstractSearchResultAssertionRobot? assertionRobot,
  })  : suggestion = suggestionRobot ?? SearchSuggestionRobot($),
        assertion = assertionRobot ?? SearchResultAssertionRobot($),
        super($);

  @override
  Future<void> tapOnSearchField() async {
    await $(ThreadView).$(SearchBarView).tap();
  }

  Future<void> enterQueryString(String queryString) async {
    final finder = $(#search_email_text_field).$(TextField);
    final isTextFieldFocused = finder
      .which<TextField>((view) => view.focusNode?.hasFocus ?? false)
      .exists;
    if (!isTextFieldFocused) {
      await finder.tap();
    }
    await finder.enterTextWithoutTapAction(queryString);
  }

  @override
  Future<void> verifySearchSuggestionHighlights(String keyword) async {
    // Mobile/native: SearchEmailView renders suggestions directly in its widget tree.
    await $.waitUntilVisible($(RichTextBuilder));
    expect($(RichTextBuilder).$(keyword.split(' ').first).evaluate().length, 10);
  }

  @override
  Future<void> scrollToEndListSearchFilter() async {
    await $.scrollUntilVisible(
      finder: $(#mobile_sortBy_search_filter_button),
      view: $(#search_filter_list_view),
      scrollDirection: AxisDirection.right,
      delta: 300,
    );
  }

  @override
  Future<void> openSortOrderMenu() async {
    await $(#mobile_sortBy_search_filter_button).tap();
  }

  @override
  Future<void> selectSortOrder(String sortOrderName) async {
    await $(find.text(sortOrderName)).tap();
    await $.pump(const Duration(seconds: 2));
  }

  @override
  Future<void> enterKeyword(String keyword) async {
    final finder = $(SearchEmailView).$(TextFieldBuilder);
    final isTextFieldFocused = finder
      .which<TextFieldBuilder>((view) => view.focusNode?.hasFocus ?? false)
      .exists;
    if (!isTextFieldFocused) {
      await finder.tap();
    }
    await finder.enterTextWithoutTapAction(keyword);
  }

  @override
  Future<void> tapOnShowAllResultsText() async {
    await $.waitUntilVisible($(AppLocalizations().showingResultsFor));
    await $(AppLocalizations().showingResultsFor).tap();
  }

  @override
  Future<void> scrollToDateTimeButtonFilter() async {
    // The horizontal filter list may already be scrolled to its far-right end
    // (e.g. after reaching the sortBy button). The dateTime button sits to the
    // left of sortBy, so reset to the start before scrolling right to it,
    // otherwise the rightward scroll never reaches it.
    await _resetSearchFilterListScrollToStart();
    await $.scrollUntilVisible(
      finder: $(#mobile_dateTime_search_filter_button),
      view: $(#search_filter_list_view),
      scrollDirection: AxisDirection.right,
      delta: 100,
    );
  }

  Future<void> _resetSearchFilterListScrollToStart() async {
    final listViewFinder = find.byKey(const Key(UiKeys.searchFilterListView));
    if (listViewFinder.evaluate().isEmpty) return;
    final scrollController = $.tester.widget<ListView>(listViewFinder).controller;
    if (scrollController != null && scrollController.hasClients) {
      scrollController.jumpTo(0);
      await $.pumpAndSettle();
    }
  }

  @override
  Future<void> openDateTimeBottomDialog() async {
    await $(#mobile_dateTime_search_filter_button).tap();
  }

  @override
  Future<void> selectDateTime(String dateTimeType) async {
    await $(find.text(dateTimeType)).tap();
    await $.pump(const Duration(seconds: 2));
  }

  Future<void> openEmailWithSubject(String subject) async {
    final email = $(EmailTileBuilder)
      .which<EmailTileBuilder>((view) => view.presentationEmail.subject == subject);
    await $.waitUntilVisible(email);
    await email.tap();
    await $.pump(const Duration(seconds: 2));
  }

  Future<void> tapBackButton() async {
    await $(#search_email_back_button).tap();
  }

  @override
  Future<void> selectAttachmentFilter() async {
    await $.scrollUntilVisible(
      finder: $(#mobile_hasAttachment_search_filter_button),
      view: $(#search_filter_list_view),
      scrollDirection: AxisDirection.right,
      delta: 50,
    );
    await $(#mobile_hasAttachment_search_filter_button).tap();
  }

  @override
  Future<void> openLabelListModal() async {
    await $(#mobile_labels_search_filter_button).tap();
  }

  @override
  Future<void> expectSortBySearchFilterButtonVisible() async {
    await $.waitUntilVisible($(#mobile_sortBy_search_filter_button));
  }

  @override
  Future<void> expectSortOrderMenuVisible() async {
    await $.waitUntilVisible($(#sort_filter_context_menu));
  }

  @override
  Future<void> expectSearchResultEmailListVisible() async {
    await $.waitUntilVisible($(#search_email_list_notification_listener));
  }

  @override
  Future<void> expectDateTimeSearchFilterButtonVisible() async {
    await $.waitUntilVisible($(#mobile_dateTime_search_filter_button));
  }

  @override
  Future<void> expectDateTimeFilterContextMenuVisible() async {
    await $.waitUntilVisible($(#date_time_filter_context_menu));
  }

  @override
  Future<void> expectEmailListCount(int count) async {
    expect(find.byType(EmailTileBuilder), findsNWidgets(count));
  }

  @override
  Future<void> expectEmailListCountAtLeast(int count) async {
    // Wait for the search result container — confirms searchIsRunning=true
    // and listResultSearch is non-empty before checking individual tiles.
    await $.waitUntilVisible(
      $(#search_email_list_notification_listener),
      timeout: TestTimeouts.medium,
    );
    await waitForCondition(
      () async {
        final tiles = $(#search_email_list_notification_listener)
            .$(EmailTileBuilder)
            .evaluate();
        return tiles.length >= count;
      },
      timeout: TestTimeouts.medium,
    );
    expect(
      $(#search_email_list_notification_listener)
          .$(EmailTileBuilder)
          .evaluate()
          .length,
      greaterThanOrEqualTo(count),
    );
  }

  @override
  Future<void> expectEmailListSortedByMostRecent() async {
    final tiles = $.tester.widgetList<EmailTileBuilder>(find.byType(EmailTileBuilder));
    final dates = tiles
      .map((t) => t.presentationEmail.receivedAt?.value)
      .nonNulls
      .toList();
    expect(dates.isSortedByMostRecent(), isTrue);
  }

  @override
  Future<void> expectEmailListSortedByOldest() async {
    final tiles = $.tester.widgetList<EmailTileBuilder>(find.byType(EmailTileBuilder));
    final dates = tiles
      .map((t) => t.presentationEmail.receivedAt?.value)
      .nonNulls
      .toList();
    expect(dates.isSortedByOldestFirst(), isTrue);
  }

  @override
  Future<void> expectEmailListSortedBySenderAscending(List<String> usernames) async {
    final tiles = $.tester.widgetList<EmailTileBuilder>(find.byType(EmailTileBuilder));
    for (int i = 0; i < usernames.length; i++) {
      final sender = tiles.elementAt(i).presentationEmail.firstEmailAddressInFrom;
      expect(sender, equals('${usernames[i].toLowerCase()}@example.com'));
    }
  }

  @override
  Future<void> expectEmailListSortedBySenderDescending(List<String> usernames) async {
    final tiles = $.tester.widgetList<EmailTileBuilder>(find.byType(EmailTileBuilder));
    final reversed = usernames.reversed.toList();
    for (int i = 0; i < reversed.length; i++) {
      final sender = tiles.elementAt(i).presentationEmail.firstEmailAddressInFrom;
      expect(sender, equals('${reversed[i].toLowerCase()}@example.com'));
    }
  }

  @override
  Future<void> expectEmailListSortedBySubjectAscending(List<String> usernames) async {
    final tiles = $.tester.widgetList<EmailTileBuilder>(find.byType(EmailTileBuilder));
    for (int i = 0; i < usernames.length; i++) {
      final subject = tiles.elementAt(i).presentationEmail.subject;
      expect(subject, equals('${usernames[i]} send Bob'));
    }
  }

  @override
  Future<void> expectEmailListSortedBySubjectDescending(List<String> usernames) async {
    final tiles = $.tester.widgetList<EmailTileBuilder>(find.byType(EmailTileBuilder));
    final reversed = usernames.reversed.toList();
    for (int i = 0; i < reversed.length; i++) {
      final subject = tiles.elementAt(i).presentationEmail.subject;
      expect(subject, equals('${reversed[i]} send Bob'));
    }
  }

  @override
  Future<void> expectEmailListSortedBySizeAscending() async {
    final tiles = $.tester.widgetList<EmailTileBuilder>(find.byType(EmailTileBuilder));
    final sizes = tiles
      .mapIndexed((i, t) => tiles.elementAt(i).presentationEmail.size)
      .nonNulls
      .toList();
    expect(_isSortedAscending(sizes), isTrue);
  }

  @override
  Future<void> expectEmailListSortedBySizeDescending() async {
    final tiles = $.tester.widgetList<EmailTileBuilder>(find.byType(EmailTileBuilder));
    final sizes = tiles
      .mapIndexed((i, t) => tiles.elementAt(i).presentationEmail.size)
      .nonNulls
      .toList();
    expect(_isSortedAscending(sizes), isFalse);
  }

  bool _isSortedAscending(List<UnsignedInt> list) {
    for (int i = 0; i < list.length - 1; i++) {
      if (list[i].value > list[i + 1].value) return false;
    }
    return true;
  }
  
  @override
  Future<void> expectEmailWithSubjectVisible(String subject) {
    throw UnimplementedError();
  }
  
  @override
  Future<void> expectEmptyResults() {
    throw UnimplementedError();
  }
  
  @override
  Future<void> openSearch() {
    throw UnimplementedError();
  }
  
  @override
  Future<void> searchByLabel(String labelName) {
    throw UnimplementedError();
  }
}
