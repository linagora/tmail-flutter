import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:tmail_ui_user/main.dart' as app;

class TestBase {
  void runPatrolTest({
    required String description,
    required Function(PatrolIntegrationTester $) test,
  }) {
    patrolTest(
      description,
      config: const PatrolTesterConfig(
        settlePolicy: SettlePolicy.trySettle,
        visibleTimeout: Duration(minutes: 1),
        printLogs: true,
      ),
      nativeAutomatorConfig: const NativeAutomatorConfig(
        findTimeout: Duration(seconds: 10),
      ),
      framePolicy: LiveTestWidgetsFlutterBindingFramePolicy.benchmarkLive,
    ($) async {
      await app.runTmail();
      // https://github.com/leancodepl/patrol/issues/1602#issuecomment-1665317814
      final originalOnError = FlutterError.onError!;
      FlutterError.onError = (FlutterErrorDetails details) {
        originalOnError(details);
      };
      
      await test($);
    });
  }
}