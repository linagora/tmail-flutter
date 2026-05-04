import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_view.dart';

import '../../../base/app_constants.dart';
import '../../../base/base_test_scenario.dart';

/// RC1 scenario: composer survives app backgrounding.
///
/// Steps:
///   1. Login
///   2. Open composer → fill subject
///   3. Background the app (Home button) — triggers auto-save to Hive
///   4. Return to the app
///   5. Assert composer is still open with subject intact
class AndroidComposerBackgroundRestoreScenario extends BaseTestScenario {
  const AndroidComposerBackgroundRestoreScenario(super.$, super.robots);

  static const _subject = 'Auto-save background test';
  static const _appId = AppConstants.appId;

  @override
  Future<void> runTestLogic() async {
    final threadRobot = robots.threadRobot();
    final composerRobot = robots.composerRobot();
    final native = $.platformAutomator.android;

    await threadRobot.openComposer();
    await _expectComposerVisible();
    await composerRobot.grantContactPermission();
    await composerRobot.addSubject(_subject);

    // Backgrounding triggers AppLifecycleState.inactive → Hive auto-save.
    await native.pressHome();
    await $.pump(const Duration(seconds: 2));

    await native.openApp(appId: _appId);
    await $.pump(const Duration(seconds: 2));

    await _expectComposerVisible();
    await _expectSubjectVisible(_subject);
  }

  Future<void> _expectComposerVisible() => expectViewVisible($(ComposerView));

  Future<void> _expectSubjectVisible(String subject) =>
      expectViewVisible($(find.text(subject)));
}
