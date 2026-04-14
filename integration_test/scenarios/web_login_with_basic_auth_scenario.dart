import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/login/presentation/login_view_web.dart';
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

    await _expectCredentialInputFormVisible();

    await loginRobot.enterBasicAuthEmail(email);

    await loginRobot.enterBasicAuthPassword(password);

    await loginRobot.loginBasicAuth();

    await _expectThreadViewVisible();
  }

  Future<void> _expectCredentialInputFormVisible() async {
    await expectViewVisible($(LoginView).$(#credential_input_form));
  }

  Future<void> _expectThreadViewVisible() => expectViewVisible($(ThreadView));
}