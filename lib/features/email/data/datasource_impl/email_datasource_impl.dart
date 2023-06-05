import 'dart:async';
import 'dart:typed_data';

import 'package:core/data/network/download/downloaded_response.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/composer/domain/model/email_request.dart';
import 'package:tmail_ui_user/features/email/data/datasource/email_datasource.dart';
import 'package:tmail_ui_user/features/email/data/network/email_api.dart';
import 'package:tmail_ui_user/features/email/domain/model/detailed_email.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_to_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/create_new_mailbox_request.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';

class EmailDataSourceImpl extends EmailDataSource {

  final EmailAPI emailAPI;
  final ExceptionThrower _exceptionThrower;

  EmailDataSourceImpl(this.emailAPI, this._exceptionThrower);

  @override
  Future<Email> getEmailContent(Session session, AccountId accountId, EmailId emailId) {
    return Future.sync(() async {
      return await emailAPI.getEmailContent(session, accountId, emailId);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<bool> sendEmail(
    Session session,
    AccountId accountId,
    EmailRequest emailRequest,
    {CreateNewMailboxRequest? mailboxRequest}
  ) {
    return Future.sync(() async {
      return await emailAPI.sendEmail(session, accountId, emailRequest, mailboxRequest: mailboxRequest);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<List<Email>> markAsRead(
    Session session,
    AccountId accountId,
    List<Email> emails,
    ReadActions readActions
  ) {
    return Future.sync(() async {
      return await emailAPI.markAsRead(session, accountId, emails, readActions);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<List<DownloadTaskId>> downloadAttachments(
      List<Attachment> attachments,
      AccountId accountId,
      String baseDownloadUrl,
      AccountRequest accountRequest
  ) {
    return Future.sync(() async {
      return await emailAPI.downloadAttachments(attachments, accountId, baseDownloadUrl, accountRequest);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<DownloadedResponse> exportAttachment(
      Attachment attachment,
      AccountId accountId,
      String baseDownloadUrl,
      AccountRequest accountRequest,
      CancelToken cancelToken
  ) {
    return Future.sync(() async {
      return await emailAPI.exportAttachment(attachment, accountId, baseDownloadUrl, accountRequest, cancelToken);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<List<EmailId>> moveToMailbox(Session session, AccountId accountId, MoveToMailboxRequest moveRequest) {
    return Future.sync(() async {
      return await emailAPI.moveToMailbox(session, accountId, moveRequest);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<List<Email>> markAsStar(Session session, AccountId accountId, List<Email> emails, MarkStarAction markStarAction) {
    return Future.sync(() async {
      return await emailAPI.markAsStar(session, accountId, emails, markStarAction);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<Email> saveEmailAsDrafts(Session session, AccountId accountId, Email email) {
    return Future.sync(() async {
      return await emailAPI.saveEmailAsDrafts(session, accountId, email);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<bool> removeEmailDrafts(Session session, AccountId accountId, EmailId emailId) {
    return Future.sync(() async {
      return await emailAPI.removeEmailDrafts(session, accountId, emailId);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<Email> updateEmailDrafts(Session session, AccountId accountId, Email newEmail) {
    return Future.sync(() async {
      return await emailAPI.updateEmailDrafts(session, accountId, newEmail);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<Uint8List> downloadAttachmentForWeb(
      DownloadTaskId taskId,
      Attachment attachment,
      AccountId accountId,
      String baseDownloadUrl,
      AccountRequest accountRequest,
      StreamController<Either<Failure, Success>> onReceiveController
  ) {
    return Future.sync(() async {
      return await emailAPI.downloadAttachmentForWeb(
          taskId,
          attachment,
          accountId,
          baseDownloadUrl,
          accountRequest,
          onReceiveController);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<List<EmailId>> deleteMultipleEmailsPermanently(Session session, AccountId accountId, List<EmailId> emailIds) {
    return Future.sync(() async {
      return await emailAPI.deleteMultipleEmailsPermanently(session, accountId, emailIds);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<bool> deleteEmailPermanently(Session session, AccountId accountId, EmailId emailId) {
    return Future.sync(() async {
      return await emailAPI.deleteEmailPermanently(session, accountId, emailId);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<void> storeDetailedEmail(Session session, AccountId accountId, DetailedEmail detailedEmail) {
    throw UnimplementedError();
  }

  @override
  Future<Email> getDetailedEmailById(Session session, AccountId accountId, EmailId emailId) {
    return Future.sync(() async {
      return await emailAPI.getDetailedEmailById(session, accountId, emailId);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<void> storeEmail(Session session, AccountId accountId, Email email) {
    throw UnimplementedError();
  }

  @override
  Future<void> storeOpenedEmail(Session session, AccountId accountId, DetailedEmail detailedEmail) {
    throw UnimplementedError();
  }

  @override
  Future<DetailedEmail> getOpenedEmail(Session session, AccountId accountId, EmailId emailId) {
    throw UnimplementedError();
  }

  @override
  Future<DetailedEmail?> getDetailedEmail(Session session, AccountId accountId, EmailId emailId) {
    throw UnimplementedError();
  }

  @override
  Future<Email?> getEmailFromCache(Session session, AccountId accountId, EmailId emailId) {
    throw UnimplementedError();
  }
}