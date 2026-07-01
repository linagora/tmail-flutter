import 'package:flutter_test/flutter_test.dart';
import 'package:model/model.dart';

import '../../base/base_test_scenario.dart';
import '../../models/provisioning_twp_warning_email.dart';
import '../../provisioning/twp_warning_email_provisioner.dart';

/// Opens an email that arrives with a backend-positioned `X-TWP-Message`
/// warning header, asserts the warning banner is shown, dismisses it, and
/// asserts it disappears.
class DismissTwpWarningBannerScenario extends BaseTestScenario {
  const DismissTwpWarningBannerScenario(super.$, super.robots);

  @override
  Future<void> runTestLogic() async {
    const subject = 'TWP warning banner email';
    final threadRobot = robots.threadRobot();
    final emailRobot = robots.emailRobot();

    await const TwpWarningEmailProvisioner().provision(
      const ProvisioningTwpWarningEmail(
        subject: subject,
        level: TwpWarningLevel.warn,
        code: 'virus',
        message: 'This email contains a virus in its attachments!',
      ),
    );
    await $.pumpAndSettle();

    await threadRobot.openEmailWithSubject(subject);
    await $.pumpAndSettle();

    await emailRobot.assertion.expectTwpWarningBannerVisible();

    await emailRobot.twpWarning.tapDismissWarning();

    // Reopen the mail to prove the dismissal was persisted to the backend
    // (SetEmail keyword), not just optimistically hidden in the current view.
    await emailRobot.onTapBackButton();
    await threadRobot.openEmailWithSubject(subject);
    await $.pumpAndSettle();

    await emailRobot.assertion.expectTwpWarningBannerNotVisible();
  }
}
