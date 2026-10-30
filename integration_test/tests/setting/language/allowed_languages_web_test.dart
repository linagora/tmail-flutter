import 'package:flutter/widgets.dart';

import '../../../base/test_base.dart';
import '../../../models/test_tags.dart';
import '../../../scenarios/setting/language/allowed_languages_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should list only the allowed languages when ALLOWED_LANGUAGES is set on web',
    scenarioBuilder: ($, robots) => AllowedLanguagesScenario(
      $,
      robots,
      listedLanguages: const [Locale('mn', 'MN'), Locale('en', 'US')],
      hiddenLanguages: const [
        Locale('vi', 'VN'),
        Locale('fr', 'FR'),
        Locale('de', 'DE'),
      ],
    ),
    tags: [TestTags.web],
    envOverrides: const {'ALLOWED_LANGUAGES': 'mn,en'},
  );
}
