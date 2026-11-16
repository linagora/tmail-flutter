import 'package:core/presentation/views/dialog/confirm_dialog_button.dart';
import 'package:linagora_design_flutter/linagora_design_flutter.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../base/core_robot.dart';
import 'abstract/abstract_delegation_settings_assertion_robot.dart';
import 'abstract/abstract_delegation_settings_robot.dart';
import 'delegation_settings_assertion_robot.dart';

class DelegationSettingsRobot extends CoreRobot
    implements AbstractDelegationSettingsRobot {
  @override
  final AbstractDelegationSettingsAssertionRobot assertion;

  DelegationSettingsRobot(super.$, {AbstractDelegationSettingsAssertionRobot? assertionRobot})
      : assertion = assertionRobot ?? DelegationSettingsAssertionRobot($);

  @override
  Future<void> tapRemoveAccess(String ownerAddress) async {
    await $(LinagoraPersonTile.actionKeyFor(ownerAddress)).tap();
  }

  @override
  Future<void> confirmRemoveAccess() async {
    await $(ConfirmDialogButton).$(AppLocalizations().removeAccess).tap();
  }
}
