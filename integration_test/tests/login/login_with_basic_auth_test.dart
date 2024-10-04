import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../../base/test_base.dart';
import '../../scenarios/login_with_basic_auth.dart';

void main() {
  patrolTest(
    'Should see thread view when login with basic auth successfully',
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
      username: dotenv.get('USERNAME'),
      hostUrl: dotenv.get('BASIC_AUTH_URL'),
      email: dotenv.get('BASIC_AUTH_EMAIL'),
      password: dotenv.get('PASSWORD'),
    );

    await loginWithBasicAuthScenario.execute();
  });
}