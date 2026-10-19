import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';

import '../../base/core_robot.dart';
import '../abstract/abstract_workplace_profile_menu_assertion_robot.dart';
import '../abstract/abstract_workplace_profile_menu_robot.dart';
import 'web_workplace_profile_menu_assertion_robot.dart';

/// Web only: Twake Workplace embeds the app in a browser and swaps the avatar
/// for a settings button next to the search field.
class WebWorkplaceProfileMenuRobot extends CoreRobot
    implements AbstractWorkplaceProfileMenuRobot {
  @override
  final AbstractWorkplaceProfileMenuAssertionRobot assertion;

  WebWorkplaceProfileMenuRobot(super.$)
      : assertion = WebWorkplaceProfileMenuAssertionRobot($);

  @override
  Future<void> openProfileMenu() async {
    await $(const ValueKey(UiKeys.workplaceSettingsButton)).tap();
    await $.pumpAndTrySettle();
  }
}
