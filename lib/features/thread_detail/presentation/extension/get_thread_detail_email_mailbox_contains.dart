import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/presentation_email_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';

extension GetThreadDetailEmailMailboxContains on ThreadDetailController {
  PresentationMailbox? getThreadDetailEmailMailboxContains(
    PresentationEmail presentationEmail,
  ) {
    return presentationEmail.findMailboxContain(
      mailboxDashBoardController.mapMailboxById,
    );  
  }
}