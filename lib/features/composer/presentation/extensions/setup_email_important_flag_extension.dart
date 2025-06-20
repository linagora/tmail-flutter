
import 'package:model/email/email_action_type.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';

extension SetupEmailImportantFlagExtension on ComposerController {

  void setupEmailImportantFlag(ComposerArguments arguments) {
    switch(currentEmailActionType) {
      case EmailActionType.editAsNewEmail:
      case EmailActionType.editDraft:
        isMarkAsImportant.value = arguments.presentationEmail?.isMarkAsImportant ?? false;
        break;
      case EmailActionType.reopenComposerBrowser:
        isMarkAsImportant.value = arguments.isMarkAsImportant ?? false;
        break;
      case EmailActionType.editSendingEmail:
        isMarkAsImportant.value = arguments.sendingEmail?.presentationEmail.isMarkAsImportant ?? false;
        break;
      default:
        break;
    }
  }
}