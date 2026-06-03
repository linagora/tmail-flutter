import 'package:core/presentation/views/text/rich_text_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/quick_search/email_quick_search_item_tile_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/search_input_form_widget.dart';

import '../../extensions/patrol_finder_extension.dart';
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
  Future<void> verifySearchSuggestionHighlights(String keyword) async {
    // Web: suggestions render inside an OverlayEntry wrapped by PointerInterceptor,
    // so they are not hit-testable. Use waitUntilExists instead of waitUntilVisible.
    await $.waitUntilExists($(EmailQuickSearchItemTileWidget));
    expect(
      $(EmailQuickSearchItemTileWidget).$(RichTextBuilder).evaluate().isNotEmpty,
      isTrue,
    );
  }
}
