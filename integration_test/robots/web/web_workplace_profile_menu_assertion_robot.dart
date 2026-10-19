import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/profile_setting/profile_setting_action_type.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/providers/cozy/inside_cozy_provider.dart';

import '../../base/core_robot.dart';
import '../abstract/abstract_workplace_profile_menu_assertion_robot.dart';

class WebWorkplaceProfileMenuAssertionRobot extends CoreRobot
    implements AbstractWorkplaceProfileMenuAssertionRobot {
  WebWorkplaceProfileMenuAssertionRobot(super.$);

  PatrolFinder get _manageAccountItem =>
      $(ValueKey(ProfileSettingActionType.manageAccount.name));

  @override
  Future<void> expectManageAccountVisible() async {
    await $.waitUntilVisible(_manageAccountItem);
  }

  @override
  Future<void> expectSignOutHidden() async {
    // Sign out is also hidden while the Cozy check loads, so assert only once
    // it has resolved to inside.
    final container = ProviderScope.containerOf(
      $.tester.element(_manageAccountItem),
      listen: false,
    );
    expect(await container.read(insideCozyProvider.future), isTrue);
    await $.pumpAndTrySettle();

    expect($(AppLocalizations().sign_out), findsNothing);
  }
}
