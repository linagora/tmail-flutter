
import 'package:model/email/email_action_type.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';

extension SetupEmailOtherComponentsExtension on ComposerController {

  void setupEmailOtherComponents(ComposerArguments arguments) {
    switch(currentEmailActionType) {
      case EmailActionType.editDraft:
        emailIdEditing = arguments.presentationEmail?.id;
        break;
      case EmailActionType.editSendingEmail:
        emailIdEditing = arguments.sendingEmail?.presentationEmail.id;
        break;
      case EmailActionType.reopenComposerBrowser:
        screenDisplayMode.value = arguments.displayMode;
        break;
      default:
        break;
    }

    minInputLengthAutocomplete = mailboxDashBoardController.minInputLengthAutocomplete;
  }
}