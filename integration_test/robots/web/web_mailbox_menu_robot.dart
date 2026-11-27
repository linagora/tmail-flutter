import 'package:flutter/material.dart';
import 'package:patrol/patrol.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/profile_setting/profile_setting_action_type.dart';

import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../utils/wait_for_condition.dart';
import '../mailbox_navigation_robot.dart';
import '../mobile/mobile_mailbox_menu_robot.dart';
import 'web_hover_tap.dart';
import 'web_mailbox_assertion_robot.dart';
import 'web_mailbox_label_robot.dart';

/// Web-specific navigation robot that simulates "long-press" via mouse hover
/// then tapping the more-action button, because mobile long-press gestures
/// are not available in a web browser context.
class WebMailboxNavigationRobot extends MailboxNavigationRobot {
  WebMailboxNavigationRobot(super.$);

  @override
  Future<void> longPressMailbox(PatrolFinder finder) async {
    await finder.waitUntilExists();
    await webHoverThenTap(
      $,
      finder,
      finder.$(const ValueKey(UiKeys.mailboxMoreActionButton)),
    );
  }

  /// Real touch long press, as on a phone browser drawer.
  Future<void> touchLongPressMailbox(PatrolFinder finder) =>
      super.longPressMailbox(finder);
}

class WebMailboxMenuRobot extends MobileMailboxMenuRobot {
  WebMailboxMenuRobot(super.$)
      : super(
          navigationRobot: WebMailboxNavigationRobot($),
          labelRobot: WebMailboxLabelRobot($),
          assertionRobot: WebMailboxAssertionRobot($),
        );

  @override
  Future<void> openSetting() async {
    await $(const ValueKey(UiKeys.userAvatar)).tap();
    // With delegation on, the avatar opens the account switcher menu, whose footer has the Manage row.
    final switcherManageRow = $(const ValueKey(UiKeys.accountSwitcherMenu))
        .$(AppLocalizations().manage_account);
    final profileManageItem = $(ValueKey(ProfileSettingActionType.manageAccount.name));
    await waitForCondition(
      () => switcherManageRow.exists || profileManageItem.exists,
      reason: 'avatar menu shows Manage account',
    );
    await (switcherManageRow.exists ? switcherManageRow : profileManageItem).tap();
  }
}
