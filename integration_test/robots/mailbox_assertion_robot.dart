import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/namespace.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:model/mailbox/mailbox_constants.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:patrol/patrol.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/sidebar/sidebar_mailbox_item.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

import '../base/core_robot.dart';
import '../utils/wait_for_condition.dart';
import '../utils/wait_for_mailbox_ready.dart';
import 'abstract/abstract_mailbox_assertion_robot.dart';

typedef _MailboxMatcher = bool Function(PresentationMailbox mailbox);

class MailboxAssertionRobot extends CoreRobot implements AbstractMailboxAssertionRobot {
  MailboxAssertionRobot(super.$);

  @override
  Future<void> expectMailboxVisible(PatrolFinder finder) async {
    await waitForCondition(() async => finder.evaluate().isNotEmpty);
    expect(finder, findsWidgets);
  }

  @override
  Future<void> expectSubfolderNotExist(PatrolFinder finder) async {
    await waitForCondition(() => !finder.exists);
  }

  @override
  Future<void> expectPersonalInboxSelected() async {
    await waitForMailboxReady();
    final selectedMailbox =
        getBinding<MailboxDashBoardController>()?.selectedMailbox.value;

    expect(selectedMailbox?.isPersonal, isTrue);
    expect(selectedMailbox?.role, PresentationMailbox.roleInbox);
  }

  @override
  Future<void> expectTeamMailboxCollapsed(String teamMailboxEmail) async {
    final teamMailboxRoot = _teamMailboxItem(
      teamMailboxEmail,
      (mailbox) => mailbox.isTeamMailboxRoot,
    );
    await waitForCondition(() => teamMailboxRoot.evaluate().isNotEmpty);

    expect(teamMailboxRoot, findsOneWidget);
    expect(
      _teamMailboxItem(
        teamMailboxEmail,
        (mailbox) => mailbox.isChildOfTeamMailboxes,
      ),
      findsNothing,
    );
  }

  @override
  Future<void> expectTeamMailboxChildVisible(
    String teamMailboxEmail,
    String childName,
  ) async {
    final teamMailboxChild = _teamMailboxItem(
      teamMailboxEmail,
      (mailbox) =>
          mailbox.isChildOfTeamMailboxes && mailbox.name?.name == childName,
    );
    await waitForCondition(() => teamMailboxChild.evaluate().isNotEmpty);

    expect(teamMailboxChild, findsOneWidget);
  }

  PatrolFinder _teamMailboxItem(
    String teamMailboxEmail,
    _MailboxMatcher matches,
  ) {
    final namespace = Namespace('$teamMailboxNamespacePrefix$teamMailboxEmail]');
    return $(SidebarMailboxItem).which<SidebarMailboxItem>((item) {
      final mailbox = item.mailboxNode.item;
      return mailbox.namespace == namespace && matches(mailbox);
    });
  }
}
