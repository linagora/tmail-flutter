import 'package:flutter_dotenv/flutter_dotenv.dart';
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
    await TestBase().runTestApp();

    final loginWithOidcScenario = LoginWithOidc($,
      email: dotenv.get('USERNAME'),
      password: dotenv.get('PASSWORD'),
      hostUrl: dotenv.get('HOST_URL'));

    await loginWithOidcScenario.execute();
  });
}