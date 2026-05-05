
import 'package:model/email/email_action_type.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/email_action_type_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

extension SetupEmailSubjectExtension on ComposerController {

  void setupEmailSubject(ComposerArguments arguments) {
    final actionType = currentEmailActionType;
    if (actionType == null) return;
    final subject = _resolveRawSubject(arguments, actionType);
    final newSubject = actionType.getSubjectComposer(currentContext, subject);
    if (newSubject.isNotEmpty) {
      setSubjectEmail(newSubject);
      subjectEmailInputController.text = newSubject;
    }
  }

  String _resolveRawSubject(ComposerArguments arguments, EmailActionType actionType) {
    if (actionType == EmailActionType.editSendingEmail) {
      return arguments.sendingEmail?.presentationEmail.getEmailTitle().trim() ?? '';
    }
    if (actionType == EmailActionType.composeFromMailtoUri ||
        actionType == EmailActionType.composeFromUnsubscribeMailtoLink) {
      return arguments.subject ?? '';
    }
    return arguments.presentationEmail?.getEmailTitle().trim() ?? '';
  }
}
