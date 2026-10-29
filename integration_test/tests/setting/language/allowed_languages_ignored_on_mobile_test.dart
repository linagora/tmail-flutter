import 'package:tmail_ui_user/main/localizations/localization_service.dart';

import '../../../base/test_base.dart';
import '../../../models/test_tags.dart';
import '../../../scenarios/setting/language/allowed_languages_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should list every language when ALLOWED_LANGUAGES is set on mobile',
    scenarioBuilder: ($, robots) => AllowedLanguagesScenario(
      $,
      robots,
      listedLanguages: LocalizationService.supportedLocales,
    ),
    tags: [TestTags.android, TestTags.ios],
    envOverrides: const {'ALLOWED_LANGUAGES': 'mn,en'},
  );
}
