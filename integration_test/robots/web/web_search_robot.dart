import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/presentation/views/text/rich_text_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';
import 'package:tmail_ui_user/features/base/widget/popup_menu/popup_menu_item_action_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/quick_search/email_quick_search_item_tile_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/search_input_form_widget.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/email_tile_web_builder.dart';

import '../../extensions/patrol_finder_extension.dart';
import '../../utils/test_timeouts.dart';
import '../../utils/wait_for_condition.dart';
import '../abstract/abstract_search_robot.dart';
import '../search_robot.dart';

class WebSearchRobot extends SearchRobot implements AbstractSearchRobot {
  WebSearchRobot(PatrolIntegrationTester $) : super($);

  @override
  Future<void> tapOnSearchField() async {
    await $(SearchInputFormWidget).$(TextField).tap();
    // Tap the search icon button so isSearchEmailRunning becomes true and filter
    // buttons appear in the dashboard bar before any keyword is entered.
    await $(SearchInputFormWidget).$(TMailButtonWidget).tap();
    await waitForCondition(
      () async => $(#sortBy_search_filter_button).evaluate().isNotEmpty,
      timeout: TestTimeouts.short,
    );
  }

  @override
  Future<void> enterKeyword(String keyword) async {
    final finder = $(SearchInputFormWidget).$(TextField);
    await finder.tap();
    await finder.enterTextWithoutTapAction(keyword);
  }

  @override
  Future<void> verifySearchSuggestionHighlights(String keyword) async {
    // Web: suggestions render inside an OverlayEntry wrapped by PointerInterceptor,
    // so they are not hit-testable. Use waitUntilExists instead of waitUntilVisible.
    await $.waitUntilExists($(EmailQuickSearchItemTileWidget));
    expect(
      $(EmailQuickSearchItemTileWidget).$(RichTextBuilder).evaluate().isNotEmpty,
      isTrue,
    );
  }

  @override
  Future<void> tapOnShowAllResultsText() async {
    // On web the suggestion overlay wraps content in PointerInterceptor, making
    // the "Showing results for:" InkWell unreliable to tap. Pressing Enter on the
    // focused search field triggers onSubmitted → _invokeSearchEmailAction which
    // commits the search and sets isSearchEmailRunning = true.
    await $.platformAutomator.web.pressKeyCombo(keys: ['Enter']);
    await waitForCondition(
      () async => $(EmailTileBuilder).evaluate().isNotEmpty,
      timeout: TestTimeouts.medium,
    );
  }

  @override
  Future<void> scrollToEndListSearchFilter() async {
    // Web: sortBy button is always visible in the top dashboard bar — no scroll.
  }

  @override
  Future<void> scrollToDateTimeButtonFilter() async {
    // Web: dateTime button is always visible in the top dashboard bar — no scroll.
  }

  @override
  Future<void> openSortOrderMenu() async {
    // Web desktop uses #sortBy_search_filter_button (no mobile_ prefix).
    await $(#sortBy_search_filter_button).tap();
  }

  @override
  Future<void> openDateTimeBottomDialog() async {
    // Web desktop uses #dateTime_search_filter_button (no mobile_ prefix).
    await $(#dateTime_search_filter_button).tap();
  }

  @override
  Future<void> openLabelListModal() async {
    // Web desktop uses #labels_search_filter_button (no mobile_ prefix).
    await $(#labels_search_filter_button).tap();
  }

  @override
  Future<void> selectSortOrder(String sortOrderName) async {
    await $(sortOrderName).tap();
    // pump() does not yield to browser XHR — waitForCondition yields via Future.delayed internally.
    await waitForCondition(
      () async => $(PopupMenuItemActionWidget).evaluate().isEmpty,
      timeout: TestTimeouts.short,
    );
  }

  @override
  Future<void> selectDateTime(String dateTimeType) async {
    await $(dateTimeType).tap();
    // pump() does not yield to browser XHR — waitForCondition yields via Future.delayed internally.
    await waitForCondition(
      () async => $(PopupMenuItemActionWidget).evaluate().isEmpty,
      timeout: TestTimeouts.short,
    );
  }

  @override
  Future<void> expectSortBySearchFilterButtonVisible() async {
    await $.waitUntilVisible($(#sortBy_search_filter_button));
  }

  @override
  Future<void> expectSortOrderMenuVisible() async {
    // showMenu popup has no container key — assert via the item widget type.
    await $.waitUntilVisible($(PopupMenuItemActionWidget));
  }

  @override
  Future<void> expectSearchResultEmailListVisible() async {
    // EmailTileBuilder on web is a StatefulWidget from email_tile_web_builder.dart
    // and is NOT hit-testable. waitUntilVisible uses pump() which does not yield to
    // the browser event loop. waitForCondition uses Future.delayed which does yield,
    // allowing JMAP responses to arrive.
    await waitForCondition(
      () async => $(EmailTileBuilder).evaluate().isNotEmpty,
      timeout: TestTimeouts.medium,
    );
  }

  @override
  Future<void> expectDateTimeSearchFilterButtonVisible() async {
    await $.waitUntilVisible($(#dateTime_search_filter_button));
  }

  @override
  Future<void> expectDateTimeFilterContextMenuVisible() async {
    // showMenu popup has no container key — assert via the item widget type.
    await $.waitUntilVisible($(PopupMenuItemActionWidget));
  }

  @override
  Future<void> openSearch() async {
    await $(const ValueKey(UiKeys.openAdvancedSearchButton)).tap();
  }

  @override
  Future<void> searchByLabel(String labelName) async {
    await $(const ValueKey(UiKeys.advancedSearchLabelDropDown)).tap();
    await $(find.text(labelName)).tap();
    await $(const ValueKey(UiKeys.advancedSearchSearchButton)).tap();
  }

  @override
  Future<void> expectEmailWithSubjectVisible(String subject) async {
    final email = $(EmailTileBuilder).which<EmailTileBuilder>(
      (view) => view.presentationEmail.subject?.contains(subject) == true,
    );
    await $.waitUntilVisible(email);
  }

  @override
  Future<void> expectEmailListCountAtLeast(int count) async {
    // Web desktop: results render in ThreadView (no #search_email_list_notification_listener).
    // $.pump() advances the widget tree each retry so GetX rebuilds from JMAP responses
    // are processed; Future.delayed inside waitForCondition then yields to the browser
    // event loop so XHR callbacks can fire before the next retry.
    await waitForCondition(
      () async {
        await $.pump();
        return $(EmailTileBuilder).evaluate().length >= count;
      },
      timeout: TestTimeouts.medium,
    );
    expect($(EmailTileBuilder).evaluate().length, greaterThanOrEqualTo(count));
  }

  @override
  Future<void> expectEmptyResults() async {
    await $(const Key(UiKeys.emptyThreadView)).waitUntilVisible();
  }
}
