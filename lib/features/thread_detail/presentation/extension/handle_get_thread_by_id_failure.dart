import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/state/get_emails_by_ids_state.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/state/get_thread_by_id_state.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';

extension HandleGetThreadByIdFailure on ThreadDetailController {
  void handleGetThreadByIdFailure(GetThreadByIdFailure failure) {
    if (failure.updateCurrentThreadDetail) return;

    final selectedEmail = mailboxDashBoardController.selectedEmail.value;
    if (selectedEmail != null) {
      consumeState(Stream.value(Right(GetEmailsByIdsSuccess([selectedEmail]))));
    } else {
      showRetryToast(failure);
    }
  }
}