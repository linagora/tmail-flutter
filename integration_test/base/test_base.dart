import 'package:core/utils/platform_info.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:tmail_ui_user/main/main_entry.dart';

import 'base_scenario.dart';

class TestBase {
  static final TestBase _instance = TestBase._internal();
  factory TestBase() => _instance;

  TestBase._internal();

  void runPatrolTest({
    required String description,
    required BaseScenario Function(PatrolIntegrationTester $) scenarioBuilder,
  }) {
    patrolSetUp(_setup);

    patrolTearDown(_tearDown);

    patrolTest(
      description,
      config: const PatrolTesterConfig(
        settlePolicy: SettlePolicy.trySettle,
        visibleTimeout: Duration(seconds: 30),
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
    await runTmail();

    final originalOnError = FlutterError.onError!;
    FlutterError.onError = (FlutterErrorDetails details) {
      originalOnError(details);
    };
  }

  Future<void> _setup() async {
    PlatformInfo.isIntegrationTesting = true;
  }

  Future<void> _tearDown() async {
    PlatformInfo.isIntegrationTesting = false;
  }
}