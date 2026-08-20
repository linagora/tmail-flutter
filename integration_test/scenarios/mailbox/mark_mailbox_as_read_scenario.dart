import 'package:flutter_test/flutter_test.dart';
import 'package:linagora_design_flutter/linagora_design_flutter.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:patrol/patrol.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/sidebar/sidebar_mailbox_item.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../base/base_test_scenario.dart';
import '../../models/provisioning_email.dart';
import '../../robots/mailbox_menu_robot.dart';
import '../../robots/thread_robot.dart';

class MarkMailboxAsReadScenario extends BaseTestScenario {
  const MarkMailboxAsReadScenario(super.$, super.robots);

  @override
  Future<void> runTestLogic() async {
    const email = String.fromEnvironment('BASIC_AUTH_EMAIL');

    final threadRobot = ThreadRobot($);
    final mailboxMenuRobot = MailboxMenuRobot($);

    await robots.commonRobot().provisionEmail([ProvisioningEmail(
      toEmail: email,
      subject: 'placeholder email',
      content: ''
    )]);
    await $.pumpAndSettle(duration: const Duration(seconds: 2));
    await threadRobot.openMailbox();
    await $.pumpAndTrySettle();
    _expectInboxUnreadCountVisible();

    await mailboxMenuRobot.navigation.longPressMailbox(
      mailboxMenuRobot.mailboxItemByName(AppLocalizations().inboxMailboxDisplayName),
    );
    await mailboxMenuRobot.tapMarkAsRead();
    await threadRobot.openMailbox();
    await $.pumpAndTrySettle();
    _expectInboxUnreadCountInvisible();
  }

  void _expectInboxUnreadCountVisible() {
    expect(_inboxItem.$(LinagoraSidebarBadge), findsOneWidget);
  }

  void _expectInboxUnreadCountInvisible() {
    expect(_inboxItem.$(LinagoraSidebarBadge), findsNothing);
  }

  PatrolFinder get _inboxItem => $(SidebarMailboxItem)
      .which<SidebarMailboxItem>((widget) =>
          widget.mailboxNode.item.role == PresentationMailbox.roleInbox);
}
