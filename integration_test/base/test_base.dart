import 'package:core/utils/config/env_loader.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:tmail_ui_user/main/main_entry.dart';

import '../models/test_tags.dart';
import '../utils/backend_reset_client.dart';
import '../utils/test_timer.dart';
import 'base_scenario.dart';
import '../factories/robot_factory.dart';
import '../factories/robot_factory_provider.dart';

class TestBase {
  static final TestBase _instance = TestBase._internal();
  factory TestBase() => _instance;

  TestBase._internal();

  void runPatrolTest({
    required String description,
    required BaseScenario Function(PatrolIntegrationTester $, RobotFactory robots) scenarioBuilder,
    List<TestTags> tags = const [TestTags.android, TestTags.ios],
  }) {
    patrolSetUp(_setup);

    patrolTearDown(_tearDown);

    patrolTest(
      description,
      config: const PatrolTesterConfig(
        settlePolicy: SettlePolicy.trySettle,
        existsTimeout: Duration(seconds: 10),
        visibleTimeout: Duration(seconds: 10),
        settleTimeout: Duration(seconds: 10),
        printLogs: true,
      ),
      tags: tags.map((t) => t.name).toList(),
      platformAutomatorConfig: PlatformAutomatorConfig.fromOptions(
        findTimeout: const Duration(seconds: 10),
      ),
      framePolicy: LiveTestWidgetsFlutterBindingFramePolicy.benchmarkLive,
      ($) async {
        // Fire before startTest so harness_setup→test_body_start delta isolates
        // patrol's internal setUp-to-test scheduling overhead.
        await BackendResetClient.postEvent('test_body_start');
        TestTimer().startTest(description);
        await TestTimer().timedPhase('app_launch', setupTest);
        try {
          await scenarioBuilder($, createRobotFactory($)).execute();
          TestTimer().recordStatus('passed');
        } catch (_) {
          TestTimer().recordStatus('failed');
          rethrow;
        }
      },
    );
  }

  Future<void> setupTest() async {
    await TestTimer().timedStep('env_load', EnvLoader.loadEnvFile);
    await TestTimer().timedStep('app_start', runTmail);

    final originalOnError = FlutterError.onError!;
    FlutterError.onError = (FlutterErrorDetails details) {
      originalOnError(details);
    };
  }

  Future<void> _setup() async {
    PlatformInfo.isIntegrationTesting = true;
    await BackendResetClient.postEvent('harness_setup');
  }

  Future<void> _tearDown() async {
    PlatformInfo.isIntegrationTesting = false;
    await TestTimer().timedPhase('backend_reset', BackendResetClient.reset);
    await TestTimer().printReport();
    await BackendResetClient.postEvent('harness_teardown_end');
  }
}
