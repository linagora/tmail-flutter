import 'package:flutter_test/flutter_test.dart';

import '../../base/base_test_scenario.dart';
import '../../models/provisioning_email.dart';
import '../../robots/thread_robot.dart';

class PullToRefreshScenario extends BaseTestScenario {
  const PullToRefreshScenario(super.$);

  @override
  Future<void> runTestLogic() async {
    const toEmail = String.fromEnvironment('BASIC_AUTH_EMAIL');
    const visibleBeforePullToRefresh = 'before pull to refresh';
    const visibleAfterPullToRefresh = 'after pull to refresh';

    final threadRobot = ThreadRobot($);

    await provisionEmail(
      [ProvisioningEmail(
        toEmail: toEmail,
        subject: visibleBeforePullToRefresh,
        content: '',
      )],
    );
    await $.pumpAndSettle();
    _expectEmailWithSubjectVisible(visibleBeforePullToRefresh);

    await provisionEmail(
      [ProvisioningEmail(
        toEmail: toEmail,
        subject: visibleAfterPullToRefresh,
        content: '',
      )],
      refreshEmailView: false,
    );
    await $.pumpAndSettle();
    _expectEmailWithSubjectInvisible(visibleAfterPullToRefresh);

    await threadRobot.pullToRefreshByEmailSubject(visibleBeforePullToRefresh);
    _expectEmailWithSubjectVisible(visibleAfterPullToRefresh);
  }

  _expectEmailWithSubjectVisible(String subject) {
    expect($(subject), findsOneWidget);
  }

  _expectEmailWithSubjectInvisible(String subject) {
    expect($(subject), findsNothing);
  }
}