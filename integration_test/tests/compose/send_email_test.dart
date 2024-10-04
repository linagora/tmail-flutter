import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../../base/test_base.dart';
import '../../scenarios/login_with_basic_auth.dart';
import '../../scenarios/send_email.dart';

void main() {
  patrolTest(
    'Should see success toast when send email successfully',
    config: const PatrolTesterConfig(
      settlePolicy: SettlePolicy.trySettle,
      visibleTimeout: Duration(minutes: 1)),
    nativeAutomatorConfig: const NativeAutomatorConfig(
      findTimeout: Duration(seconds: 10),
    ),
    framePolicy: LiveTestWidgetsFlutterBindingFramePolicy.benchmarkLive,
  ($) async {
    await TestBase().runTestApp();
    
    final loginWithBasicAuthScenario = LoginWithBasicAuth($,
      username: const String.fromEnvironment('USERNAME'),
      hostUrl: const String.fromEnvironment('BASIC_AUTH_URL'),
      email: const String.fromEnvironment('BASIC_AUTH_EMAIL'),
      password: const String.fromEnvironment('PASSWORD'),
    );
    final sendEmailScenario = SendEmail($,
      loginWithBasicAuthScenario: loginWithBasicAuthScenario,
      additionalRecipient: const String.fromEnvironment('ADDITIONAL_MAIL_RECIPIENT'),
      subject: 'Test subject',
      content: 'Test content');

    await sendEmailScenario.execute();
  });
}