import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';

import 'test_timeouts.dart';
import 'wait_for_condition.dart';

/// Waits until the dashboard's [role] mailbox counts at least [minTotalEmails].
///
/// Emails provisioned over JMAP reach the mailbox counters only on the next
/// Mailbox/changes; actions that read the counter (e.g. empty trash) must await it.
Future<void> waitForMailboxTotalEmails(
  Role role, {
  int minTotalEmails = 1,
  Duration timeout = TestTimeouts.long,
}) =>
    waitForCondition(
      () {
        final controller = Get.find<MailboxDashBoardController>();
        final mailboxId = controller.mapDefaultMailboxIdByRole[role];
        final count = controller.mapMailboxById[mailboxId]?.countTotalEmails ?? 0;
        return count >= minTotalEmails;
      },
      timeout: timeout,
    );
