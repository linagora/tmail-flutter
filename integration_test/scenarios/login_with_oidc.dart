import '../base/base_scenario.dart';
import '../robots/login_robot.dart';
import '../robots/thread_robot.dart';

class LoginWithOidc extends BaseScenario {
  const LoginWithOidc(
    super.$, 
    {
      required this.email,
      required this.password,
      required this.hostUrl
    }
  );

  final String email;
  final String password;
  final String hostUrl;

  @override
  Future<void> execute() async {
    final loginRobot = LoginRobot($);
    final threadRobot = ThreadRobot($);

    await loginRobot.expectLoginViewVisible();
    await loginRobot.enterEmail(email);
    await loginRobot.enterHostUrl(hostUrl);

    try {
      await loginRobot.enterOidcUsername(email);
      await loginRobot.enterOidcPassword(password);
      await loginRobot.loginOidc();
    } catch (e) {
      await loginRobot.ignoreException();
    }

    await threadRobot.grantNotificationPermission();

    await threadRobot.expectThreadViewVisible();
  }
}