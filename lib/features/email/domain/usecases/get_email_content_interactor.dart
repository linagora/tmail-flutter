
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/email/domain/model/detailed_email.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/state/get_email_content_state.dart';

class GetEmailContentInteractor {
  final EmailRepository emailRepository;

  GetEmailContentInteractor(this.emailRepository);

  Stream<Either<Failure, Success>> execute(
    Session session,
    AccountId accountId,
    EmailId emailId,
    String baseDownloadUrl,
    TransformConfiguration transformConfiguration,
    {Properties? additionalProperties}
  ) async* {
    try {
      yield Right<Failure, Success>(GetEmailContentLoading());

      if (PlatformInfo.isMobile) {
        yield* _getStoredOpenedEmail(
          session,
          accountId,
          emailId,
          baseDownloadUrl,
          transformConfiguration,
          additionalProperties: additionalProperties);
      } else {
        yield* _getContentEmailFromServer(
          session,
          accountId,
          emailId,
          baseDownloadUrl,
          transformConfiguration,
          additionalProperties: additionalProperties);
      }
    } catch (e) {
      log('GetEmailContentInteractor::execute(): exception = $e');
      yield Left<Failure, Success>(GetEmailContentFailure(
        e,
        onRetry: execute(
          session,
          accountId,
          emailId,
          baseDownloadUrl,
          transformConfiguration,
          additionalProperties: additionalProperties
        ),
      ));
    }
  }

  Stream<Either<Failure, Success>> _getContentEmailFromServer(
    Session session,
    AccountId accountId,
    EmailId emailId,
    String baseDownloadUrl,
    TransformConfiguration transformConfiguration,
    {Properties? additionalProperties}
  ) async* {
    try {
      final email = await emailRepository.getEmailContent(
        session,
        accountId,
        emailId,
        additionalProperties: additionalProperties);
      final listAttachments = email.allAttachments.getListAttachmentsDisplayedOutside(email.htmlBodyAttachments);
      final listInlineImages = email.allAttachments.listAttachmentsDisplayedInContent;
      log('GetEmailContentInteractor::_getContentEmailFromServer: listAttachments = ${listAttachments.length} | listInlineImages = ${listInlineImages.length}');
      if (email.emailContentList.isNotEmpty) {
        final mapCidImageDownloadUrl = listInlineImages.toMapCidImageDownloadUrl(
          accountId: accountId,
          downloadUrl: baseDownloadUrl
        );
        final newEmailContents = await emailRepository.transformEmailContent(
          email.emailContentList,
          mapCidImageDownloadUrl,
          transformConfiguration
        );

        yield Right<Failure, Success>(GetEmailContentSuccess(
          htmlEmailContent: newEmailContents.asHtmlString,
          attachments: listAttachments,
          inlineImages: listInlineImages,
          emailCurrent: email
        ));
      } else {
        yield Right<Failure, Success>(GetEmailContentSuccess(
          htmlEmailContent: '',
          attachments: listAttachments,
          inlineImages: listInlineImages,
          emailCurrent: email
        ));
      }
    } catch (e) {
      logError('GetEmailContentInteractor::_getContentEmailFromServer():EXCEPTION: $e');
      yield Left<Failure, Success>(GetEmailContentFailure(
        e,
        onRetry: execute(
          session,
          accountId,
          emailId,
          baseDownloadUrl,
          transformConfiguration,
          additionalProperties: additionalProperties
        ),
      ));
    }
  }

  Stream<Either<Failure, Success>> _getStoredOpenedEmail(
    Session session,
    AccountId accountId,
    EmailId emailId,
    String baseDownloadUrl,
    TransformConfiguration transformConfiguration,
    {Properties? additionalProperties}
  ) async* {
    try {
      final tupleEmail = await Future.wait([
        emailRepository.getStoredEmail(session, accountId, emailId),
        emailRepository.getStoredOpenedEmail(session, accountId, emailId),
      ], eagerError: true);
      final emailCache = tupleEmail[0] as Email;
      final detailedEmail = tupleEmail[1] as DetailedEmail;
      log('GetEmailContentInteractor::_getStoredOpenedEmail: attachments = ${detailedEmail.attachments?.length} | inlineImages = ${detailedEmail.inlineImages?.length}');
      yield Right<Failure, Success>(GetEmailContentFromCacheSuccess(
        htmlEmailContent: detailedEmail.htmlEmailContent ?? '',
        attachments: detailedEmail.attachments ?? [],
        inlineImages: detailedEmail.inlineImages ?? [],
        emailCurrent: emailCache.copyWith(
          headers: detailedEmail.headers,
          sMimeStatusHeader: detailedEmail.sMimeStatusHeader,
        )
      ));
    } catch (e) {
      logError('GetEmailContentInteractor::_getStoredOpenedEmail():EXCEPTION: $e');
      yield* _getStoredNewEmail(
        session,
        accountId,
        emailId,
        baseDownloadUrl,
        transformConfiguration,
        additionalProperties: additionalProperties
      );
    }
  }

  Stream<Either<Failure, Success>> _getStoredNewEmail(
    Session session,
    AccountId accountId,
    EmailId emailId,
    String baseDownloadUrl,
    TransformConfiguration transformConfiguration,
    {Properties? additionalProperties}
  ) async* {
    try {
      final tupleEmail = await Future.wait([
        emailRepository.getStoredEmail(session, accountId, emailId),
        emailRepository.getStoredNewEmail(session, accountId, emailId),
      ], eagerError: true);
      final emailCache = tupleEmail[0] as Email;
      final detailedEmail = tupleEmail[1] as DetailedEmail;
      log('GetEmailContentInteractor::_getStoredNewEmail: attachments = ${detailedEmail.attachments?.length} | inlineImages = ${detailedEmail.inlineImages?.length}');
      yield Right<Failure, Success>(GetEmailContentFromCacheSuccess(
        htmlEmailContent: detailedEmail.htmlEmailContent ?? '',
        attachments: detailedEmail.attachments ?? [],
        inlineImages: detailedEmail.inlineImages ?? [],
        emailCurrent: emailCache.copyWith(
          headers: detailedEmail.headers,
          sMimeStatusHeader: detailedEmail.sMimeStatusHeader,
        )
      ));
    } catch (e) {
      logError('GetEmailContentInteractor::_getStoredNewEmail():EXCEPTION: $e');
      yield* _getContentEmailFromServer(
        session,
        accountId,
        emailId,
        baseDownloadUrl,
        transformConfiguration,
        additionalProperties: additionalProperties
      );
    }
  }
}