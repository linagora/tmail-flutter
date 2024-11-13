import '../../base/test_base.dart';
import '../../scenarios/login_with_basic_auth_scenario.dart';
import '../../scenarios/search_email_with_sort_order_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should see list email displayed by sort order selected when search email successfully',
    test: ($) async {
      const username = String.fromEnvironment('USERNAME');
      const password = String.fromEnvironment('PASSWORD');
      const hostUrl = String.fromEnvironment('BASIC_AUTH_URL');
      const email = String.fromEnvironment('BASIC_AUTH_EMAIL');

      final loginWithBasicAuthScenario = LoginWithBasicAuthScenario(
        $,
        username: username,
        password: password,
        hostUrl: hostUrl,
        email: email,
      );

      const queryString = 'hello';
      const listUsername = ['Alice', 'Brian', 'Charlotte', 'David', 'Emma'];

      final searchEmailWithSortOrderScenario = SearchEmailWithSortOrderScenario(
        $,
        loginWithBasicAuthScenario: loginWithBasicAuthScenario,
        queryString: queryString,
        listUsername: listUsername
      );

      await searchEmailWithSortOrderScenario.execute();
    },
  );
}