
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/clear_mailbox_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

extension HandleClearMailboxExtension on MailboxDashBoardController {

  void clearMailbox(Session session, AccountId accountId, MailboxId mailboxId) {
    consumeState(clearMailboxInteractor.execute(
      session,
      accountId,
      mailboxId,
    ));
  }

  void clearMailboxSuccess(ClearMailboxSuccess success) {
    viewStateMailboxActionProgress.value = Right(UIState.idle);

    if (currentOverlayContext != null && currentContext != null) {
      appToast.showToastSuccessMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).toast_message_empty_trash_folder_success,
      );
    }

    if (selectedMailbox.value?.id == success.mailboxId) {
      emailsInCurrentMailbox.clear();
    }
  }
}