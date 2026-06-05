import 'package:patrol/patrol.dart';
import 'package:flutter/material.dart';
import 'package:core/presentation/views/text/rich_text_builder.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/email_tile_builder.dart';

import '../abstract/abstract_search_robot.dart';
import '../search_robot.dart';

class MobileSearchRobot extends SearchRobot implements AbstractSearchRobot {
  MobileSearchRobot(PatrolIntegrationTester $) : super($);

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
  Future<void> verifySearchSuggestionHighlights(String keyword) async {
    // Mobile: SearchEmailView renders suggestions directly in its widget tree
    await $.waitUntilVisible($(RichTextBuilder));
    expect($(RichTextBuilder).$(keyword.split(' ').first).evaluate().length, 10);
  }

  @override
  Future<void> expectSearchResultEmailListVisible() async {
    await $.waitUntilVisible($(EmailTileBuilder));
  }
}
