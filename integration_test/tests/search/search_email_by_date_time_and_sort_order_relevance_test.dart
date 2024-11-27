import '../../base/test_base.dart';
import '../../models/provisioning_email.dart';
import '../../scenarios/login_with_basic_auth_scenario.dart';
import '../../scenarios/search_email_by_date_time_and_sort_order_relevance_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should see list email displayed by date time `Last 7 days` and sort order `Relevance` when search email successfully',
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

      const queryString = 'relevance';
      const listUsername = ['Alice', 'Brian', 'Charlotte', 'David', 'Emma'];

      final listProvisioningEmail = listUsername
        .map((username) => ProvisioningEmail(
          toEmail: '${username.toLowerCase()}@example.com',
          subject: queryString,
          content: '$queryString to user $username',
        ))
        .toList();

      final searchEmailByDatetimeAndSortOrderRelevanceScenario = SearchEmailByDatetimeAndSortOrderRelevanceScenario(
        $,
        loginWithBasicAuthScenario: loginWithBasicAuthScenario,
        queryString: queryString,
        listProvisioningEmail: listProvisioningEmail,
      );

      await searchEmailByDatetimeAndSortOrderRelevanceScenario.execute();
    },
  );
}