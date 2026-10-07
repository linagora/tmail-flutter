import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../mobile/mobile_email_robot.dart';
import 'web_email_assertion_robot.dart';
import 'web_email_label_robot.dart';

class WebEmailRobot extends MobileEmailRobot {
  WebEmailRobot(PatrolIntegrationTester $)
      : super(
          $,
          assertionRobot: WebEmailAssertionRobot($),
          labelRobot: WebEmailLabelRobot($),
        );

  @override
  Future<void> expectDownloadSaveDialogVisible() async {
    final downloads = await $.platformAutomator.web.verifyFileDownloads();
    expect(downloads.any((name) => name.startsWith('TwakeMail-')), isTrue);
  }
}