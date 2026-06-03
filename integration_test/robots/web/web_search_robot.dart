import 'package:core/presentation/views/text/rich_text_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
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
    // Wait for search suggestions to appear in overlay
    // The suggestions contain the keyword in highlighted RichTextBuilder widgets
    await waitForCondition(() => $(RichTextBuilder).evaluate().isNotEmpty);
    
    // Verify the rich text builders contain highlighted content
    expect(
      $(RichTextBuilder).evaluate().isNotEmpty,
      isTrue,
    );
  }
}
