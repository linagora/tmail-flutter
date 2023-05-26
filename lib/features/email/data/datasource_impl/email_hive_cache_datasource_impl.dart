
import 'dart:async';

import 'dart:typed_data';

import 'package:core/data/network/download/downloaded_response.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/file_utils.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/account/account_request.dart';
import 'package:model/download/download_task_id.dart';
import 'package:model/email/attachment.dart';
import 'package:model/email/mark_star_action.dart';
import 'package:model/email/read_actions.dart';
import 'package:model/extensions/email_id_extensions.dart';
import 'package:tmail_ui_user/features/caching/utils/caching_constants.dart';
import 'package:tmail_ui_user/features/composer/domain/extensions/sending_email_extension.dart';
import 'package:tmail_ui_user/features/composer/domain/model/email_request.dart';
import 'package:tmail_ui_user/features/composer/domain/model/sending_email.dart';
import 'package:tmail_ui_user/features/email/data/datasource/email_datasource.dart';
import 'package:tmail_ui_user/features/email/domain/extensions/detailed_email_extension.dart';
import 'package:tmail_ui_user/features/email/domain/extensions/detailed_email_hive_cache_extension.dart';
import 'package:tmail_ui_user/features/email/domain/model/detailed_email.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_to_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/create_new_mailbox_request.dart';
import 'package:tmail_ui_user/features/offline_mode/hive_worker/hive_task.dart';
import 'package:tmail_ui_user/features/offline_mode/manager/detailed_email_cache_manager.dart';
import 'package:tmail_ui_user/features/offline_mode/manager/detailed_email_cache_worker_queue.dart';
import 'package:tmail_ui_user/features/offline_mode/manager/opened_email_cache_manager.dart';
import 'package:tmail_ui_user/features/offline_mode/manager/opened_email_cache_worker_queue.dart';
import 'package:tmail_ui_user/features/thread/data/extensions/email_cache_extension.dart';
import 'package:tmail_ui_user/features/offline_mode/manager/sending_email_cache_manager.dart';
import 'package:tmail_ui_user/features/thread/data/extensions/email_extension.dart';
import 'package:tmail_ui_user/features/thread/data/local/email_cache_manager.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';

class EmailHiveCacheDataSourceImpl extends EmailDataSource {

  final DetailedEmailCacheManager _detailedEmailCacheManager;
  final OpenedEmailCacheManager _openedEmailCacheManager;
  final DetailedEmailCacheWorkerQueue _cacheWorkerQueue;
  final OpenedEmailCacheWorkerQueue _openedEmailCacheWorkerQueue;
  final EmailCacheManager _emailCacheManager;
  final SendingEmailCacheManager _sendingEmailCacheManager;
  final FileUtils _fileUtils;
  final ExceptionThrower _exceptionThrower;

  EmailHiveCacheDataSourceImpl(
    this._detailedEmailCacheManager,
    this._openedEmailCacheManager,
    this._cacheWorkerQueue,
    this._openedEmailCacheWorkerQueue,
    this._emailCacheManager,
    this._sendingEmailCacheManager,
    this._fileUtils,
    this._exceptionThrower
  );

  @override
  Future<bool> deleteEmailPermanently(Session session, AccountId accountId, EmailId emailId) {
    throw UnimplementedError();
  }

  @override
  Future<List<EmailId>> deleteMultipleEmailsPermanently(Session session, AccountId accountId, List<EmailId> emailIds) {
    throw UnimplementedError();
  }

  @override
  Future<Uint8List> downloadAttachmentForWeb(DownloadTaskId taskId, Attachment attachment, AccountId accountId, String baseDownloadUrl, AccountRequest accountRequest, StreamController<Either<Failure, Success>> onReceiveController) {
    throw UnimplementedError();
  }

  @override
  Future<List<DownloadTaskId>> downloadAttachments(List<Attachment> attachments, AccountId accountId, String baseDownloadUrl, AccountRequest accountRequest) {
    throw UnimplementedError();
  }

  @override
  Future<DownloadedResponse> exportAttachment(Attachment attachment, AccountId accountId, String baseDownloadUrl, AccountRequest accountRequest, CancelToken cancelToken) {
    throw UnimplementedError();
  }

  @override
  Future<Email> getEmailContent(Session session, AccountId accountId, EmailId emailId) {
    throw UnimplementedError();
  }

  @override
  Future<List<Email>> markAsRead(Session session, AccountId accountId, List<Email> emails, ReadActions readActions) {
    throw UnimplementedError();
  }

  @override
  Future<List<Email>> markAsStar(Session session, AccountId accountId, List<Email> emails, MarkStarAction markStarAction) {
    throw UnimplementedError();
  }

  @override
  Future<List<EmailId>> moveToMailbox(Session session, AccountId accountId, MoveToMailboxRequest moveRequest) {
    throw UnimplementedError();
  }

  @override
  Future<bool> removeEmailDrafts(Session session, AccountId accountId, EmailId emailId) {
    throw UnimplementedError();
  }

