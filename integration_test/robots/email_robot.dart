import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../base/core_robot.dart';

class EmailRobot extends CoreRobot {
  EmailRobot(super.$);

  Future<void> onTapForwardEmail() async {
    await $(#forward_email_button).tap();
    await $.pump(const Duration(seconds: 2));
  }

  Future<void> tapDownloadAllButton() async {
    await $(AppLocalizations().downloadAll).tap();
    await $.pumpAndSettle();
  }
}