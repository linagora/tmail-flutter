
import 'dart:async';

import 'package:core/data/network/download/downloaded_response.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/file_utils.dart';
import 'package:dio/dio.dart';
import 'package:email_recovery/email_recovery/email_recovery_action.dart';
import 'package:email_recovery/email_recovery/email_recovery_action_id.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/error/set_error.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:model/account/account_request.dart';
import 'package:model/email/attachment.dart';
import 'package:model/email/mark_star_action.dart';
import 'package:model/email/read_actions.dart';
import 'package:model/extensions/email_extension.dart';
import 'package:model/extensions/email_id_extensions.dart';
import 'package:tmail_ui_user/features/caching/utils/caching_constants.dart';
import 'package:tmail_ui_user/features/composer/domain/model/email_request.dart';
import 'package:tmail_ui_user/features/email/data/datasource/email_datasource.dart';
import 'package:tmail_ui_user/features/email/domain/extensions/detailed_email_extension.dart';
import 'package:tmail_ui_user/features/email/domain/extensions/detailed_email_hive_cache_extension.dart';
import 'package:tmail_ui_user/features/email/domain/model/detailed_email.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_to_mailbox_request.dart';
import 'package:tmail_ui_user/features/email/domain/model/preview_email_eml_request.dart';
import 'package:tmail_ui_user/features/email/domain/model/restore_deleted_message_request.dart';
import 'package:tmail_ui_user/features/email/domain/model/view_entire_message_request.dart';
import 'package:tmail_ui_user/features/email/presentation/model/eml_previewer.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/create_new_mailbox_request.dart';
import 'package:tmail_ui_user/features/offline_mode/extensions/list_sending_email_hive_cache_extension.dart';
import 'package:tmail_ui_user/features/offline_mode/extensions/sending_email_hive_cache_extension.dart';
import 'package:tmail_ui_user/features/offline_mode/hive_worker/hive_task.dart';
import 'package:tmail_ui_user/features/offline_mode/manager/new_email_cache_manager.dart';
import 'package:tmail_ui_user/features/offline_mode/manager/new_email_cache_worker_queue.dart';
import 'package:tmail_ui_user/features/offline_mode/manager/opened_email_cache_manager.dart';
import 'package:tmail_ui_user/features/offline_mode/manager/opened_email_cache_worker_queue.dart';
import 'package:tmail_ui_user/features/offline_mode/manager/sending_email_cache_manager.dart';
import 'package:tmail_ui_user/features/offline_mode/model/detailed_email_hive_cache.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/extensions/list_sending_email_extension.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/extensions/sending_email_extension.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/model/sending_email.dart';
import 'package:tmail_ui_user/features/thread/data/extensions/email_cache_extension.dart';
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
  Future<bool> deleteEmailPermanently(
    Session session,
    AccountId accountId,
    EmailId emailId,
    {CancelToken? cancelToken}
  ) async {
    await _emailCacheManager.update(
      accountId,
      session.username,
      destroyed: [emailId],
    );
    return true;
  }

  @override
  Future<({
    List<EmailId> emailIdsSuccess,
    Map<Id, SetError> mapErrors,
  })> deleteMultipleEmailsPermanently(
    Session session,
    AccountId accountId,
    List<EmailId> emailIds,
  ) async {
    await _emailCacheManager.update(
      accountId,
      session.username,
      destroyed: emailIds,
    );
    return (
      emailIdsSuccess: emailIds,
      mapErrors: <Id, SetError>{}
    );
  }

  @override
  Future<DownloadedResponse> exportAttachment(Attachment attachment, AccountId accountId, String baseDownloadUrl, AccountRequest accountRequest, CancelToken cancelToken) {
    throw UnimplementedError();
  }

  @override
  Future<Email> getEmailContent(
    Session session,
    AccountId accountId,
    EmailId emailId,
    {Properties? additionalProperties}
  ) {
    throw UnimplementedError();
  }

  @override
  Future<({
    List<EmailId> emailIdsSuccess,
    Map<Id, SetError> mapErrors,
  })> markAsRead(
    Session session,
    AccountId accountId,
    List<EmailId> emailIds,
    ReadActions readActions,
  ) async {
    final cacheEmails = await _emailCacheManager.getMultipleStoredEmails(
      accountId,
      session.username,
      emailIds,
    );
    final storedEmails = cacheEmails.map((emailCache) => emailCache.toEmail()).toList();
    for (var email in storedEmails) {
      if (readActions == ReadActions.markAsUnread) {
        email.keywords?.remove(KeyWordIdentifier.emailSeen);
      } else {
        email.keywords?[KeyWordIdentifier.emailSeen] = true;
      }
    }
    await _emailCacheManager.storeMultipleEmails(
      accountId,
      session.username,
      storedEmails.map((email) => email.toEmailCache()).toList(),
    );
    return (
      emailIdsSuccess: emailIds,
      mapErrors: <Id, SetError>{}
    );
  }

  @override
  Future<({
    List<EmailId> emailIdsSuccess,
    Map<Id, SetError> mapErrors,
  })> markAsStar(
    Session session,
    AccountId accountId,
    List<EmailId> emailIds,
    MarkStarAction markStarAction,
  ) async {
    final cacheEmails = await _emailCacheManager.getMultipleStoredEmails(
      accountId,
      session.username,
      emailIds,
    );
    final storedEmails = cacheEmails.map((emailCache) => emailCache.toEmail()).toList();
    for (var email in storedEmails) {
      if (markStarAction == MarkStarAction.unMarkStar) {
        email.keywords?.remove(KeyWordIdentifier.emailFlagged);
      } else {
        email.keywords?[KeyWordIdentifier.emailFlagged] = true;
      }
    }
    await _emailCacheManager.storeMultipleEmails(
      accountId,
      session.username,
      storedEmails.map((email) => email.toEmailCache()).toList(),
    );
    return (
      emailIdsSuccess: emailIds,
      mapErrors: <Id, SetError>{}
    );
  }

  @override
  Future<({
    List<EmailId> emailIdsSuccess,
    Map<Id, SetError> mapErrors,
  })> moveToMailbox(
    Session session,
    AccountId accountId,
    MoveToMailboxRequest moveRequest,
  ) async {
    final emailIds = moveRequest
      .currentMailboxes
      .values
      .expand((emails) => emails)
      .toList();
    final cacheEmails = await _emailCacheManager.getMultipleStoredEmails(
      accountId,
      session.username,
      emailIds,
    );
    final storedEmails = cacheEmails.map((emailCache) => emailCache.toEmail()).toList();
    for (int i = 0; i < storedEmails.length; i++) {
      storedEmails[i] = storedEmails[i].updatedEmail(
        newMailboxIds: {moveRequest.destinationMailboxId: true},
      );
    }
    await _emailCacheManager.storeMultipleEmails(
      accountId,
      session.username,
      storedEmails.map((email) => email.toEmailCache()).toList(),
    );
    return (
      emailIdsSuccess: emailIds,
      mapErrors: <Id, SetError>{}
    );
  }

  @override
  Future<bool> removeEmailDrafts(
    Session session,
    AccountId accountId,
    EmailId emailId,
    {CancelToken? cancelToken}
  ) async {
    await _emailCacheManager.update(
      accountId,
      session.username,
      destroyed: [emailId],
    );
    return true;
  }

  @override
  Future<Email> saveEmailAsDrafts(
    Session session,
    AccountId accountId,
    Email email,
    {CancelToken? cancelToken}
  ) async {
    await _emailCacheManager.update(accountId, session.username, created: [email]);
    return email;
  }

  @override
  Future<Email> saveEmailAsTemplate(
    Session session,
    AccountId accountId,
    Email email,
    {
      CreateNewMailboxRequest? createNewMailboxRequest,
      CancelToken? cancelToken
    }
  ) async {
    await _emailCacheManager.update(accountId, session.username, created: [email]);
    return email;
  }

  @override
  Future<Email> updateEmailTemplate(
    Session session,
    AccountId accountId,
    Email newEmail,
    EmailId oldEmailId,
    {CancelToken? cancelToken}
  ) async {
    await _emailCacheManager.update(
      accountId,
      session.username,
      updated: [newEmail],
    );
    return newEmail;
  }

  @override
  Future<bool> sendEmail(
    Session session,
    AccountId accountId,
    EmailRequest emailRequest,
    {
      CreateNewMailboxRequest? mailboxRequest,
      CancelToken? cancelToken
    }
  ) {
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
  Future<Email> updateEmailDrafts(
    Session session,
    AccountId accountId,
    Email newEmail,
    EmailId oldEmailId,
    {CancelToken? cancelToken}
  ) async {
    await _emailCacheManager.update(
      accountId,
      session.username,
      updated: [newEmail],
    );
    return newEmail;
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

  @override
  Future<void> unsubscribeMail(Session session, AccountId accountId, EmailId emailId) {
    throw UnimplementedError();
  }

  @override
  Future<EmailRecoveryAction> restoreDeletedMessage(RestoredDeletedMessageRequest restoredDeletedMessageRequest) {
    throw UnimplementedError();
  }

  @override
  Future<EmailRecoveryAction> getRestoredDeletedMessage(EmailRecoveryActionId emailRecoveryActionId) {
    throw UnimplementedError();
  }

  @override
  Future<void> markAsAnswered(Session session, AccountId accountId, List<EmailId> emailIds) async {
    final cacheEmails = await _emailCacheManager.getMultipleStoredEmails(
      accountId,
      session.username,
      emailIds,
    );

    final storedEmails = cacheEmails
      .map((emailCache) => emailCache.toEmail())
      .toList();

    for (var email in storedEmails) {
      email.keywords?[KeyWordIdentifier.emailAnswered] = true;
    }

    await _emailCacheManager.storeMultipleEmails(
      accountId,
      session.username,
      storedEmails.map((email) => email.toEmailCache()).toList(),
    );

    return Future.value();
  }

  @override
  Future<void> markAsForwarded(Session session, AccountId accountId, List<EmailId> emailIds) async {
    final cacheEmails = await _emailCacheManager.getMultipleStoredEmails(
      accountId,
      session.username,
      emailIds,
    );

    final storedEmails = cacheEmails
      .map((emailCache) => emailCache.toEmail())
      .toList();

    for (var email in storedEmails) {
      email.keywords?[KeyWordIdentifier.emailForwarded] = true;
    }

    await _emailCacheManager.storeMultipleEmails(
      accountId,
      session.username,
      storedEmails.map((email) => email.toEmailCache()).toList(),
    );

    return Future.value();
  }

  @override
  Future<List<Email>> parseEmailByBlobIds(AccountId accountId, Set<Id> blobIds) {
    throw UnimplementedError();
  }

  @override
  Future<String> generatePreviewEmailEMLContent(PreviewEmailEMLRequest previewEmailEMLRequest) {
    throw UnimplementedError();
  }

  @override
  Future<void> sharePreviewEmailEMLContent(EMLPreviewer emlPreviewer) {
    throw UnimplementedError();
  }

  @override
  Future<EMLPreviewer> getPreviewEmailEMLContentShared(String keyStored) {
    throw UnimplementedError();
  }

  @override
  Future<void> removePreviewEmailEMLContentShared(String keyStored) {
    throw UnimplementedError();
  }

  @override
  Future<void> storePreviewEMLContentToSessionStorage(EMLPreviewer emlPreviewer) {
    throw UnimplementedError();
  }

  @override
  Future<EMLPreviewer> getPreviewEMLContentInMemory(String keyStored) {
    throw UnimplementedError();
  }
  
  @override
  Future<DownloadedResponse> exportAllAttachments(AccountId accountId, EmailId emailId, String baseDownloadAllUrl, String outputFileName, AccountRequest accountRequest, {CancelToken? cancelToken}) {
    throw UnimplementedError();
  }

  @override
  Future<String> generateEntireMessageAsDocument(ViewEntireMessageRequest entireMessageRequest) {
    throw UnimplementedError();
  }

  @override
  Future<void> addLabelToEmail(Session session, AccountId accountId, EmailId emailId, KeyWordIdentifier labelKeyword) {
    throw UnimplementedError();
  }

  @override
  Future<void> addLabelToThread(Session session, AccountId accountId, List<EmailId> emailIds, KeyWordIdentifier labelKeyword) {
    throw UnimplementedError();
  }

  @override
  Future<void> removeLabelFromEmail(Session session, AccountId accountId, EmailId emailId, KeyWordIdentifier labelKeyword) {
    throw UnimplementedError();
  }
}