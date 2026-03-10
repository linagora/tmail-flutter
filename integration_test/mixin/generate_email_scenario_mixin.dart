import 'package:flutter_test/flutter_test.dart';

import '../base/base_scenario.dart';
import '../models/provisioning_email.dart';
import '../robots/email_robot.dart';
import 'scenario_utils_mixin.dart';

mixin GenerateEmailScenarioMixin on BaseScenario, ScenarioUtilsMixin {
  Future<void> generateEmailWithSubject({
    required String emailUser,
    required String subject,
  }) async {
    await provisionEmail(
      [
        ProvisioningEmail(
          toEmail: emailUser,
          subject: subject,
          content: subject,
        ),
      ],
      requestReadReceipt: false,
    );
    await $.pumpAndTrySettle();
  }

  Future<void> closeEmailDetailedView({required EmailRobot emailRobot}) async {
    await emailRobot.onTapBackButton();
  }
}
