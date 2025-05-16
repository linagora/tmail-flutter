import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/presentation_email_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';

extension GetMailboxContainExtension on MailboxDashBoardController {
  PresentationMailbox? getMailboxContain(PresentationEmail email) {
    if (selectedMailbox.value == null) {
      return email.findMailboxContain(mapMailboxById);
    } else {
      return searchController.isSearchEmailRunning
        ? email.findMailboxContain(mapMailboxById)
        : selectedMailbox.value;
    }
  }
}