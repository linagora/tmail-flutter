import '../../base/test_base.dart';
import '../../scenarios/login_with_basic_auth_scenario.dart';
import '../../scenarios/send_email_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should see success toast when send email successfully',
    test: ($) async {
      final loginWithBasicAuthScenario = LoginWithBasicAuthScenario($,
        username: const String.fromEnvironment('USERNAME'),
        hostUrl: const String.fromEnvironment('BASIC_AUTH_URL'),
        email: const String.fromEnvironment('BASIC_AUTH_EMAIL'),
        password: const String.fromEnvironment('PASSWORD'),
      );
      final sendEmailScenario = SendEmailScenario($,
        loginWithBasicAuthScenario: loginWithBasicAuthScenario,
        additionalRecipient: const String.fromEnvironment('ADDITIONAL_MAIL_RECIPIENT'),
        subject: 'Test subject',
        content: 'Test content');

      await sendEmailScenario.execute();
    },
  );
}