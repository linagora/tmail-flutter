import '../base/base_test_scenario.dart';
import '../models/provisioning_email.dart';

class SearchSuggestionHighlightsScenario extends BaseTestScenario {
  SearchSuggestionHighlightsScenario(super.$, super.robots);

  static const keyword = 'Search snippet suggestions';
  static const List<String> longEmailContents = [
    "$keyword Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s",
    "Lorem Ipsum is simply dummy text of the printing and typesetting industry. $keyword Lorem Ipsum has been the industry's standard dummy text ever since the 1500s",
    "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s $keyword",
  ];

  @override
  Future<void> runTestLogic() async {
    const email = String.fromEnvironment('BASIC_AUTH_EMAIL');

    final commonRobot = robots.commonRobot();
    final threadRobot = robots.threadRobot();
    final searchRobot = robots.searchRobot();

    final file = await commonRobot.prepareTxtFile(keyword);

    await commonRobot.provisionEmail(longEmailContents
      .map(
        (emailContent) => ProvisioningEmail(
          toEmail: email,
          subject: keyword,
          content: emailContent,
          fileInfos: emailContent == longEmailContents.first
            ? [file]
            : [],
        ),
      )
      .toList());
    await $.waitUntilVisible($(keyword));

    await threadRobot.tapOnSearchField();
    await searchRobot.enterKeyword(keyword);
    await searchRobot.verifySearchSuggestionHighlights(keyword);
  }
}