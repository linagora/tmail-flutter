
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
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/account/account_request.dart';
import 'package:model/download/download_task_id.dart';
import 'package:model/email/attachment.dart';
import 'package:model/email/mark_star_action.dart';
import 'package:model/email/read_actions.dart';
import 'package:model/extensions/email_id_extensions.dart';
import 'package:tmail_ui_user/features/composer/domain/model/email_request.dart';
import 'package:tmail_ui_user/features/email/data/datasource/email_datasource.dart';
import 'package:tmail_ui_user/features/email/domain/extensions/detailed_email_extension.dart';
import 'package:tmail_ui_user/features/email/domain/model/detailed_email.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_to_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/create_new_mailbox_request.dart';
import 'package:tmail_ui_user/features/offline_mode/manager/detailed_email_cache_manager.dart';
import 'package:tmail_ui_user/features/offline_mode/manager/detailed_email_cache_worker_queue.dart';
import 'package:tmail_ui_user/features/offline_mode/worker/hive_task.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';

class EmailHiveCacheDataSourceImpl extends EmailDataSource {

  final DetailedEmailCacheManager _emailCacheManager;
  final DetailedEmailCacheWorkerQueue _cacheWorkerQueue;
  final FileUtils _fileUtils;
  final ExceptionThrower _exceptionThrower;

  EmailHiveCacheDataSourceImpl(
    this._emailCacheManager,
    this._cacheWorkerQueue,
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
  Future<void> storeDetailedEmailToCache(Session session, AccountId accountId, DetailedEmail detailedEmail) {
    return Future.sync(() async {
      final task = HiveTask(
        runnable: () async {
          final fileSaved = await _fileUtils.saveToFile(
            nameFile: detailedEmail.emailId.asString,
            content: detailedEmail.htmlEmailContent ?? '',
            folderPath: detailedEmail.folderPath,
            extensionFile: ExtensionType.text.value
          );
          log('EmailHiveCacheDataSourceImpl::storeDetailedEmailToCache():fileSavedPath: ${fileSaved.path}');
          final detailedEmailSaved = detailedEmail.fromEmailContentPath(fileSaved.path);

          final detailedEmailCache = await _emailCacheManager.handleStoreDetailedEmailToCache(
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
}