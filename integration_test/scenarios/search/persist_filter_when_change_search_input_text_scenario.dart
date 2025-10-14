import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/search_filters/search_filter_button.dart';

import '../../base/base_test_scenario.dart';
import '../../models/provisioning_email.dart';
import '../../robots/search_robot.dart';
import '../../robots/thread_robot.dart';

class PersistFilterWhenChangeSearchInputTextScenario
    extends BaseTestScenario {
  const PersistFilterWhenChangeSearchInputTextScenario(super.$);

  @override
  Future<void> runTestLogic() async {
    const email = String.fromEnvironment('BASIC_AUTH_EMAIL');
    const subject = 'Persist search filter';
    const queryStringFirst = 'Persist search filter';
    const queryStringSecond = 'Persist search';

    final threadRobot = ThreadRobot($);
    final searchRobot = SearchRobot($);

    final file = await preparingTxtFile('attachment');
    await provisionEmail(
      [
        ProvisioningEmail(
          toEmail: email,
          subject: subject,
          content: subject,
          attachmentPaths: [file.path],
        ),
      ],
      requestReadReceipt: false,
    );
    await $.pumpAndSettle();

    await threadRobot.tapOnSearchField();
    await searchRobot.enterKeyword(queryStringFirst);
    await searchRobot.tapOnShowAllResultsText();
    await _expectEmailWithSubjectVisible(subject);

    await searchRobot.selectAttachmentFilter();
    await _expectEmailWithSubjectVisible(subject);
    _expectAttachmentFilterSelected();

    await searchRobot.enterKeyword(queryStringSecond);
    await _expectEmailWithSubjectVisible(subject);
    _expectAttachmentFilterSelected();
  }

  Future<void> _expectEmailWithSubjectVisible(String subject) async {
    await expectViewVisible($(find.text(subject)));
  }

  void _expectAttachmentFilterSelected() {
    expect(
      $(#mobile_hasAttachment_search_filter_button)
          .which<SearchFilterButton>((widget) => widget.isSelected)
          .visible,
      true,
    );
  }
}
