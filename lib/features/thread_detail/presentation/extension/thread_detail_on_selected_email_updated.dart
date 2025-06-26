import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:model/email/presentation_email.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/state/get_emails_by_ids_state.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/state/get_thread_by_id_state.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/usecases/get_thread_by_id_interactor.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/close_thread_detail_action.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';

extension ThreadDetailOnSelectedEmailUpdated on ThreadDetailController {
  void onSelectedEmailUpdated(
    PresentationEmail? selectedEmail,
    GetThreadByIdInteractor getThreadByIdInteractor,
    BuildContext? context,
  ) {
    if (selectedEmail?.threadId == null || selectedEmail?.id == null) {
      closeThreadDetailAction(context);
      return;
    }

    consumeState(Stream.fromIterable([
      Right(PreloadEmailIdsInThreadSuccess([selectedEmail!.id!])),
      Right(PreloadEmailsByIdsSuccess([selectedEmail])),
    ]));
    if (!isThreadDetailEnabled) return;

    if (session != null &&
        accountId != null &&
        sentMailboxId != null &&
        ownEmailAddress != null) {
      scrollController = ScrollController();
      consumeState(getThreadByIdInteractor.execute(
        selectedEmail.threadId!,
        session!,
        accountId!,
        sentMailboxId!,
        ownEmailAddress!,
        selectedEmailId: selectedEmail.id,
      ));
    }
  }
}