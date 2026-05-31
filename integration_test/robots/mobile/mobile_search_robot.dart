import 'package:patrol/patrol.dart';

import '../abstract/abstract_search_robot.dart';
import '../search_robot.dart';

class MobileSearchRobot extends SearchRobot implements AbstractSearchRobot {
  MobileSearchRobot(PatrolIntegrationTester $) : super($);

  @override
  Future<void> verifySearchSuggestionHighlights(String keyword) async {
    // Mobile: SearchEmailView renders suggestions directly in its widget tree
    await $.waitUntilVisible($(RichTextBuilder));
    expect($(RichTextBuilder).$(keyword.split(' ').first).evaluate().length, 10);
  }
}
