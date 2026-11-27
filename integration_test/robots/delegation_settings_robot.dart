import 'package:core/presentation/views/dialog/confirm_dialog_button.dart';
import 'package:flutter/foundation.dart';
import 'package:linagora_design_flutter/linagora_design_flutter.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/delegation/delegation_settings_view.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../base/core_robot.dart';
import 'abstract/abstract_add_delegates_robot.dart';
import 'abstract/abstract_delegation_settings_assertion_robot.dart';
import 'abstract/abstract_delegation_settings_robot.dart';
import 'add_delegates_robot.dart';
import 'delegation_settings_assertion_robot.dart';

class DelegationSettingsRobot extends CoreRobot
    implements AbstractDelegationSettingsRobot {
  @override
  final AbstractDelegationSettingsAssertionRobot assertion;

  @override
  final AbstractAddDelegatesRobot addDelegates;

  DelegationSettingsRobot(super.$, {AbstractDelegationSettingsAssertionRobot? assertionRobot})
      : assertion = assertionRobot ?? DelegationSettingsAssertionRobot($),
        addDelegates = AddDelegatesRobot($);

  @override
  Future<void> openDelegatedToMeTab() async {
    await $(LinagoraSegmentedTabs.segmentKey(DelegationTab.withMe)).tap();
  }

  @override
  Future<void> tapRemoveAccess(String ownerAddress) async {
    await $(LinagoraPersonTile.actionKeyFor(ownerAddress)).tap();
  }

  @override
  Future<void> confirmRemoveAccess() async {
    await $(ConfirmDialogButton).$(AppLocalizations().removeAccess).tap();
  }

  @override
  Future<void> confirmRemoveDelegate() async {
    await $(const ValueKey(UiKeys.removeDelegateSubmitButton)).tap();
  }
}
