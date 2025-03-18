import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/scroll_to_top_button_widget.dart';

import '../../base/base_test_scenario.dart';
import '../../models/provisioning_email.dart';
import '../../robots/thread_robot.dart';

class ScrollListEmailInMailboxAndBackToTopScenario extends BaseTestScenario {
  const ScrollListEmailInMailboxAndBackToTopScenario(super.$);

  String _getSubjectWithIndex(int emailIndex) => 'scroll email subject $emailIndex';

  @override
  Future<void> runTestLogic() async {
    const email = String.fromEnvironment('BASIC_AUTH_EMAIL');
    const totalEmails = 15;
    const bottomEmailSubject = 'scroll email subject bottom';

    final threadRobot = ThreadRobot($);

    await provisionEmail([ProvisioningEmail(
      toEmail: email,
      subject: bottomEmailSubject,
      content: '',
    )]);
    await $.pumpAndSettle(duration: const Duration(seconds: 2));
    await provisionEmail(List.generate(
      totalEmails,
      (index) => ProvisioningEmail(
        toEmail: email,
        subject: _getSubjectWithIndex(index),
        content: '$index',
      ),
    ));
    await $.pumpAndSettle(duration: const Duration(seconds: 2));

    await threadRobot.scrollToEmailWithSubject(bottomEmailSubject);
    await _expectScrollToTopButtonVisible();

    await threadRobot.scrollToTop();
    await _expectScrollToTopButtonInvisible();
  }
  
  _expectScrollToTopButtonVisible() {
    expect($(ScrollToTopButtonWidget), findsOneWidget);
  }

  Future<void> _expectScrollToTopButtonInvisible() async {
    expect($(ScrollToTopButtonWidget).visible, false);
  }
}