import 'package:core/utils/platform_info.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/presentation_email_extension.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/action/email_ui_action.dart';
import 'package:tmail_ui_user/features/thread/presentation/extensions/list_presentation_email_extensions.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/state/get_emails_by_ids_state.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/state/get_thread_by_id_state.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/action/thread_detail_ui_action.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/close_thread_detail_action.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/handle_mail_shortcut_actions_extension.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';

extension ThreadDetailOnSelectedEmailUpdated on ThreadDetailController {
  void onSelectedEmailUpdated(
    PresentationEmail? selectedEmail,
    BuildContext? context,
  ) {
    final selectedPresentationEmail = selectedEmail;
    final selectedPresentationEmailId = selectedPresentationEmail?.id;
    final selectedPresentationEmailThreadId = selectedPresentationEmail?.threadId;

    if (selectedPresentationEmailId == null && mailboxDashBoardController.isEmailOpened) {
      closeThreadDetailAction();
      return;
    }

    emailIdsPresentation.clear();
    onKeyboardShortcutInit();
    scrollController ??= ScrollController();

    if (currentExpandedEmailId.value == null && selectedPresentationEmail != null) {
      loadThreadOnThreadChanged = isThreadDetailEnabled;
      _preloadSelectedEmail(selectedPresentationEmail);
      return;
    }

    // Thread setting updated, no need to dispose current single email controller
    if (currentExpandedEmailId.value == selectedPresentationEmailId && selectedPresentationEmail != null) {
      _preloadSelectedEmail(selectedPresentationEmail);

      if (isThreadDetailEnabled && selectedPresentationEmailThreadId != null) {
        final mailboxContain = selectedPresentationEmail.findMailboxContain(
          mailboxDashBoardController.mapMailboxById,
        );
        mailboxDashBoardController.dispatchThreadDetailUIAction(
          LoadThreadDetailAfterSelectedEmailAction(
            selectedPresentationEmailThreadId,
            isSentMailbox: mailboxContain?.isSent == true,
          )
        );
      }
      return;
    }

    if (PlatformInfo.isWeb) {
      mailboxDashBoardController.dispatchEmailUIAction(
        DisposePreviousExpandedEmailAction(
          currentExpandedEmailId.value!,
        ),
      );
    }

    loadThreadOnThreadChanged = isThreadDetailEnabled;

    if (selectedPresentationEmail != null) {
      _preloadSelectedEmail(selectedPresentationEmail);
    }
  }

  void _preloadSelectedEmail(PresentationEmail selectedEmail) {
    consumeState(Stream.fromIterable([
      Right(PreloadEmailIdsInThreadSuccess(
        [selectedEmail.id!],
        threadId: selectedEmail.threadId,
        emailsInThreadDetailInfo: [selectedEmail].toEmailsInThreadDetailInfo(
          sentMailboxId: sentMailboxId,
          ownEmailAddress: ownEmailAddress,
        ),
      )),
      Right(PreloadEmailsByIdsSuccess([selectedEmail])),
    ]));
  }

  void resyncThreadDetailWhenSettingChanged() {
    final selectedEmail = mailboxDashBoardController.selectedEmail.value;
    if (selectedEmail == null) return;

    emailIdsPresentation.clear();
    scrollController ??= ScrollController();

    mailboxDashBoardController.dispatchEmailUIAction(
      DisposePreviousExpandedEmailAction(selectedEmail.id!),
    );

    loadThreadOnThreadChanged = isThreadDetailEnabled;
    _preloadSelectedEmail(selectedEmail);
  }
}