import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../../base/test_base.dart';
import '../../scenarios/login_with_oidc.dart';
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
    
    final loginWithOidcScenario = LoginWithOidc($,
      email: dotenv.get('USERNAME'),
      password: dotenv.get('PASSWORD'),
      hostUrl: dotenv.get('HOST_URL'));
    final sendEmailScenario = SendEmail($,
      loginWithOidcScenario: loginWithOidcScenario,
      additionalRecipient: dotenv.get('ADDITIONAL_MAIL_RECIPIENT'),
      subject: 'Test subject',
      content: 'Test content');

    await sendEmailScenario.execute();
  });
}