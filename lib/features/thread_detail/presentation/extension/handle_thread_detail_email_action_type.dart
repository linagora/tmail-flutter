import 'package:model/email/email_action_type.dart';
import 'package:model/email/presentation_email.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';

extension HandleThreadDetailEmailActionType on ThreadDetailController {
  void handleThreadDetailEmailActionType(
    EmailActionType actionType,
    PresentationEmail selectedEmail,
  ) {
    switch(actionType) {
      case EmailActionType.preview:
        break;
      case EmailActionType.markAsStarred:
        // markAsStarEmail(selectedEmail, MarkStarAction.markStar);
        break;
      case EmailActionType.unMarkAsStarred:
        // markAsStarEmail(selectedEmail, MarkStarAction.unMarkStar);
        break;
      default:
        break;
    }
  }
}