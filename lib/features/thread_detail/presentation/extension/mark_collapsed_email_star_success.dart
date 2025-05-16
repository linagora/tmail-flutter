import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:model/email/mark_star_action.dart';
import 'package:model/extensions/presentation_email_extension.dart';
import 'package:tmail_ui_user/features/email/domain/state/mark_as_email_star_state.dart';
import 'package:tmail_ui_user/features/email/presentation/controller/single_email_controller.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

extension MarkCollapsedEmailStarSuccess on ThreadDetailController {
  void markCollapsedEmailStarSuccess(MarkAsStarEmailSuccess success) {
    final updatedMarkedEmail = emailIdsPresentation[success.emailId]
      ?.updateKeywords({
        KeyWordIdentifier.emailFlagged: success.markStarAction == MarkStarAction.markStar,
      });
    if (updatedMarkedEmail == null) return;

    if (mailboxDashBoardController.selectedEmail.value?.id == success.emailId) {
      mailboxDashBoardController.setSelectedEmail(updatedMarkedEmail);
    }
    final markedEmailController = getBinding<SingleEmailController>(
      tag: success.emailId.id.value,
    );
    if (markedEmailController != null) {
      markedEmailController.handleSuccessViewState(success);
    } else {
      emailIdsPresentation[success.emailId] = updatedMarkedEmail;
    }
  }
}