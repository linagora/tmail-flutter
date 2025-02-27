
import 'package:model/mailbox/select_mode.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/thread/presentation/extensions/list_presentation_email_extensions.dart';

extension HandleSelectionEmailExtension on MailboxDashBoardController {

  void cancelAllSelectionEmailMode() {
    isSelectAllEmailsEnabled.value = false;
    isSelectAllPageEnabled.value = false;
    currentSelectMode.value = SelectMode.INACTIVE;
    listEmailSelected.clear();

    final newEmailList = emailsInCurrentMailbox.cancelSelectionMode();
    updateEmailList(newEmailList);
  }
}