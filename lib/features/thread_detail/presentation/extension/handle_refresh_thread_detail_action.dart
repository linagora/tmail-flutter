import 'package:dartz/dartz.dart';
import 'package:model/extensions/list_email_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/action/email_ui_action.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/state/get_thread_by_id_state.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/usecases/get_thread_by_id_interactor.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';

extension HandleRefreshThreadDetailAction on ThreadDetailController {
  void handleRefreshThreadDetailAction(
    RefreshThreadDetailAction action,
    GetThreadByIdInteractor getThreadByIdInteractor,
  ) {
    if (!isThreadDetailEnabled) {
      final currentEmailId = mailboxDashBoardController.selectedEmail.value?.id;
      if (currentEmailId == null) return;

      final updatedEmailIds = action
        .emailChangeResponse
        .updated
        ?.listEmailIds ?? [];

      if (updatedEmailIds.contains(currentEmailId)) {
        consumeState(Stream.value(Right(GetThreadByIdSuccess(
          [currentEmailId],
          updateCurrentThreadDetail: true,
        ))));
      }

      return;
    }

    final currentThreadId = mailboxDashBoardController.selectedEmail.value?.threadId;
    final threadIdsEmailCreated = action
      .emailChangeResponse
      .created
      ?.listThreadIds ?? [];
    final threadIdsEmailUpdated = action
      .emailChangeResponse
      .updated
      ?.listThreadIds ?? [];
    final updatedThreadIds = threadIdsEmailCreated + threadIdsEmailUpdated;
    final destroyedEmailIds = action.emailChangeResponse.destroyed ?? [];

    if (session != null &&
        accountId != null &&
        sentMailboxId != null &&
        ownEmailAddress != null &&
        currentThreadId != null && (
          updatedThreadIds.contains(currentThreadId) ||
          emailIdsPresentation.keys.any(destroyedEmailIds.contains))) {
      consumeState(getThreadByIdInteractor.execute(
        currentThreadId,
        session!,
        accountId!,
        sentMailboxId!,
        ownEmailAddress!,
        updateCurrentThreadDetail: true,
        selectedEmailId: mailboxDashBoardController.selectedEmail.value?.id,
      ));
    }
  }
}