import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/build_utils.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/extensions/email_extension.dart';
import 'package:model/extensions/list_attachment_extension.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/state/get_email_content_state.dart';

class GetEmailContentInteractor {
  final EmailRepository emailRepository;

  GetEmailContentInteractor(this.emailRepository);

  Stream<Either<Failure, Success>> execute(
    Session session,
    AccountId accountId,
    EmailId emailId,
    String? baseDownloadUrl,
    {
      bool composeEmail = false,
      bool draftsEmail = false
    }
  ) async* {
    try {
      yield Right<Failure, Success>(GetEmailContentLoading());
      final email = await emailRepository.getEmailContent(session, accountId, emailId);

      if (email.emailContentList.isNotEmpty) {
        final newEmailContents = await emailRepository.transformEmailContent(
          email.emailContentList,
          email.allAttachments.listAttachmentsDisplayedInContent,
          baseDownloadUrl,
          accountId,
          draftsEmail: draftsEmail
        );

        final newEmailContentsDisplayed = BuildUtils.isWeb && !composeEmail
          ? await emailRepository.addTooltipWhenHoverOnLink(newEmailContents)
          : newEmailContents;

        yield Right<Failure, Success>(GetEmailContentSuccess(
          newEmailContents,
          newEmailContentsDisplayed,
          email.allAttachments,
          email
        ));
      } else if (email.allAttachments.isNotEmpty) {
        yield Right<Failure, Success>(GetEmailContentSuccess([], [], email.allAttachments, email));
      } else if (email.headers?.isNotEmpty == true) {
        yield Right<Failure, Success>(GetEmailContentSuccess([], [], [], email));
      } else {
        yield Left(GetEmailContentFailure(null));
      }
    } catch (e) {
      log('GetEmailContentInteractor::execute(): exception = $e');
      yield Left(GetEmailContentFailure(e));
    }
  }
}