
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
import 'package:jmap_dart_client/jmap/core/sort/comparator.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/account/account_request.dart';
import 'package:model/download/download_task_id.dart';
import 'package:model/email/attachment.dart';
import 'package:model/email/mark_star_action.dart';
import 'package:model/email/read_actions.dart';
import 'package:model/extensions/email_id_extensions.dart';
import 'package:tmail_ui_user/features/caching/utils/caching_constants.dart';
import 'package:tmail_ui_user/features/composer/domain/model/email_request.dart';
import 'package:tmail_ui_user/features/email/data/datasource/email_datasource.dart';
import 'package:tmail_ui_user/features/email/domain/extensions/detailed_email_extension.dart';
import 'package:tmail_ui_user/features/email/domain/extensions/detailed_email_hive_cache_extension.dart';
import 'package:tmail_ui_user/features/email/domain/model/detailed_email.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_to_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/create_new_mailbox_request.dart';
import 'package:tmail_ui_user/features/offline_mode/extensions/list_sending_email_hive_cache_extension.dart';
import 'package:tmail_ui_user/features/offline_mode/extensions/sending_email_hive_cache_extension.dart';
import 'package:tmail_ui_user/features/offline_mode/hive_worker/hive_task.dart';
import 'package:tmail_ui_user/features/offline_mode/manager/new_email_cache_manager.dart';
import 'package:tmail_ui_user/features/offline_mode/manager/new_email_cache_worker_queue.dart';
import 'package:tmail_ui_user/features/offline_mode/manager/opened_email_cache_manager.dart';
import 'package:tmail_ui_user/features/offline_mode/manager/opened_email_cache_worker_queue.dart';
import 'package:tmail_ui_user/features/offline_mode/model/detailed_email_hive_cache.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/extensions/list_sending_email_extension.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/extensions/sending_email_extension.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/model/sending_email.dart';
import 'package:tmail_ui_user/features/thread/data/extensions/email_cache_extension.dart';
import 'package:tmail_ui_user/features/offline_mode/manager/sending_email_cache_manager.dart';
import 'package:tmail_ui_user/features/thread/data/extensions/email_extension.dart';
import 'package:tmail_ui_user/features/thread/data/local/email_cache_manager.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';

class EmailHiveCacheDataSourceImpl extends EmailDataSource {

  final NewEmailCacheManager _newEmailCacheManager;
  final OpenedEmailCacheManager _openedEmailCacheManager;
  final NewEmailCacheWorkerQueue _newEmailCacheWorkerQueue;
  final OpenedEmailCacheWorkerQueue _openedEmailCacheWorkerQueue;
  final EmailCacheManager _emailCacheManager;
  final SendingEmailCacheManager _sendingEmailCacheManager;
  final FileUtils _fileUtils;
  final ExceptionThrower _exceptionThrower;

