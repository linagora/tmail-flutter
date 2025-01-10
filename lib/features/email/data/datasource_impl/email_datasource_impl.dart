import 'dart:async';
import 'dart:typed_data';

import 'package:core/data/network/download/downloaded_response.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:email_recovery/email_recovery/email_recovery_action.dart';
import 'package:email_recovery/email_recovery/email_recovery_action_id.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/error/set_error.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/composer/domain/model/email_request.dart';
import 'package:tmail_ui_user/features/email/data/datasource/email_datasource.dart';
import 'package:tmail_ui_user/features/email/data/network/email_api.dart';
import 'package:tmail_ui_user/features/email/domain/model/detailed_email.dart';
import 'package:tmail_ui_user/features/email/domain/model/event_action.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_to_mailbox_request.dart';
import 'package:tmail_ui_user/features/email/domain/model/restore_deleted_message_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/create_new_mailbox_request.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/model/sending_email.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';
import 'package:tmail_ui_user/main/exceptions/send_email_exception_thrower.dart';

class EmailDataSourceImpl extends EmailDataSource {

  final EmailAPI emailAPI;
  final ExceptionThrower _exceptionThrower;
  final ExceptionThrower _sendEmailExceptionThrower = Get.find<SendEmailExceptionThrower>();

  EmailDataSourceImpl(this.emailAPI, this._exceptionThrower);

