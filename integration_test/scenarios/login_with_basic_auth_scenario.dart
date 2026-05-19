import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/thread/presentation/thread_view.dart';

import '../base/base_test_scenario.dart';

class LoginWithBasicAuthScenario extends BaseTestScenario {
  const LoginWithBasicAuthScenario(
    super.$,
    super.robots, {
    required this.username,
    required this.hostUrl,
    required this.email,
    required this.password,
  });

  final String username;
  final String hostUrl;
  final String email;
  final String password;

  // Skip credential seeding — test the actual login UI flow.
  @override
  Future<void> execute() async {
    await robots.loginRobot().loginWithBasicAuth(
      username: username,
      hostUrl: hostUrl,
      email: email,
      password: password,
    );
    await runTestLogic();
  }

  @override
  Future<void> runTestLogic() async {
    await timedStep('expect_thread_view', _expectThreadViewVisible);
  }

  Future<void> _expectThreadViewVisible() => expectViewVisible($(ThreadView));
}
