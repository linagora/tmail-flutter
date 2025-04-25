import 'package:tmail_ui_user/features/thread_detail/domain/model/email_in_thread_status.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/utils/thread_detail_presentation_utils.dart';

extension InitializeThreadDetailEmails on ThreadDetailController {
  void initializeThreadDetailEmails() {
    emailIdsPresentation.value = Map.fromEntries(
      emailIds.map((id) => MapEntry(id, null))
    );
    emailIdsStatus.value = Map.fromEntries(
      emailIds.map((id) => MapEntry(id, EmailInThreadStatus.hidden))
    );
    final emailIdToLoadContent = emailIds.last;
    final emailIdsToLoadMetaData = ThreadDetailPresentationUtils.getEmailIdsToLoad(
      Map.from(emailIdsPresentation)..remove(emailIdToLoadContent),
    );

    if (accountId == null || session == null) {
      // TODO: Handle error
      return;
    }
    consumeState(getEmailsByIdsInteractor.execute(
      session!,
      accountId!,
      [...emailIdsToLoadMetaData, emailIdToLoadContent],
    ));
  }
}