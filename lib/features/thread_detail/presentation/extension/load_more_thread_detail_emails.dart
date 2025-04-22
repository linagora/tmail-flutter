import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/utils/thread_detail_presentation_utils.dart';

extension LoadMoreThreadDetailEmails on ThreadDetailController {
  void loadMoreThreadDetailEmails() {
    if (accountId == null || session == null) {
      // TODO: Handle error
      return;
    }

    final emailIdsToLoadMetaData = ThreadDetailPresentationUtils
      .getEmailIdsToLoad(emailIdsPresentation);
    consumeState(getEmailsByIdsInteractor.execute(
      session!,
      accountId!,
      emailIdsToLoadMetaData,
    ));
  }
}