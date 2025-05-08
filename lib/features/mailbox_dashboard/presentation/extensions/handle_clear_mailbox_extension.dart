
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/clear_mailbox_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';

extension HandleClearMailboxExtension on MailboxDashBoardController {

  void clearMailbox(
    Session session,
    AccountId accountId,
    MailboxId mailboxId,
    Role mailboxRole,
  ) {
    viewStateMailboxActionProgress.value = Right(ClearingMailbox());

    consumeState(clearMailboxInteractor.execute(
      session,
      accountId,
      mailboxId,
      mailboxRole,
    ));
  }

  void clearMailboxSuccess(ClearMailboxSuccess success) {
    viewStateMailboxActionProgress.value = Right(UIState.idle);

    toastManager.showMessageSuccess(success);

    if (selectedMailbox.value?.id == success.mailboxId) {
      emailsInCurrentMailbox.clear();
    }
  }

  void clearMailboxFailure(ClearMailboxFailure failure) {
    viewStateMailboxActionProgress.value = Right(UIState.idle);

    toastManager.showMessageFailure(failure);
  }
}