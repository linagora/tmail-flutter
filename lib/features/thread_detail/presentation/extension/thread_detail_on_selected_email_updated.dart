import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:model/email/presentation_email.dart';
import 'package:tmail_ui_user/features/email/presentation/action/email_ui_action.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/state/get_emails_by_ids_state.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/state/get_thread_by_id_state.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/usecases/get_thread_by_id_interactor.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/action/thread_detail_ui_action.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/close_thread_detail_action.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';

extension ThreadDetailOnSelectedEmailUpdated on ThreadDetailController {
  void onSelectedEmailUpdated(
    PresentationEmail? selectedEmail,
    GetThreadByIdInteractor getThreadByIdInteractor,
    BuildContext? context,
  ) {
    if (selectedEmail?.id == null) {
      closeThreadDetailAction(context);
      return;
    }

    scrollController = ScrollController();

    if (currentExpandedEmailId.value == null) {
      loadThreadOnThreadChanged = isThreadDetailEnabled;
      _preloadSelectedEmail(selectedEmail!);
      return;
    }

    // Thread setting updated, no need to dispose current single email controller
    if (currentExpandedEmailId.value == selectedEmail!.id) {
      _preloadSelectedEmail(selectedEmail);

      if (isThreadDetailEnabled && selectedEmail.threadId != null) {
        mailboxDashBoardController.dispatchThreadDetailUIAction(
          LoadThreadDetailAfterSelectedEmailAction(
            selectedEmail.threadId!,
          )
        );
      }
      return;
    }

    mailboxDashBoardController.dispatchEmailUIAction(
      DisposePreviousExpandedEmailAction(
        currentExpandedEmailId.value!,
      ),
    );
    loadThreadOnThreadChanged = isThreadDetailEnabled;
    _preloadSelectedEmail(selectedEmail);
  }

  void _preloadSelectedEmail(PresentationEmail selectedEmail) {
    consumeState(Stream.fromIterable([
      Right(PreloadEmailIdsInThreadSuccess([selectedEmail.id!])),
      Right(PreloadEmailsByIdsSuccess([selectedEmail])),
    ]));
  }
}