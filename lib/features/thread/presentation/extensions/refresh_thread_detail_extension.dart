import 'package:tmail_ui_user/features/email/presentation/action/email_ui_action.dart';
import 'package:tmail_ui_user/features/thread/data/model/email_change_response.dart';
import 'package:tmail_ui_user/features/thread/presentation/thread_controller.dart';

extension RefreshThreadDetailExtension on ThreadController {
  void refreshThreadDetail(EmailChangeResponse? emailChangeResponse) {
    if (emailChangeResponse == null) return;

    mailboxDashBoardController
      .dispatchEmailUIAction(RefreshThreadDetailAction(emailChangeResponse));
  }
}