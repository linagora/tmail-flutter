
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/model.dart';
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

      if (PlatformInfo.isMobile) {
        yield* _getStoredOpenedEmail(session, accountId, emailId, baseDownloadUrl, composeEmail: composeEmail, draftsEmail: draftsEmail);
      } else {
        yield* _getContentEmailFromServer(session, accountId, emailId, baseDownloadUrl, composeEmail: composeEmail, draftsEmail: draftsEmail);
      }
    } catch (e) {
      log('GetEmailContentInteractor::execute(): exception = $e');
      yield Left<Failure, Success>(GetEmailContentFailure(e));
    }
  }

  Stream<Either<Failure, Success>> _getContentEmailFromServer(
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
      final email = await emailRepository.getEmailContent(session, accountId, emailId);

      if (email.emailContentList.isNotEmpty) {
        final newEmailContents = await emailRepository.transformEmailContent(
          email.emailContentList,
          email.allAttachments.listAttachmentsDisplayedInContent,
          baseDownloadUrl,
          accountId,
          draftsEmail: draftsEmail
        );

        final newEmailContentsDisplayed = PlatformInfo.isWeb && !composeEmail
          ? await emailRepository.addTooltipWhenHoverOnLink(newEmailContents)
          : newEmailContents;

        yield Right<Failure, Success>(GetEmailContentSuccess(
          emailContent: newEmailContents.asHtmlString,
          emailContentDisplayed: newEmailContentsDisplayed.asHtmlString,
          attachments: email.allAttachments,
          emailCurrent: email
        ));
      } else {
        yield Right<Failure, Success>(GetEmailContentSuccess(
          emailContent: '',
          emailContentDisplayed: '',
          attachments: email.allAttachments,
          emailCurrent: email
        ));
      }
    } catch (e) {
      logError('GetEmailContentInteractor::_getContentEmailFromServer():EXCEPTION: $e');
      yield Left<Failure, Success>(GetEmailContentFailure(e));
    }
  }

  Stream<Either<Failure, Success>> _getStoredOpenedEmail(
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
      log('GetEmailContentInteractor::_getStoredOpenedEmail(): CALLED');
      final detailedEmail = await emailRepository.getStoredOpenedEmail(session, accountId, emailId);
      yield Right<Failure, Success>(GetEmailContentFromCacheSuccess(
        emailContent: detailedEmail.htmlEmailContent ?? "",
        attachments: detailedEmail.attachments ?? [],
        emailCurrent: Email(
          id: emailId,
          headers: detailedEmail.headers,
          keywords: detailedEmail.keywords
        )
      ));
    } catch (e) {
      logError('GetEmailContentInteractor::_getStoredOpenedEmail():EXCEPTION: $e');
      yield* _getStoredNewEmail(
        session,
        accountId,
        emailId,
        baseDownloadUrl,
        composeEmail: composeEmail,
        draftsEmail: draftsEmail);
    }
  }

  Stream<Either<Failure, Success>> _getStoredNewEmail(
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
      log('GetEmailContentInteractor::_getStoredNewEmail():CALLED');
      final detailedEmail = await emailRepository.getStoredNewEmail(session, accountId, emailId);
      yield Right<Failure, Success>(GetEmailContentFromCacheSuccess(
        emailContent: detailedEmail.htmlEmailContent ?? "",
        attachments: detailedEmail.attachments ?? [],
        emailCurrent: Email(
          id: emailId,
          headers: detailedEmail.headers,
          keywords: detailedEmail.keywords
        )
      ));
    } catch (e) {
      logError('GetEmailContentInteractor::_getStoredNewEmail():EXCEPTION: $e');
      yield* _getContentEmailFromServer(
        session,
        accountId,
        emailId,
        baseDownloadUrl,
        composeEmail: composeEmail,
        draftsEmail: draftsEmail);
    }
  }
}