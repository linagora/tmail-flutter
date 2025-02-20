import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:tmail_ui_user/main.dart' as app;

import 'base_scenario.dart';

class TestBase {
  static final TestBase _instance = TestBase._internal();
  factory TestBase() => _instance;

  TestBase._internal();

  void runPatrolTest({
    required String description,
    required BaseScenario Function(PatrolIntegrationTester $) scenarioBuilder,
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
        await setupTest();
        await scenarioBuilder($).execute();
      },
    );
  }

  Future<void> setupTest() async {
    await app.runTmail();

    final originalOnError = FlutterError.onError!;
    FlutterError.onError = (FlutterErrorDetails details) {
      originalOnError(details);
    };
  }
}