import 'package:tmail_ui_user/features/email/presentation/widgets/twp_warning_banner.dart';

import '../../utils/wait_for_condition.dart';
import '../email_assertion_robot.dart';

class WebEmailAssertionRobot extends EmailAssertionRobot {
  WebEmailAssertionRobot(super.$);

  @override
  Future<void> expectTwpWarningBannerVisible() async {
    // Web: the banner is not reliably hit-testable — assert via the element tree.
    await waitForCondition(
      () async => $(TwpWarningBanner).evaluate().isNotEmpty,
    );
  }
}
