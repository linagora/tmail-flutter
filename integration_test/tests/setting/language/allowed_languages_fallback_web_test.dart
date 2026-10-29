import 'package:flutter/widgets.dart';

import '../../../base/test_base.dart';
import '../../../models/test_tags.dart';
import '../../../scenarios/setting/language/allowed_languages_fallback_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should start in the first allowed language when English is not allowed on web',
    scenarioBuilder: ($, robots) => AllowedLanguagesFallbackScenario(
      $,
      robots,
      expectedLanguage: const Locale('mn', 'MN'),
    ),
    tags: [TestTags.web],
    envOverrides: const {'ALLOWED_LANGUAGES': 'mn,fr'},
  );
}
