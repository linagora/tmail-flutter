import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../../base/test_base.dart';
import '../../scenarios/login_with_oidc.dart';

void main() {
  patrolTest(
    'Should see thread view when login with oidc successfully',
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

    TestBase().runTestApp();

    await loginWithOidcScenario.execute();
  });
}