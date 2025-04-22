import 'package:tmail_ui_user/features/email/presentation/bindings/email_bindings.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/model/email_in_thread_status.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/state/get_emails_by_ids_state.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';

extension HandleGetEmailsByIdsSuccess on ThreadDetailController {
  void handleGetEmailsByIdsSuccess(GetEmailsByIdsSuccess success) {
    for (var presentationEmail in success.presentationEmails) {
      if (presentationEmail.id == null) continue;
      emailIdsPresentation[presentationEmail.id!] = presentationEmail;
      EmailBindings(initialEmail: presentationEmail).dependencies();
      emailIdsStatus[presentationEmail.id!] = EmailInThreadStatus.expanded;
    }
  }
}