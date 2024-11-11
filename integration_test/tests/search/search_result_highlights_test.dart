import '../../base/test_base.dart';
import '../../scenarios/login_with_basic_auth_scenario.dart';
import '../../scenarios/search_result_highlights_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should see highlighted keyword in search result',
    test: ($) async {
      const keyword = 'Search snippet results';

      const longContentWithSearchKeywordAtTheStart = "$keyword Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s";
      const longContentWithSearchKeywordAtTheMiddle = "Lorem Ipsum is simply dummy text of the printing and typesetting industry. $keyword Lorem Ipsum has been the industry's standard dummy text ever since the 1500s";
      const longContentWithSearchKeywordAtTheEnd = "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s $keyword";

      final loginWithBasicAuthScenario = LoginWithBasicAuthScenario($,
        username: const String.fromEnvironment('USERNAME'),
        hostUrl: const String.fromEnvironment('BASIC_AUTH_URL'),
        email: const String.fromEnvironment('BASIC_AUTH_EMAIL'),
        password: const String.fromEnvironment('PASSWORD'),
      );

      final searchResultHighlightsScenario = SearchResultHighlightsScenario(
        $,
        loginWithBasicAuthScenario: loginWithBasicAuthScenario,
        keyword: keyword,
        longEmailContents: [
          longContentWithSearchKeywordAtTheStart,
          longContentWithSearchKeywordAtTheMiddle,
          longContentWithSearchKeywordAtTheEnd
        ],
      );

      await searchResultHighlightsScenario.execute();
    }
  );
}