import 'package:flutter_test/flutter_test.dart';

import '../../base/base_test_scenario.dart';
import '../../models/provisioning_email.dart';
import '../../robots/mailbox_menu_robot.dart';
import '../../robots/thread_robot.dart';

class QuotaCountScenario extends BaseTestScenario {
  const QuotaCountScenario(super.$);
  
  @override
  Future<void> runTestLogic() async {
    const email = String.fromEnvironment('BASIC_AUTH_EMAIL');

    final threadRobot = ThreadRobot($);
    final mailboxMenuRobot = MailboxMenuRobot($);

    await threadRobot.openMailbox();
    final beforeUsedQuota = await mailboxMenuRobot.getUsedQuota();

    final file = await preparingTxtFile('some content');
    await provisionEmail([ProvisioningEmail(
      toEmail: email,
      subject: 'test increase quota',
      content: '',
      attachmentPaths: [file.path],
    )]);
    await mailboxMenuRobot.refreshQuota();
    final afterUsedQuota = await mailboxMenuRobot.getUsedQuota();

    _expectQuotaIncreased(beforeUsedQuota, afterUsedQuota);
  }

  void _expectQuotaIncreased(int before, int after) {
    expect(after, greaterThan(before));
  }
}