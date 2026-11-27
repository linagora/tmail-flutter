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
}

class WebMailboxMenuRobot extends MobileMailboxMenuRobot {
  WebMailboxMenuRobot(super.$)
      : super(
          navigationRobot: WebMailboxNavigationRobot($),
          labelRobot: WebMailboxLabelRobot($),
          assertionRobot: WebMailboxAssertionRobot($),
        );

  @override
  Future<void> openSetting() => _tapAvatarMenuItem(
        AppLocalizations().manage_account,
        ProfileSettingActionType.manageAccount,
      );

  @override
  Future<void> tapSignOut() => _tapAvatarMenuItem(
        AppLocalizations().sign_out,
        ProfileSettingActionType.signOut,
      );

  @override
  Future<void> confirmSignOut() async {
    // Web: sign out runs at once, there is no confirm dialog.
  }

  Future<void> _tapAvatarMenuItem(String label, ProfileSettingActionType action) async {
    await $(const ValueKey(UiKeys.userAvatar)).tap();
    // With delegation on, the avatar opens the account switcher menu, whose footer has the row.
    final switcherRow = $(const ValueKey(UiKeys.accountSwitcherMenu)).$(label);
    final profileItem = $(ValueKey(action.name));
    await waitForCondition(
      () => switcherRow.exists || profileItem.exists,
      reason: 'avatar menu shows $label',
    );
    await (switcherRow.exists ? switcherRow : profileItem).tap();
  }
}
