import 'package:tmail_ui_user/features/starting_page/presentation/twake_welcome/twake_welcome_view.dart';

import '../../base/base_test_scenario.dart';
import '../../mixin/delegation_standalone_scenario_mixin.dart';
import '../../models/provisioning_email.dart';
import '../../utils/backend_reset_client.dart';
import '../../utils/test_backend.dart';
import '../../utils/wait_for_mailbox_ready.dart';

/// Bob, with Delegation on and alice's mailbox delegated (reset-server seed),
/// has his session ended with 401 while a search is shown, then signs in again.
/// Android and iOS app.
class SearchLeftOpenOnForcedSignOutScenario extends BaseTestScenario
    with DelegationStandaloneScenarioMixin {
  const SearchLeftOpenOnForcedSignOutScenario(super.$, super.robots);

  static const _username = String.fromEnvironment('USERNAME');
  static const _email = String.fromEnvironment('BASIC_AUTH_EMAIL');
  static const _password = String.fromEnvironment('PASSWORD');
  static const _searchedSubject = 'forced sign out searched';
  static const _otherSubject = 'forced sign out other';

  @override
  Future<void> runTestLogic() async {
    final threadRobot = robots.threadRobot();
    final searchRobot = robots.searchRobot();

    await robots.commonRobot().provisionEmail([
      ProvisioningEmail(toEmail: _email, subject: _otherSubject, content: _otherSubject),
      ProvisioningEmail(toEmail: _email, subject: _searchedSubject, content: _searchedSubject),
    ]);
    await $.waitUntilVisible($(_otherSubject));
    await enableDelegationAndReturnToMailbox();

    await threadRobot.tapOnSearchField();
    await searchRobot.enterKeyword('searched');
    await searchRobot.tapOnShowAllResultsText();
    await searchRobot.expectEmailListCountAtLeast(1);

    await BackendResetClient.setPassword(_username, 'changed-password');
    // Re-running the search gets a 401, which ends the session.
    await searchRobot.selectAttachmentFilter();
    await expectViewVisible($(TwakeWelcomeView));
    await BackendResetClient.setPassword(_username, _password);

    await robots.loginRobot().loginWithBasicAuth(
      username: _username,
      hostUrl: TestBackend.current.url,
      email: _email,
      password: _password,
    );
    await waitForMailboxReady();
    // Only the Inbox lists it: the search for "searched" left open before the sign-out does not.
    await $.waitUntilVisible($(_otherSubject));
  }
}