  @override
  Future<Email> getEmailContent(
    Session session,
    AccountId accountId,
    EmailId emailId,
    {Properties? additionalProperties}
  ) {
    return Future.sync(() async {
      return await emailAPI.getEmailContent(
        session,
        accountId,
        emailId,
        additionalProperties: additionalProperties);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<void> sendEmail(
    Session session,
    AccountId accountId,
    EmailRequest emailRequest,
    {
      CreateNewMailboxRequest? mailboxRequest,
      CancelToken? cancelToken,
    }
  ) async {
    try {
      return await emailAPI.sendEmail(
        session,
        accountId,
        emailRequest,
        mailboxRequest: mailboxRequest,
        cancelToken: cancelToken
      );
    } catch (error, stackTrace) {
      return await _sendEmailExceptionThrower.throwException(error, stackTrace);
    }
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
  ) {
    return Future.sync(() async {
      return await emailAPI.markAsRead(session, accountId, emailIds, readActions);
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
  Future<({
    List<EmailId> emailIdsSuccess,
    Map<Id, SetError> mapErrors,
  })> moveToMailbox(
    Session session,
    AccountId accountId,
    MoveToMailboxRequest moveRequest,
  ) {
    return Future.sync(() async {
      return await emailAPI.moveToMailbox(session, accountId, moveRequest);
    }).catchError(_exceptionThrower.throwException);
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
  ) {
    return Future.sync(() async {
      return await emailAPI.markAsStar(
        session,
        accountId,
        emailIds,
        markStarAction,
      );
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<Email> saveEmailAsDrafts(
    Session session,
    AccountId accountId,
    Email email,
    {CancelToken? cancelToken}
  ) {
    return Future.sync(() async {
      return await emailAPI.saveEmailAsDrafts(
        session,
        accountId,
        email,
        cancelToken: cancelToken
      );
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<bool> removeEmailDrafts(
    Session session,
    AccountId accountId,
    EmailId emailId,
    {CancelToken? cancelToken}
  ) {
    return Future.sync(() async {
      return await emailAPI.removeEmailDrafts(
        session,
        accountId,
        emailId,
        cancelToken: cancelToken
      );
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<Email> updateEmailDrafts(
    Session session,
    AccountId accountId,
    Email newEmail,
    EmailId oldEmailId,
    {CancelToken? cancelToken}
  ) {
    return Future.sync(() async {
      return await emailAPI.updateEmailDrafts(
        session,
        accountId,
        newEmail,
        oldEmailId,
        cancelToken: cancelToken
      );
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<Uint8List> downloadAttachmentForWeb(
      DownloadTaskId taskId,
      Attachment attachment,
      AccountId accountId,
      String baseDownloadUrl,
      AccountRequest accountRequest,
      StreamController<Either<Failure, Success>> onReceiveController,
      {CancelToken? cancelToken}
  ) {
    return Future.sync(() async {
      return await emailAPI.downloadAttachmentForWeb(
          taskId,
          attachment,
          accountId,
          baseDownloadUrl,
          accountRequest,
          onReceiveController,
          cancelToken: cancelToken);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<({
    List<EmailId> emailIdsSuccess,
    Map<Id, SetError> mapErrors,
  })> deleteMultipleEmailsPermanently(
    Session session,
    AccountId accountId,
    List<EmailId> emailIds,
  ) {
    return Future.sync(() async {
      return await emailAPI.deleteMultipleEmailsPermanently(
        session,
        accountId,
        emailIds,
      );
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<bool> deleteEmailPermanently(
    Session session,
    AccountId accountId,
    EmailId emailId,
    {CancelToken? cancelToken}
  ) {
    return Future.sync(() async {
      return await emailAPI.deleteEmailPermanently(
        session,
        accountId,
        emailId,
        cancelToken: cancelToken
      );
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<void> storeDetailedNewEmail(Session session, AccountId accountId, DetailedEmail detailedEmail) {
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
  Future<DetailedEmail> getStoredOpenedEmail(Session session, AccountId accountId, EmailId emailId) {
    throw UnimplementedError();
  }

  @override
  Future<DetailedEmail> getStoredNewEmail(Session session, AccountId accountId, EmailId emailId) {
    throw UnimplementedError();
  }

  @override
  Future<Email> getStoredEmail(Session session, AccountId accountId, EmailId emailId) {
    throw UnimplementedError();
  }

  @override
  Future<SendingEmail> storeSendingEmail(AccountId accountId, UserName userName, SendingEmail sendingEmail) {
    throw UnimplementedError();
  }

  @override
  Future<List<SendingEmail>> getAllSendingEmails(AccountId accountId, UserName userName) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteSendingEmail(AccountId accountId, UserName userName, String sendingId) {
    throw UnimplementedError();
  }

  @override
  Future<SendingEmail> updateSendingEmail(AccountId accountId, UserName userName, SendingEmail newSendingEmail) {
    throw UnimplementedError();
  }

  @override
  Future<List<SendingEmail>> updateMultipleSendingEmail(AccountId accountId, UserName userName, List<SendingEmail> newSendingEmails) {
    throw UnimplementedError();
  }

  @override
  Future<List<SendingEmail>> deleteMultipleSendingEmail(AccountId accountId, UserName userName, List<String> sendingIds) {
    throw UnimplementedError();
  }

  @override
  Future<SendingEmail> getStoredSendingEmail(AccountId accountId, UserName userName, String sendingId) {
    throw UnimplementedError();
  }

  @override
  Future<void> unsubscribeMail(Session session, AccountId accountId, EmailId emailId) {
    return Future.sync(() async {
      return await emailAPI.unsubscribeMail(session, accountId, emailId);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<EmailRecoveryAction> restoreDeletedMessage(RestoredDeletedMessageRequest restoredDeletedMessageRequest) {
    return Future.sync(() async {
      return await emailAPI.restoreDeletedMessage(restoredDeletedMessageRequest);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<EmailRecoveryAction> getRestoredDeletedMessage(EmailRecoveryActionId emailRecoveryActionId) {
    return Future.sync(() async {
      return await emailAPI.getRestoredDeletedMessage(emailRecoveryActionId);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<void> storeEventAttendanceStatus(
    Session session,
    AccountId accountId,
    EmailId emailId,
    EventActionType eventActionType
  ) {
    return Future.sync(() async {
      return await emailAPI.storeEventAttendanceStatus(
        session,
        accountId,
        emailId,
        eventActionType);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<void> markAsAnswered(Session session, AccountId accountId, List<EmailId> emailIds) {
    throw UnimplementedError();
  }

  @override
  Future<void> markAsForwarded(Session session, AccountId accountId, List<EmailId> emailIds) {
    throw UnimplementedError();
  }

  @override
  Future<List<Email>> parseEmailByBlobIds(AccountId accountId, Set<Id> blobIds) {
    return Future.sync(() async {
      return await emailAPI.parseEmailByBlobIds(accountId, blobIds);
    }).catchError(_exceptionThrower.throwException);
  }
}