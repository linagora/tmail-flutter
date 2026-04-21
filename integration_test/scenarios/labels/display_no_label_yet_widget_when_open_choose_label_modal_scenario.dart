import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/labels/presentation/widgets/no_label_yet_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../base/base_test_scenario.dart';
import '../../models/provisioning_email.dart';
import '../../robots/labels/choose_label_modal_robot.dart';
import '../../robots/thread_robot.dart';

class DisplayNoLabelYetWidgetWhenOpenChooseLabelModalScenario
    extends BaseTestScenario {
  const DisplayNoLabelYetWidgetWhenOpenChooseLabelModalScenario(super.$, super.robots);

  @override
  Future<void> runTestLogic() async {
    const emailUser = String.fromEnvironment('BASIC_AUTH_EMAIL');
    expect(emailUser, isNotEmpty, reason: 'BASIC_AUTH_EMAIL must be set');

    final threadRobot = ThreadRobot($);
    final chooseLabelModalRobot = ChooseLabelModalRobot($);

    await provisionEmail(
      [
        ProvisioningEmail(
          toEmail: emailUser,
          subject: 'Test email for no-label modal',
          content: 'Content',
        ),
      ],
      requestReadReceipt: false,
    );
    await $.pumpAndSettle(duration: const Duration(seconds: 2));

    await threadRobot.longPressEmailWithSubject('Test email for no-label modal');
    await $.pumpAndTrySettle();

    await threadRobot.tapLabelAsButton();
    await $.pumpAndTrySettle();

    await _expectNoLabelYetWidgetVisible(chooseLabelModalRobot);
  }

  Future<void> _expectNoLabelYetWidgetVisible(
    ChooseLabelModalRobot chooseLabelModalRobot,
  ) async {
    await expectViewVisible($(NoLabelYetWidget));
    await expectViewVisible($(find.text(AppLocalizations().noLabelsYet)));
    await expectViewVisible($(find.text(AppLocalizations().createALabel)));
    expect(chooseLabelModalRobot.isLabelListVisible, isFalse);
  }
}
