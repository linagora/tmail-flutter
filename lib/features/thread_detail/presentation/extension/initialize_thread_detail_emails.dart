import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/features/email/presentation/utils/email_utils.dart';
import 'package:tmail_ui_user/features/home/data/exceptions/session_exceptions.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/state/get_emails_by_ids_state.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/state/get_thread_by_id_state.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/utils/thread_detail_presentation_utils.dart';

extension InitializeThreadDetailEmails on ThreadDetailController {
  void initializeThreadDetailEmails(GetThreadByIdSuccess success) {
    final threadDetailEnabled = isThreadDetailEnabled;
    final selectedEmail = mailboxDashBoardController.selectedEmail.value;
    if (!threadDetailEnabled &&
        selectedEmail != null &&
        !success.updateCurrentThreadDetail) {
      consumeState(Stream.value(Right(GetEmailsByIdsSuccess([selectedEmail]))));
      return;
    }

    final existingEmailIds = emailIdsPresentation.keys.toList();
    final selectedEmailId = mailboxDashBoardController.selectedEmail.value?.id;

    List<EmailId> emailIdsToLoadMetaData = [];
    if (success.updateCurrentThreadDetail) {
      final nonNullEmailIds = emailIdsPresentation.entries
        .where((entry) => entry.value != null)
        .map((entry) => entry.key)
        .toList();
      final newEmailIds = success.emailIds.where(
        (emailId) => !existingEmailIds.contains(emailId),
      );
      emailIdsToLoadMetaData = [...nonNullEmailIds, ...newEmailIds];
    } else {
      emailIdsToLoadMetaData = ThreadDetailPresentationUtils.getFirstLoadEmailIds(
        existingEmailIds,
        selectedEmailId: selectedEmailId,
      );
    }

    if (accountId == null || session == null) {
      consumeState(Stream.value(Left(GetEmailsByIdsFailure(
        exception: NotFoundSessionException(),
        updateCurrentThreadDetail: false,
      ))));
      return;
    }
    consumeState(getEmailsByIdsInteractor.execute(
      session!,
      accountId!,
      emailIdsToLoadMetaData,
      properties: EmailUtils.getPropertiesForEmailGetMethod(
        session!,
        accountId!,
      ).union(additionalProperties),
      updateCurrentThreadDetail: success.updateCurrentThreadDetail,
    ));
  }
}