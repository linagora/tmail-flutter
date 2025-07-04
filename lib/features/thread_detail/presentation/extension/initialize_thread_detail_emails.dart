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
    if (success.skipLoadingMetadata) return;

    final selectedEmailId = mailboxDashBoardController.selectedEmail.value?.id;
    if (skipLoadThreadMetaData(
      selectedEmailId: selectedEmailId,
      updateCurrentThreadDetail: success.updateCurrentThreadDetail,
    )) return;

    List<EmailId> emailIdsToLoadMetaData = [];
    emailIdsToLoadMetaData = ThreadDetailPresentationUtils.getFirstLoadEmailIds(
      emailIdsPresentation.keys.toList(),
      selectedEmailId: selectedEmailId,
    );
    emailIdsToLoadMetaData.remove(selectedEmailId);

    if (accountId == null || session == null) {
      consumeState(Stream.value(Left(GetEmailsByIdsFailure(
        exception: NotFoundSessionException(),
        updateCurrentThreadDetail: false,
      ))));
      return;
    }
    if (_currentThreadOnlyContainsSelectedEmail(selectedEmailId)) return;

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

  bool _currentThreadOnlyContainsSelectedEmail(EmailId? selectedEmailId) {
    return selectedEmailId != null &&
        emailIdsPresentation.length == 1 &&
        emailIdsPresentation.keys.contains(selectedEmailId);
  }

  bool skipLoadThreadMetaData({
    EmailId? selectedEmailId,
    bool updateCurrentThreadDetail = false,
  }) {
    return selectedEmailId == null ||
        !isThreadDetailEnabled ||
        !networkConnected ||
        updateCurrentThreadDetail;
  }
}