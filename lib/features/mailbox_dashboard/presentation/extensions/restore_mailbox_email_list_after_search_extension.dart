import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/action/dashboard_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';

extension RestoreMailboxEmailListAfterSearchExtension
    on MailboxDashBoardController {
  bool shouldRestoreMailboxEmailListAfterSearch(
    PresentationMailbox presentationMailbox,
  ) {
    final selectedMailboxId = selectedMailbox.value?.id;
    return presentationMailbox.id == selectedMailboxId &&
        searchController.isSearchEmailRunning;
  }

  void restoreMailboxEmailListAfterSearch() {
    dispatchAction(
      RestoreMailboxEmailListAfterSearchAction(force: true),
    );
  }
}
