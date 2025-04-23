import 'package:flutter_test/flutter_test.dart';

import '../../base/base_test_scenario.dart';
import '../../models/provisioning_email.dart';
import '../../robots/search_robot.dart';
import '../../robots/thread_robot.dart';

class SearchSnippetsWithHtmlEscapeScenario extends BaseTestScenario {
  SearchSnippetsWithHtmlEscapeScenario(super.$);

  @override
  Future<void> runTestLogic() async {
    const email = String.fromEnvironment('BASIC_AUTH_EMAIL');
    const subject = '<Search snippets html escape>';

    final threadRobot = ThreadRobot($);
    final searchRobot = SearchRobot($);

    await provisionEmail(
      [ProvisioningEmail(toEmail: email, subject: subject, content: subject)],
      requestReadReceipt: false,
    );
    await $.pumpAndSettle();

    await threadRobot.tapOnSearchField();
    await searchRobot.enterKeyword(subject);
    await searchRobot.tapOnShowAllResultsText();
    await $.pumpAndSettle();

    await _expectEmailWithSubjectUnescapedVisible(subject);
  }

  Future<void> _expectEmailWithSubjectUnescapedVisible(String subject) async {
    await expectViewVisible($(find.text(subject)));
  }
}