  EmailHiveCacheDataSourceImpl(
    this._newEmailCacheManager,
    this._openedEmailCacheManager,
    this._newEmailCacheWorkerQueue,
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
  Future<void> storeDetailedNewEmail(Session session, AccountId accountId, DetailedEmail detailedEmail) {
    return Future.sync(() async {
      final task = HiveTask(
        id: detailedEmail.emailId.asString,
        runnable: () async {
          final fileSaved = await _fileUtils.saveToFile(
            nameFile: detailedEmail.emailId.asString,
            content: detailedEmail.htmlEmailContent ?? '',
            folderPath: detailedEmail.newEmailFolderPath
          );

          final detailedEmailSaved = detailedEmail.fromEmailContentPath(fileSaved.path);
          final detailedEmailCacheSaved = detailedEmailSaved.toHiveCache();

          final detailedEmailCache = await _newEmailCacheManager.storeDetailedNewEmail(
            accountId,
            session.username,
            detailedEmailCacheSaved);

          return detailedEmailCache;
        });
      return _newEmailCacheWorkerQueue.addTask(task);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<Email> updateEmailDrafts(Session session, AccountId accountId, Email newEmail, EmailId oldEmailId) {
    throw UnimplementedError();
  }

  @override
  Future<List<Email>> getListDetailedEmailById(Session session, AccountId accountId, Set<EmailId> emailIds, {Set<Comparator>? sort}) {
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
        id: detailedEmail.emailId.asString,
        runnable: () async {
          final fileSaved = await _fileUtils.saveToFile(
            nameFile: detailedEmail.emailId.asString,
            content: detailedEmail.htmlEmailContent ?? '',
            folderPath: detailedEmail.openedEmailFolderPath
          );

          final detailedEmailSaved = detailedEmail.fromEmailContentPath(fileSaved.path);

          final detailedEmailCache = await _openedEmailCacheManager.storeOpenedEmail(
            accountId,
            session.username,
            detailedEmailSaved.toHiveCache());

          return detailedEmailCache;
        });
      return _openedEmailCacheWorkerQueue.addTask(task);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<DetailedEmail> getStoredOpenedEmail(Session session, AccountId accountId, EmailId emailId) {
    return Future.sync(() async {
      final listResult = await Future.wait([
        _openedEmailCacheManager.getStoredOpenedEmail(accountId, session.username, emailId),
        _fileUtils.getContentFromFile(nameFile: emailId.asString, folderPath: CachingConstants.openedEmailContentFolderName)
      ], eagerError: true);

      final detailedEmailCache = listResult[0] as DetailedEmailHiveCache;
      final emailContent = listResult[1] as String;
      log('EmailHiveCacheDataSourceImpl::getStoredOpenedEmail():detailedEmailCache: ${detailedEmailCache.emailId} | emailContent: $emailContent');
      return detailedEmailCache.toDetailedEmailWithContent(emailContent);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<DetailedEmail> getStoredNewEmail(Session session, AccountId accountId, EmailId emailId) {
    return Future.sync(() async {
      final listResult = await Future.wait([
        _newEmailCacheManager.getStoredNewEmail(accountId, session.username, emailId),
        _fileUtils.getContentFromFile(nameFile: emailId.asString, folderPath: CachingConstants.newEmailsContentFolderName)
      ], eagerError: true);

      final detailedEmailCache = listResult[0] as DetailedEmailHiveCache;
      final emailContent = listResult[1] as String;
      log('EmailHiveCacheDataSourceImpl::getStoredNewEmail():detailedEmailCache: ${detailedEmailCache.emailId} | emailContent: $emailContent');
      return detailedEmailCache.toDetailedEmailWithContent(emailContent);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<Email> getStoredEmail(Session session, AccountId accountId, EmailId emailId) {
    return Future.sync(() async {
      final email = await _emailCacheManager.getStoredEmail(accountId, session.username, emailId);
      return email.toEmail();
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<SendingEmail> storeSendingEmail(AccountId accountId, UserName userName, SendingEmail sendingEmail) {
    return Future.sync(() async {
      final sendingEmailsCache = await _sendingEmailCacheManager.storeSendingEmail(accountId, userName, sendingEmail.toHiveCache());
      return sendingEmailsCache.toSendingEmail();
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<List<SendingEmail>> getAllSendingEmails(AccountId accountId, UserName userName) {
    return Future.sync(() async {
      final sendingEmailsCache = await _sendingEmailCacheManager.getAllSendingEmailsByTupleKey(accountId, userName);
      return sendingEmailsCache.toSendingEmails();
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<void> deleteSendingEmail(AccountId accountId, UserName userName, String sendingId) {
    return Future.sync(() async {
      return await _sendingEmailCacheManager.deleteSendingEmail(accountId, userName, sendingId);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<SendingEmail> updateSendingEmail(AccountId accountId, UserName userName, SendingEmail newSendingEmail) {
    return Future.sync(() async {
      final sendingEmailsCache = await _sendingEmailCacheManager.updateSendingEmail(accountId, userName, newSendingEmail.toHiveCache());
      return sendingEmailsCache.toSendingEmail();
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<List<SendingEmail>> updateMultipleSendingEmail(AccountId accountId, UserName userName, List<SendingEmail> newSendingEmails) {
    return Future.sync(() async {
      final listSendingEmailsCache = await _sendingEmailCacheManager.updateMultipleSendingEmail(accountId, userName, newSendingEmails.toHiveCache());
      return listSendingEmailsCache.toSendingEmails();
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<void> deleteMultipleSendingEmail(AccountId accountId, UserName userName, List<String> sendingIds) {
    return Future.sync(() async {
      return await _sendingEmailCacheManager.deleteMultipleSendingEmail(accountId, userName, sendingIds);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<SendingEmail> getStoredSendingEmail(AccountId accountId, UserName userName, String sendingId) {
    return Future.sync(() async {
      final sendingEmailCache = await _sendingEmailCacheManager.getStoredSendingEmail(accountId, userName, sendingId);
      return sendingEmailCache.toSendingEmail();
    }).catchError(_exceptionThrower.throwException);
  }
}