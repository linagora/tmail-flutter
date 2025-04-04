
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../base/core_robot.dart';

class EmailAddressDialogRobot extends CoreRobot {
  EmailAddressDialogRobot(super.$);

  Future<void> tapCloseDialogButton() async {
    await $(#email_address_dialog_close_button).tap();
  }

  Future<void> tapCopyEmailAddressButton(AppLocalizations appLocalizations) async {
    await $(appLocalizations.copy_email_address).tap();
  }

  Future<void> tapComposeEmailButton(AppLocalizations appLocalizations) async {
    await $(appLocalizations.compose_email).tap();
  }

  Future<void> tapCreateRuleWithThisEmailAddressButton(AppLocalizations appLocalizations) async {
    await $(appLocalizations.quickCreatingRule).tap();
  }
}