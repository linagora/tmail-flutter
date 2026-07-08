import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../mobile/mobile_email_robot.dart';
import 'web_email_assertion_robot.dart';

class WebEmailRobot extends MobileEmailRobot {
  // Inject the web assertion sub-robot (non-hit-testable waits) — composite
  // platform injection instead of overriding assertions on the root.
  WebEmailRobot(PatrolIntegrationTester $)
      : super($, assertionRobot: WebEmailAssertionRobot($));

  @override
  Future<void> expectDownloadSaveDialogVisible() async {
    final downloads = await $.platformAutomator.web.verifyFileDownloads();
    expect(downloads.any((name) => name.startsWith('TwakeMail-')), isTrue);
  }
}