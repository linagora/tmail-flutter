import 'package:tmail_ui_user/features/login/presentation/login_view.dart';
import 'package:tmail_ui_user/features/starting_page/presentation/twake_welcome/twake_welcome_view.dart';
import 'package:tmail_ui_user/features/thread/presentation/thread_view.dart';

import '../base/base_scenario.dart';
import '../robots/login_robot.dart';

class LoginWithBasicAuthScenario extends BaseScenario {
  const LoginWithBasicAuthScenario(
    super.$, 
    {
      required this.username,
      required this.hostUrl,
      required this.email,
      required this.password,
    }
  );

  final String username;
  final String hostUrl;
  final String email;
  final String password;

  @override
  Future<void> execute() async {
    final loginRobot = LoginRobot($);

    await _expectWelcomeViewVisible();

    await loginRobot.tapOnUseCompanyServer();
    await _expectLoginViewVisible();

    await loginRobot.enterEmail(username);
    await loginRobot.enterHostUrl(hostUrl);

    await loginRobot.enterBasicAuthEmail(email);
    await loginRobot.enterBasicAuthPassword(password);
    await loginRobot.loginBasicAuth();

    await loginRobot.grantNotificationPermission($.native);

    await _expectThreadViewVisible();
  }

  Future<void> _expectWelcomeViewVisible() => expectViewVisible($(TwakeWelcomeView));

  Future<void> _expectLoginViewVisible() => expectViewVisible($(LoginView));

  Future<void> _expectThreadViewVisible() => expectViewVisible($(ThreadView));
}