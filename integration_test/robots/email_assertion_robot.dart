import 'package:tmail_ui_user/features/email/presentation/widgets/twp_warning_banner.dart';

import '../base/core_robot.dart';
import '../utils/wait_for_condition.dart';
import 'abstract/abstract_email_assertion_robot.dart';

class EmailAssertionRobot extends CoreRobot
    implements AbstractEmailAssertionRobot {
  EmailAssertionRobot(super.$);

  @override
  Future<void> expectTwpWarningBannerVisible() async {
    await $.waitUntilVisible($(TwpWarningBanner));
  }

  @override
  Future<void> expectTwpWarningBannerNotVisible() async {
    await waitForCondition(() async => $(TwpWarningBanner).evaluate().isEmpty);
  }
}
