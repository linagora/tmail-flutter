import 'package:flutter/widgets.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';

import '../../../base/base_test_scenario.dart';

class AllowedLanguagesScenario extends BaseTestScenario {
  const AllowedLanguagesScenario(
    super.$,
    super.robots, {
    required this.listedLanguages,
    this.hiddenLanguages = const [],
  });

  final List<Locale> listedLanguages;
  final List<Locale> hiddenLanguages;

  @override
  Future<void> runTestLogic() async {
    final mailboxMenuRobot = robots.mailboxMenuRobot();
    final settingsRobot = robots.settingsRobot();
    final languageRobot = settingsRobot.languageRobot;

    await mailboxMenuRobot.openSetting();
    await settingsRobot.openSettingsDetail(AccountMenuItem.languageAndRegion);
    await languageRobot.openLanguagePicker();

    await languageRobot.expectLanguagesListed(listedLanguages);
    await languageRobot.expectLanguagesNotListed(hiddenLanguages);
  }
}
