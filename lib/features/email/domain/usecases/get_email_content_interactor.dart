import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/state/get_email_content_state.dart';

class GetEmailContentInteractor {
  final EmailRepository emailRepository;

  GetEmailContentInteractor(this.emailRepository);

  Stream<Either<Failure, Success>> execute(AccountId accountId, EmailId emailId, String? baseDownloadUrl) async* {
    try {
      yield Right<Failure, Success>(GetEmailContentLoading());
      final email = await emailRepository.getEmailContent(accountId, emailId);

      if (email.emailContentList.isNotEmpty) {
        final newEmailContents = await emailRepository.transformEmailContent(
            email.emailContentList,
            email.allAttachments.listAttachmentsDisplayedInContent,
            baseDownloadUrl,
            accountId);
        final newEmailContentsDisplayed = kIsWeb
            ? await emailRepository.addTooltipWhenHoverOnLink(newEmailContents)
            : newEmailContents;
        yield Right<Failure, Success>(GetEmailContentSuccess(
            newEmailContents,
            newEmailContentsDisplayed,
            email.allAttachments,
            email.needShowNotificationMessageReadReceipt));
      } else if (email.allAttachments.isNotEmpty) {
        yield Right<Failure, Success>(GetEmailContentSuccess(
            [],
            [],
            email.allAttachments,
            email.needShowNotificationMessageReadReceipt));
      } else if (email.headers?.isNotEmpty == true) {
        yield Right<Failure, Success>(GetEmailContentSuccess(
            [], 
            [],
            [],
            email.needShowNotificationMessageReadReceipt));
      } else {
        yield Left(GetEmailContentFailure(null));
      }
    } catch (e) {
      log('GetEmailContentInteractor::execute(): exception = $e');
      yield Left(GetEmailContentFailure(e));
    }
  }
}