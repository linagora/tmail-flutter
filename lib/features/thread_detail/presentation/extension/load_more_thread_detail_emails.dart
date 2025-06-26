import 'dart:math';

import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/email/presentation/utils/email_utils.dart';
import 'package:tmail_ui_user/features/home/data/exceptions/session_exceptions.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/state/get_emails_by_ids_state.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/utils/thread_detail_presentation_utils.dart';

extension LoadMoreThreadDetailEmails on ThreadDetailController {
  void loadMoreThreadDetailEmails({
    required int loadMoreIndex,
    required int loadMoreCount,
  }) {
    if (accountId == null || session == null) {
      consumeState(Stream.value(Left(GetEmailsByIdsFailure(
        exception: NotFoundSessionException(),
        updateCurrentThreadDetail: false,
      ))));
      return;
    }

    final currentExpandedEmailIndex = currentExpandedEmailId.value == null
      ? -1
      : emailIdsPresentation.keys.toList().indexOf(currentExpandedEmailId.value!);
    final loadMoreEmailIds = emailIdsPresentation.keys.toList().sublist(
      loadMoreIndex,
      min(
        loadMoreIndex + loadMoreCount,
        emailIdsPresentation.length,
      ),
    );

    final emailIdsToLoadMetaData = ThreadDetailPresentationUtils.getLoadMoreEmailIds(
      loadMoreEmailIds,
      loadEmailsAfterSelectedEmail: loadMoreIndex > currentExpandedEmailIndex,
    );
    if (emailIdsToLoadMetaData.isEmpty) {
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
      loadMoreIndex: loadMoreIndex,
    ));
  }
}