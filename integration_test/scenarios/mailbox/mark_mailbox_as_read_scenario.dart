import 'package:flutter_test/flutter_test.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/trailing_mailbox_item_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../base/base_test_scenario.dart';
import '../../models/provisioning_email.dart';
import '../../robots/mailbox_menu_robot.dart';
import '../../robots/thread_robot.dart';

class MarkMailboxAsReadScenario extends BaseTestScenario {
  const MarkMailboxAsReadScenario(super.$);

  @override
  Future<void> runTestLogic() async {
    const email = String.fromEnvironment('BASIC_AUTH_EMAIL');

    final threadRobot = ThreadRobot($);
    final mailboxMenuRobot = MailboxMenuRobot($);

    await provisionEmail([ProvisioningEmail(
      toEmail: email,
      subject: 'placeholder email',
      content: ''
    )]);
    await $.pumpAndSettle(duration: const Duration(seconds: 2));
    await threadRobot.openMailbox();
    await _expectInboxUnreadCountVisible();

    await mailboxMenuRobot.longPressMailboxWithName(
      AppLocalizations().inboxMailboxDisplayName,
    );
    await mailboxMenuRobot.tapMarkAsRead();
    await threadRobot.openMailbox();
    await _expectInboxUnreadCountInvisible();
  }

  Future<void> _expectInboxUnreadCountVisible() async {
    await expectViewVisible($(TrailingMailboxItemWidget)
      .which<TrailingMailboxItemWidget>((widget) {
        final mailbox = widget.mailboxNode.item;
        return mailbox.role == PresentationMailbox.roleInbox
          && mailbox.countUnReadEmailsAsString.isNotEmpty;
    }));
  }

  Future<void> _expectInboxUnreadCountInvisible() async {
    expect(
      $(TrailingMailboxItemWidget)
        .which<TrailingMailboxItemWidget>((widget) {
          final mailbox = widget.mailboxNode.item;
          return mailbox.role == PresentationMailbox.roleInbox
            && mailbox.countUnReadEmailsAsString.isEmpty;
        }
      ),
      findsOneWidget,
    );
  }
}
