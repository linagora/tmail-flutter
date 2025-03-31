
import 'package:model/email/email_action_type.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/email_action_type_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

extension SetupEmailSubjectExtension on ComposerController {

  void setupEmailSubject(ComposerArguments arguments) {
    String subject = '';

    switch(currentEmailActionType!) {
      case EmailActionType.editAsNewEmail:
      case EmailActionType.editDraft:
      case EmailActionType.reply:
      case EmailActionType.replyToList:
      case EmailActionType.replyAll:
      case EmailActionType.forward:
      case EmailActionType.reopenComposerBrowser:
        subject = arguments.presentationEmail!.getEmailTitle().trim();
        break;
      case EmailActionType.editSendingEmail:
        subject = arguments.sendingEmail!.presentationEmail.getEmailTitle().trim();
        break;
      case EmailActionType.composeFromMailtoUri:
      case EmailActionType.composeFromUnsubscribeMailtoLink:
        subject = arguments.subject ?? '';
        break;
      default:
        break;
    }

    final newSubject = currentEmailActionType!.getSubjectComposer(
      currentContext,
      subject,
    );

    if (newSubject.isNotEmpty) {
      setSubjectEmail(subject);
      subjectEmailInputController.text = subject;
    }
  }
}