  @override
  Future<Email> saveEmailAsDrafts(Session session, AccountId accountId, Email email) {
    throw UnimplementedError();
  }

  @override
  Future<bool> sendEmail(Session session, AccountId accountId, EmailRequest emailRequest, {CreateNewMailboxRequest? mailboxRequest}) {
    throw UnimplementedError();
  }

  @override
  Future<void> storeDetailedEmail(Session session, AccountId accountId, DetailedEmail detailedEmail) {
    return Future.sync(() async {
      final task = HiveTask(
        runnable: () async {
          final fileSaved = await _fileUtils.saveToFile(
            nameFile: detailedEmail.emailId.asString,
            content: detailedEmail.htmlEmailContent ?? '',
            folderPath: detailedEmail.newEmailFolderPath
          );
          log('EmailHiveCacheDataSourceImpl::storeDetailedEmailToCache():fileSavedPath: ${fileSaved.path}');
          final detailedEmailSaved = detailedEmail.fromEmailContentPath(fileSaved.path);

          final detailedEmailCache = await _detailedEmailCacheManager.handleStoreDetailedEmail(
            accountId,
            session.username,
            detailedEmailSaved.toHiveCache());

          return detailedEmailCache;
        });
      return await _cacheWorkerQueue.addTask(task);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<Email> updateEmailDrafts(Session session, AccountId accountId, Email newEmail) {
    throw UnimplementedError();
  }

  @override
  Future<Email> getDetailedEmailById(Session session, AccountId accountId, EmailId emailId) {
    throw UnimplementedError();
  }

  @override
  Future<void> storeEmail(Session session, AccountId accountId, Email email) {
    return Future.sync(() async {
      return await _emailCacheManager.storeEmail(accountId, session.username, email.toEmailCache());
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<void> storeOpenedEmail(Session session, AccountId accountId, DetailedEmail detailedEmail) {
    return Future.sync(() async {
      final task = HiveTask(
          runnable: () async {

            final detailedEmailExisted = await _openedEmailCacheManager.isOpenedDetailEmailCached(accountId, session.username, detailedEmail.emailId);
            log('EmailHiveCacheDataSourceImpl::storeOpenedEmail():detailedEmailExisted: $detailedEmailExisted');

            if (detailedEmailExisted) {
              return Future.value();
            }

            final fileSaved = await _fileUtils.saveToFile(
              nameFile: detailedEmail.emailId.asString,
              content: detailedEmail.htmlEmailContent ?? '',
              folderPath: detailedEmail.openedEmailFolderPath
            );

            log('EmailHiveCacheDataSourceImpl::storeOpenedEmail():fileSavedPath: ${fileSaved.path}');

            final detailedEmailSaved = detailedEmail.fromEmailContentPath(fileSaved.path);

            await _openedEmailCacheManager.storeOpenedEmail(
              accountId,
              session.username,
              detailedEmailSaved);
          });
      return _openedEmailCacheWorkerQueue.addTask(task);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<DetailedEmail?> getOpenedEmail(Session session, AccountId accountId, EmailId emailId) {
    return Future.sync(() async {
      final openedEmailHiveCache = await _openedEmailCacheManager.getOpenedEmailExistedInCache(accountId, session.username, emailId);

      if (openedEmailHiveCache == null) {
        return null;
      }

      log('EmailHiveCacheDataSourceImpl::getOpenedEmail():folderPath: ${openedEmailHiveCache.emailContentPath}');

      final emailContent = await _fileUtils.getContentFromFile(
        nameFile: emailId.asString,
        folderPath: CachingConstants.openedEmailContentFolderName
      );

      return openedEmailHiveCache.toDetailedEmailWithContent(emailContent);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<DetailedEmail?> getIncomingEmailedStored(Session session, AccountId accountId, EmailId emailId) {
    return Future.sync(() async {
      final detailedEmailHiveCache = await _detailedEmailCacheManager.getDetailEmailExistedInCache(accountId, session.username, emailId);

      if (detailedEmailHiveCache == null) {
        return null;
      }

      log('EmailHiveCacheDataSourceImpl::getDetailedEmail():folderPath: ${detailedEmailHiveCache.emailContentPath}');

      final emailContent = await _fileUtils.getContentFromFile(
        nameFile: emailId.asString,
        folderPath: CachingConstants.incomingEmailedContentFolderName
      );

      return detailedEmailHiveCache.toDetailedEmailWithContent(emailContent);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<Email?> getEmailStored(Session session, AccountId accountId, EmailId emailId) {
    return Future.sync(() async {
      final email = await _emailCacheManager.getEmailFromCache(accountId, session.username, emailId);
      log('EmailHiveCacheDataSourceImpl::getEmailFromCache():emailId: $email');
      return email?.toEmail();
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<void> storeSendingEmail(AccountId accountId, UserName userName, SendingEmail sendingEmail) {
    return Future.sync(() async {
      return await _sendingEmailCacheManager.storeSendingEmail(accountId, userName, sendingEmail.toHiveCache());
    }).catchError(_exceptionThrower.throwException);
  }
}