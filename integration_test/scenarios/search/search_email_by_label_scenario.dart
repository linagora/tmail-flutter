import 'package:flutter_test/flutter_test.dart';
import 'package:labels/labels.dart';

import '../../base/base_test_scenario.dart';
import '../../mixin/provisioning_label_scenario_mixin.dart';
import '../../robots/abstract/abstract_search_robot.dart';

class SearchEmailByLabelScenario extends BaseTestScenario
    with ProvisioningLabelScenarioMixin {
  const SearchEmailByLabelScenario(super.$, super.robots);

  static const _searchLabel = 'search-label';
  static const _searchEmptyLabel = 'search-empty-label';

  @override
  Future<void> runTestLogic() async {
    const emailUser = String.fromEnvironment('BASIC_AUTH_EMAIL');

    final AbstractSearchRobot searchRobot = robots.searchRobot();
    final commonRobot = robots.commonRobot();

    final labels = await provisionLabelsByDisplayNames([
      _searchLabel,
      _searchEmptyLabel,
    ]);

    final searchLabel = labels.firstWhere(
      (l) => l.safeDisplayName == _searchLabel,
    );

    await commonRobot.provisionEmail(
      buildEmailsForLabel(label: searchLabel, toEmail: emailUser, count: 1),
      requestReadReceipt: false,
    );

    // Search by label that has emails
    await searchRobot.openSearch();
    await searchRobot.searchByLabel(_searchLabel);
    await searchRobot.expectEmailWithSubjectVisible(_searchLabel);

    // Search by label with no matching emails
    await searchRobot.openSearch();
    await searchRobot.searchByLabel(_searchEmptyLabel);
    await searchRobot.expectEmptyResults();
  }
}
