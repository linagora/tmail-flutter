import 'package:model/email/presentation_email.dart';
import 'package:tmail_ui_user/features/email/presentation/bindings/email_bindings.dart';
import 'package:tmail_ui_user/features/email/presentation/controller/single_email_controller.dart';
import 'package:model/email/email_in_thread_status.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/focus_thread_detail_expanded_email.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

extension ToggleThreadDetailCollapeExpand on ThreadDetailController {
  void toggleThreadDetailCollapeExpand(PresentationEmail presentationEmail) {
    final emailId = presentationEmail.id;
    final expansionStatus = presentationEmail.emailInThreadStatus;
    if (emailId == null || expansionStatus == null) return;

    if (expansionStatus == EmailInThreadStatus.expanded) {
      emailIdsPresentation[emailId] = presentationEmail.copyWith(
        emailInThreadStatus: EmailInThreadStatus.collapsed,
      );
      return;
    }

    final isInitialized = getBinding<SingleEmailController>(
      tag: emailId.id.value,
    ) != null;
    if (!isInitialized) {
      EmailBindings(currentEmailId: presentationEmail.id).dependencies();
    } else {
      focusExpandedEmail(emailId);
    }
    for (var key in emailIds) {
      if (emailIdsPresentation[key] == null) continue;

      if (key == emailId) {
        emailIdsPresentation[key] = presentationEmail.copyWith(
          emailInThreadStatus: EmailInThreadStatus.expanded,
        );
        continue;
      }

      if (emailIdsPresentation[key]?.emailInThreadStatus == EmailInThreadStatus.expanded) {
        emailIdsPresentation[key] = emailIdsPresentation[key]?.copyWith(
          emailInThreadStatus: EmailInThreadStatus.collapsed,
        );
      }
    }
  }
}