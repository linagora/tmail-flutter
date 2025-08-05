
import 'package:model/email/email_action_type.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/email/read_actions.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/open_and_close_composer_extension.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';

extension ThreadDetailOnEmailActionClick on ThreadDetailController {
  void threadDetailOnEmailActionClick(
    PresentationEmail presentationEmail,
    EmailActionType emailActionType,
  ) {
    switch(emailActionType) {
      case EmailActionType.markAsRead:
        _markRead(presentationEmail);
        break;
      case EmailActionType.reply:
        _replyEmail(presentationEmail);
        break;
      default:
        break;
    }
  }

  void _markRead(PresentationEmail presentationEmail) {
    if (session == null || accountId == null || presentationEmail.hasRead) return;

    consumeState(emailActionReactor.markAsEmailRead(
      session!,
      accountId!,
      presentationEmail,
      readAction: ReadActions.markAsRead,
    ));
  }

  void _replyEmail(PresentationEmail presentationEmail) {
    emailActionReactor.replyEmail(
      presentationEmail,
      onReplyEmailRequest: (presentationEmail, emailLoaded) {
        mailboxDashBoardController.openComposer(
          ComposerArguments.replyEmail(
            presentationEmail: presentationEmail,
            content: emailLoaded?.htmlContent,
            inlineImages: emailLoaded?.inlineImages,
            mailboxRole: presentationEmail.mailboxContain?.role,
            messageId: presentationEmail.messageId,
            references: presentationEmail.references,
            listPost: presentationEmail.listPost,
          )
        );
      },
      emailLoaded: null,
    );
  }
}