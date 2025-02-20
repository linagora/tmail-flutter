import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

import '../base/base_test_scenario.dart';
import '../models/provisioning_email.dart';
import '../robots/search_robot.dart';
import '../robots/thread_robot.dart';

class SearchResultHighlightsScenario extends BaseTestScenario {
  SearchResultHighlightsScenario(super.$);

  static const keyword = 'Search snippet results';
  static const List<String> longEmailContents = [
    "$keyword Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s",
    "Lorem Ipsum is simply dummy text of the printing and typesetting industry. $keyword Lorem Ipsum has been the industry's standard dummy text ever since the 1500s",
    "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s $keyword",
  ];

  @override
  Future<void> runTestLogic() async {
    const email = String.fromEnvironment('BASIC_AUTH_EMAIL');
    // Robots
    final threadRobot = ThreadRobot($);
    final searchRobot = SearchRobot($);

    // Prepare attachment file
    final file = await preparingTxtFile(keyword);

    // Provisioning some emails
    await provisionEmail(longEmailContents
      .map(
        (emailContent) => ProvisioningEmail(
          toEmail: email,
          subject: keyword,
          content: emailContent,
          attachmentPaths: emailContent == longEmailContents.first
            ? [file.path]
            : [],
        ),
      )
      .toList());
    await $.pumpAndSettle();

    // Search
    await threadRobot.tapOnSearchField();
    await searchRobot.enterKeyword(keyword);
    await searchRobot.tapOnShowAllResultsText();
    await $.pump(const Duration(seconds: 5));
    expect($(RichTextBuilder).$(keyword.split(' ').first).hitTestable().evaluate().length, 12);
  }
}