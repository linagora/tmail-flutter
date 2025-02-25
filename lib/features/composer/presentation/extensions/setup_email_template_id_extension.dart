import 'package:model/email/email_action_type.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';

extension SetupEmailTemplateIdExtension on ComposerController {
  void setupEmailTemplateId(ComposerArguments arguments) {
    if (currentEmailActionType == EmailActionType.editAsNewEmail ||
        currentEmailActionType == EmailActionType.reopenComposerBrowser
    ) {
      currentTemplateEmailId = arguments.savedEmailTemplateId;
    }
  }
}