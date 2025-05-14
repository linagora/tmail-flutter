
import 'package:model/support/contact_support_capability.dart';
import 'package:tmail_ui_user/features/home/domain/extensions/session_extensions.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';

extension ContactSupportCapabilityExtension on MailboxDashBoardController {
  ContactSupportCapability? get contactSupportCapability {
    final accountId = this.accountId.value;
    final session = sessionCurrent;

    if (accountId == null || session == null) return null;

    return session.getContactSupportCapability(accountId);
  }
}