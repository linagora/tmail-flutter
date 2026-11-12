import 'package:core/utils/config/env_loader.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:tmail_ui_user/main.dart';
import 'package:tmail_ui_user/main/main_entry.dart';

import '../models/test_tags.dart';
import '../utils/backend_reset_client.dart';
import '../utils/dom_focus_logger.dart';
import '../utils/failure_diagnostics.dart';
import '../utils/mock_text_input.dart';
import '../utils/test_backend.dart';
import 'base_scenario.dart';
import '../factories/robot_factory.dart';
import '../factories/robot_factory_provider.dart';

class TestBase {
  static const Duration _testTimeout = Duration(minutes: 4);
  static final TestBase _instance = TestBase._internal();
  factory TestBase() => _instance;

  TestBase._internal();

  static TestTags get _currentPlatformTag {
    if (kIsWeb) return TestTags.web;
    return defaultTargetPlatform == TargetPlatform.android ? TestTags.android : TestTags.ios;
  }

  void runPatrolTest({
    required String description,
    required BaseScenario Function(PatrolIntegrationTester $, RobotFactory robots) scenarioBuilder,
    List<TestTags> tags = const [TestTags.ios],
    Map<String, String> envOverrides = const {},
    Timeout? timeout,
  }) {
    patrolSetUp(_setup);

    patrolTearDown(_tearDown);

    patrolTest(
      description,
      // Fail stuck tests before they consume the CI build timeout.
      timeout: timeout ?? const Timeout(_testTimeout),
      config: const PatrolTesterConfig(
        settlePolicy: SettlePolicy.trySettle,
        existsTimeout: Duration(seconds: 30),
        visibleTimeout: Duration(seconds: 30),
        settleTimeout: Duration(seconds: 30),
        printLogs: true,
      ),
      tags: tags.map((t) => t.name).toList(),
      // Skipped tests skip setUp/tearDown, so a page stops replaying every earlier bundle test.
      skip: !tags.contains(_currentPlatformTag),
      platformAutomatorConfig: PlatformAutomatorConfig.fromOptions(
        findTimeout: const Duration(seconds: 30),
      ),
      framePolicy: LiveTestWidgetsFlutterBindingFramePolicy.benchmarkLive,
      ($) async {
        if (registerMockTextInput) {
          $.tester.testTextInput.register();
          addTearDown($.tester.testTextInput.unregister);
        }
        try {
          final scenario = scenarioBuilder($, createRobotFactory($));
          await setupTest($, scenario, envOverrides: envOverrides);
          await scenario.execute();
        } catch (_) {
          dumpFailureState($);
          rethrow;
        }
      },
    );
  }

  Future<void> setupTest(
    PatrolIntegrationTester $,
    BaseScenario scenario, {
    Map<String, String> envOverrides = const {},
  }) async {
    await EnvLoader.loadEnvFile();
    // loadEnvFile clears dotenv first, so overrides never leak between tests
    dotenv.env.addAll(envOverrides);
    await runTmailPreload();
    // The preload reloads env.file, whose SERVER_URL the web login reads.
    if (TestBackend.leased != null) dotenv.env['SERVER_URL'] = TestBackend.current.url;
    await scenario.prepare();
    // Added before runApp so it logs ahead of the View's own focus handler.
    final viewFocusLogger = ViewFocusLogger();
    WidgetsBinding.instance.addObserver(viewFocusLogger);
    addTearDown(() => WidgetsBinding.instance.removeObserver(viewFocusLogger));
    addTearDown(startDomFocusLogging());
    runApp(const TMailApp());

    final originalOnError = FlutterError.onError!;
    var stateDumped = false;
    FlutterError.onError = (FlutterErrorDetails details) {
      logFlutterErrorDetails(details);
      // One dump per test: the first error carries the UI state that caused the rest.
      if (!stateDumped) {
        stateDumped = true;
        dumpFailureState($);
      }
      originalOnError(details);
    };
  }

  Future<void> _setup() async {
    PlatformInfo.isIntegrationTesting = true;
    if (BackendResetClient.isEnabled) {
      TestBackend.use(await BackendResetClient.lease());
    }
  }

  Future<void> _tearDown() async {
    PlatformInfo.isIntegrationTesting = false;
    final leased = TestBackend.leased;
    try {
      if (leased != null) await BackendResetClient.release(leased);
    } finally {
      TestBackend.use(null);
    }
  }
}
