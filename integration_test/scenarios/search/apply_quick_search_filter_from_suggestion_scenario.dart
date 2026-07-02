import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/quick_search_filter.dart';

import '../../base/base_test_scenario.dart';
import '../../models/provisioning_email.dart';

/// A suggestion-overlay chip commits the filter immediately, so one submit
/// returns results already narrowed by it.
class ApplyQuickSearchFilterFromSuggestionScenario extends BaseTestScenario {
  const ApplyQuickSearchFilterFromSuggestionScenario(super.$, super.robots);

  static const keyword = 'Quicksearchsuggestion';
  static const attachedSubject = '$keyword attached';
  static const plainSubject = '$keyword plain';

  @override
  Future<void> runTestLogic() async {
    const email = String.fromEnvironment('BASIC_AUTH_EMAIL');

    final commonRobot = robots.commonRobot();
    final threadRobot = robots.threadRobot();
    final searchRobot = robots.searchRobot();

    final file = await commonRobot.prepareTxtFile(keyword);
    await commonRobot.provisionEmail([
      ProvisioningEmail(
        toEmail: email,
        subject: attachedSubject,
        content: attachedSubject,
        fileInfos: [file],
      ),
      ProvisioningEmail(
        toEmail: email,
        subject: plainSubject,
        content: plainSubject,
      ),
    ]);
    await $.waitUntilVisible($(attachedSubject));

    await threadRobot.tapOnSearchField();
    await searchRobot.enterKeyword(keyword);

    // Chip commits immediately, so it reads selected before submit.
    await searchRobot.suggestion
        .tapQuickSearchFilter(QuickSearchFilter.hasAttachment);
    await searchRobot.assertion
        .expectQuickSearchFilterSelected(QuickSearchFilter.hasAttachment);

    // One submit applies the committed filter.
    await searchRobot.tapOnShowAllResultsText();
    await searchRobot.expectEmailWithSubjectVisible(attachedSubject);
    await searchRobot.assertion.expectEmailSubjectNotPresent(plainSubject);
  }
}
