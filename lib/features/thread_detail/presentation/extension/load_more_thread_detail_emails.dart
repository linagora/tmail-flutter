import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/email/presentation/utils/email_utils.dart';
import 'package:tmail_ui_user/features/home/data/exceptions/session_exceptions.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/state/get_email_ids_by_thread_id_state.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/utils/thread_detail_presentation_utils.dart';

extension LoadMoreThreadDetailEmails on ThreadDetailController {
  void loadMoreThreadDetailEmails() {
    if (accountId == null || session == null) {
      consumeState(Stream.value(Left(GetEmailIdsByThreadIdFailure(
        exception: NotFoundSessionException(),
      ))));
      return;
    }

    final emailIdsToLoadMetaData = ThreadDetailPresentationUtils
      .getEmailIdsToLoad(emailIdsPresentation);
    consumeState(getEmailsByIdsInteractor.execute(
      session!,
      accountId!,
      emailIdsToLoadMetaData,
      properties: EmailUtils.getPropertiesForEmailGetMethod(
        session!,
        accountId!,
      ),
    ));
  }
}