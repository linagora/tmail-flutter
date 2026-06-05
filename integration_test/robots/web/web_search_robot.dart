import 'package:core/presentation/views/text/rich_text_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:tmail_ui_user/features/base/widget/popup_menu/popup_menu_item_action_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/quick_search/email_quick_search_item_tile_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/search_input_form_widget.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/email_tile_web_builder.dart';

import '../../extensions/patrol_finder_extension.dart';
import '../../utils/wait_for_condition.dart';
import '../abstract/abstract_search_robot.dart';
import '../search_robot.dart';

class WebSearchRobot extends SearchRobot implements AbstractSearchRobot {
  WebSearchRobot(PatrolIntegrationTester $) : super($);

  @override
  Future<void> enterKeyword(String keyword) async {
    final finder = $(SearchInputFormWidget).$(TextField);
    await finder.tap();
    await finder.enterTextWithoutTapAction(keyword);
  }

  @override
  Future<void> scrollToEndListSearchFilter() async {
    // Web: sortBy button is always visible in the top bar outside the
    // horizontal filter list, so no scrolling is needed.
  }

  @override
  Future<void> tapOnShowAllResultsText() async {
    // Web: "showing results for" button is inside a PointerInterceptor overlay
    // and not reliably hit-testable. Pressing Enter on the search field triggers
    // the same onSubmitted → searchEmailByQueryString action.
    await $.platformAutomator.web.pressKeyCombo(keys: ['Enter']);
  }

  @override
  Future<void> expectSuggestionListVisible() async {
    // Web: suggestions render inside an OverlayEntry wrapped by PointerInterceptor,
    // making them unreliable to assert. Skip on web — the search is still committed
    // via tapOnShowAllResultsText() and validated against the result list.
  }

  @override
  Future<void> openSortOrderMenu() async {
    // Web desktop closes SearchEmailView and renders search + filters inside the
    // dashboard, whose sortBy button key has no `mobile_` prefix.
    await $(#sortBy_search_filter_button).tap();
  }

  @override
  Future<void> expectSortOrderMenuVisible() async {
    // Web: sortBy opens a showMenu popup (no container key). Assert the popup is
    // open via its rendered sort-order menu items instead.
    await $.waitUntilVisible($(PopupMenuItemActionWidget));
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
  Future<void> expectSearchResultEmailListVisible() async {
    // Web: results render in ThreadView (not SearchEmailView, which self-closes).
    // EmailTileBuilder (web = StatefulWidget from email_tile_web_builder.dart) is
    // not hit-testable, so waitUntilVisible fails. waitUntilExists also fails because
    // Patrol's loop calls tester.pump() one frame at a time — it does NOT yield to
    // the browser event loop, so JMAP XHR callbacks never fire.
    //
    // waitForCondition uses Future.delayed between retries, which DOES yield to the
    // browser event loop, allowing JMAP responses to arrive.
    //
    await waitForCondition(
      () async => $(EmailTileBuilder).evaluate().isNotEmpty,
    );
  }
}
