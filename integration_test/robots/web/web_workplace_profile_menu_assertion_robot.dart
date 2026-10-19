import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/profile_setting/profile_setting_action_type.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../base/core_robot.dart';
import '../abstract/abstract_workplace_profile_menu_assertion_robot.dart';

class WebWorkplaceProfileMenuAssertionRobot extends CoreRobot
    implements AbstractWorkplaceProfileMenuAssertionRobot {
  WebWorkplaceProfileMenuAssertionRobot(super.$);

  @override
  Future<void> expectManageAccountVisible() async {
    await $.waitUntilVisible(
      $(ValueKey(ProfileSettingActionType.manageAccount.name)),
    );
  }

  @override
  Future<void> expectSignOutHidden() async {
    expect($(AppLocalizations().sign_out), findsNothing);
  }
}
