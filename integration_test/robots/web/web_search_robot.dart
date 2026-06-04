import 'package:core/presentation/views/text/rich_text_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:patrol/patrol.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/search_controller.dart' as search_controller_import;
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/quick_search/email_quick_search_item_tile_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/search_input_form_widget.dart';

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
  Future<void> verifySearchSuggestionHighlights(String keyword) async {
    // Wait for the search controller to have processed the keyword.
    final searchController = Get.find<search_controller_import.SearchController>();
    await waitForCondition(
      () => searchController.currentSearchText == keyword,
    );

    // EmailQuickSearchItemTileWidget renders inside an OverlayEntry
    // created by TypeAheadFieldQuickSearch, which is outside the main
    // widget tree that Patrol searches. WidgetTester searches the
    // entire element tree including overlay entries.
    await waitForCondition(
      () {
        try {
          final items = $.tester.widgetList(
            find.byType(EmailQuickSearchItemTileWidget),
          );
          return items.isNotEmpty;
        } catch (_) {
          return false;
        }
      },
    );

    // Verify that RichTextBuilder widgets (containing highlighted text)
    // exist in the overlay suggestion list.
    final richTextBuilders = $.tester.widgetList(
      find.byType(RichTextBuilder),
    );
    expect(richTextBuilders.isNotEmpty, isTrue);
  }
}
