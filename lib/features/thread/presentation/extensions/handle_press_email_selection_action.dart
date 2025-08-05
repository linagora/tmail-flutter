import 'package:model/email/presentation_email.dart';
import 'package:tmail_ui_user/features/thread/presentation/extensions/email_selection_action_type_extension.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/email_selection_action_type.dart';
import 'package:tmail_ui_user/features/thread/presentation/thread_controller.dart';

extension HandlePressEmailSelectionActionExtension on ThreadController {
  void handlePressEmailSelectionAction(
    EmailSelectionActionType type,
    List<PresentationEmail> emails,
  ) {
    final emailActionType = type.toEmailActionType();
    if (emailActionType != null) {
      pressEmailSelectionAction(emailActionType, emails);
    }
  }
}
