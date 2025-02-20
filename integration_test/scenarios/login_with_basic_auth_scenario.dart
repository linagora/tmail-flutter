import 'package:flutter_test/flutter_test.dart';
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

    await $.pumpAndSettle();
    await _expectWelcomeViewVisible();

    await loginRobot.tapOnUseCompanyServer();
    await _expectLoginViewVisible();

    await loginRobot.enterEmail(username);
    await _expectUsernameToBeEntered();

    await loginRobot.tapOnNextButton();
    await _expectBaseUrlFormVisible();

    await loginRobot.enterHostUrl(hostUrl);
    await _expectHostUrlToBeEntered();

    await loginRobot.tapOnNextButton();
    await _expectCredentialInputFormVisible();

    await loginRobot.enterBasicAuthEmail(email);
    await _expectEmailToBeEntered();

    await loginRobot.enterBasicAuthPassword(password);

    await loginRobot.loginBasicAuth();

    await loginRobot.grantNotificationPermission($.native);

    await _expectThreadViewVisible();
  }

  Future<void> _expectWelcomeViewVisible() => expectViewVisible($(TwakeWelcomeView));

  Future<void> _expectLoginViewVisible() => expectViewVisible($(LoginView));

  Future<void> _expectBaseUrlFormVisible() async {
    await expectViewVisible($(LoginView).$(#base_url_form));
  }

  Future<void> _expectUsernameToBeEntered() async {
    await expectViewVisible($(find.text(username)));
  }

  Future<void> _expectHostUrlToBeEntered() async {
    final urlWithoutScheme = hostUrl
      .replaceFirst('https://', '')
      .replaceFirst('http://', '');

    await expectViewVisible($(find.textContaining(urlWithoutScheme)));
  }

  Future<void> _expectCredentialInputFormVisible() async {
    await expectViewVisible($(LoginView).$(#credential_input_form));
  }

  Future<void> _expectEmailToBeEntered() async {
    await expectViewVisible($(find.text(email)));
  }

  Future<void> _expectThreadViewVisible() => expectViewVisible($(ThreadView));
}