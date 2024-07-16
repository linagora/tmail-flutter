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
      visibleTimeout: Duration(seconds: 10)),
    nativeAutomatorConfig: const NativeAutomatorConfig(
      findTimeout: Duration(seconds: 10),
    ),
    framePolicy: LiveTestWidgetsFlutterBindingFramePolicy.fullyLive,
  ($) async {
    final loginWithOidcScenario = LoginWithOidc($,
      email: 'firstname100.surname100@upn.integration-open-paas.org',
      password: 'secret100',
      hostUrl: 'apisix.upn.integration-open-paas.org');
    final sendEmailScenario = SendEmail($,
      loginWithOidcScenario: loginWithOidcScenario,
      additionalRecipient: 'firstname21.surname21',
      subject: 'Test subject',
      content: 'Test content');

    TestBase().runTestApp();

    await sendEmailScenario.execute();
  });
}