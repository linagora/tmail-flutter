import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/quick_search_filter.dart';

import '../../base/base_test_scenario.dart';
import '../../models/provisioning_email.dart';

/// A suggestion-dropdown chip must appear in the advanced-search form (shared
/// committed filter).
class SyncQuickSearchFilterToAdvancedSearchScenario extends BaseTestScenario {
  const SyncQuickSearchFilterToAdvancedSearchScenario(super.$, super.robots);

  static const keyword = 'Advancedsyncsuggestion';

  @override
  Future<void> runTestLogic() async {
    const email = String.fromEnvironment('BASIC_AUTH_EMAIL');

    final commonRobot = robots.commonRobot();
    final threadRobot = robots.threadRobot();
    final searchRobot = robots.searchRobot();

    await commonRobot.provisionEmail([
      ProvisioningEmail(toEmail: email, subject: keyword, content: keyword),
    ]);
    await $.waitUntilVisible($(keyword));

    await threadRobot.tapOnSearchField();
    await searchRobot.enterKeyword(keyword);

    // Select the attachment chip in the suggestion dropdown.
    await searchRobot.suggestion
        .tapQuickSearchFilter(QuickSearchFilter.hasAttachment);

    // Advanced form seeds from the committed filter, so the checkbox is already checked.
    await searchRobot.openSearch();
    await searchRobot.assertion.expectAdvancedSearchHasAttachmentChecked();
  }
}
