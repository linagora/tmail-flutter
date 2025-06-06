import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/email/presentation/utils/email_utils.dart';
import 'package:tmail_ui_user/features/home/data/exceptions/session_exceptions.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/state/get_emails_by_ids_state.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/utils/thread_detail_presentation_utils.dart';

extension InitializeThreadDetailEmails on ThreadDetailController {
  void initializeThreadDetailEmails() {
    final emailIdsToLoadMetaData = ThreadDetailPresentationUtils.getFirstLoadEmailIds(
      emailIdsPresentation.keys.toList(),
      selectedEmailId: mailboxDashBoardController.selectedEmail.value?.id,
    );

    if (accountId == null || session == null) {
      consumeState(Stream.value(Left(GetEmailsByIdsFailure(
        exception: NotFoundSessionException(),
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
    ));
  }
}