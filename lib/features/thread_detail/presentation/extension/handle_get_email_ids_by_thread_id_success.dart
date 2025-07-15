import 'package:tmail_ui_user/features/thread_detail/domain/state/get_thread_by_id_state.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';

extension HandleGetEmailIdsByThreadIdSuccess on ThreadDetailController {
  void handleGetEmailIdsByThreadIdSuccess(
    GetThreadByIdSuccess success,
  ) {
    final currentThreadId = mailboxDashBoardController.selectedEmail.value?.threadId;
    if (success.emailIds.isEmpty || success.threadId != currentThreadId) {
      return;
    }

    final allEmailIds = success.emailIds;
    if (success.updateCurrentThreadDetail) {
      final newEmailIds = allEmailIds.where(
        (emailId) => !emailIdsPresentation.keys.contains(emailId),
      );
      emailIdsPresentation
        ..removeWhere((key, _) => !allEmailIds.contains(key))
        ..addEntries(
          newEmailIds.map((emailId) => MapEntry(emailId, null)),
        );
      return;
    }

    final selectedEmail = mailboxDashBoardController.selectedEmail.value;
    final selectedEmailId = selectedEmail?.id;
    emailIdsPresentation.value = {
      for (final id in allEmailIds)
        id: id == selectedEmailId
            ? emailIdsPresentation[id] ?? selectedEmail
            : null,
    };
  }
}