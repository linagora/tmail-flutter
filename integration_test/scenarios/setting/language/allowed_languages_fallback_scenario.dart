import 'package:flutter/widgets.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';

import '../../../base/base_test_scenario.dart';

class AllowedLanguagesFallbackScenario extends BaseTestScenario {
  const AllowedLanguagesFallbackScenario(
    super.$,
    super.robots, {
    required this.expectedLanguage,
  });

  final Locale expectedLanguage;

  @override
  Future<void> runTestLogic() async {
    final mailboxMenuRobot = robots.mailboxMenuRobot();
    final settingsRobot = robots.settingsRobot();

    await mailboxMenuRobot.openSetting();
    await settingsRobot.openSettingsDetail(AccountMenuItem.languageAndRegion);

    await settingsRobot.languageRobot.assertion.expectLanguageSelected(
      expectedLanguage,
    );
  }
}
