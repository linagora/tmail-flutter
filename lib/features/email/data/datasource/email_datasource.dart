import 'dart:async';
import 'dart:typed_data';

import 'package:core/data/network/download/downloaded_response.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:email_recovery/email_recovery/email_recovery_action.dart';
import 'package:email_recovery/email_recovery/email_recovery_action_id.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/account/account_request.dart';
import 'package:model/download/download_task_id.dart';
import 'package:model/email/attachment.dart';
import 'package:model/email/mark_star_action.dart';
import 'package:model/email/read_actions.dart';
import 'package:tmail_ui_user/features/composer/domain/model/email_request.dart';
import 'package:tmail_ui_user/features/email/domain/model/detailed_email.dart';
import 'package:tmail_ui_user/features/email/domain/model/event_action.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_to_mailbox_request.dart';
import 'package:tmail_ui_user/features/email/domain/model/restore_deleted_message_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/create_new_mailbox_request.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/model/sending_email.dart';

abstract class EmailDataSource {
  Future<Email> getEmailContent(
    Session session,
    AccountId accountId,
    EmailId emailId,
    {Properties? additionalProperties});

  Future<void> sendEmail(
    Session session,
    AccountId accountId,
    EmailRequest emailRequest,
    {
      CreateNewMailboxRequest? mailboxRequest,
      CancelToken? cancelToken,
      Duration? timeout,
    }
  );

  Future<List<Email>> markAsRead(Session session, AccountId accountId, List<Email> emails, ReadActions readActions);

  Future<List<DownloadTaskId>> downloadAttachments(
    List<Attachment> attachments,
    AccountId accountId,
    String baseDownloadUrl,
    AccountRequest accountRequest
  );

  Future<DownloadedResponse> exportAttachment(
    Attachment attachment,
    AccountId accountId,
    String baseDownloadUrl,
    AccountRequest accountRequest,
    CancelToken cancelToken
  );

  Future<Uint8List> downloadAttachmentForWeb(
    DownloadTaskId taskId,
    Attachment attachment,
    AccountId accountId,
    String baseDownloadUrl,
    AccountRequest accountRequest,
    StreamController<Either<Failure, Success>> onReceiveController,
    {CancelToken? cancelToken}
  );

  Future<List<EmailId>> moveToMailbox(Session session, AccountId accountId, MoveToMailboxRequest moveRequest);

  Future<List<Email>> markAsStar(
    Session session,
    AccountId accountId,
    List<Email> emails,
    MarkStarAction markStarAction
  );

  Future<Email> saveEmailAsDrafts(
    Session session,
    AccountId accountId,
    Email email,
    {
      CancelToken? cancelToken,
      Duration? timeout
    }
  );

  Future<bool> removeEmailDrafts(
    Session session,
    AccountId accountId,
    EmailId emailId
  );

  Future<Email> updateEmailDrafts(
    Session session,
    AccountId accountId,
    Email newEmail,
    EmailId oldEmailId,
    {
      CancelToken? cancelToken,
      Duration? timeout
    }
  );

  Future<List<EmailId>> deleteMultipleEmailsPermanently(Session session, AccountId accountId, List<EmailId> emailIds);

  Future<bool> deleteEmailPermanently(
    Session session,
    AccountId accountId,
    EmailId emailId,
  );

  Future<void> storeDetailedNewEmail(Session session, AccountId accountId, DetailedEmail detailedEmail);

  Future<Email> getDetailedEmailById(Session session, AccountId accountId, EmailId emailId);

  Future<void> storeEmail(Session session, AccountId accountId, Email email);

  Future<Email> getStoredEmail(Session session, AccountId accountId, EmailId emailId);

  Future<void> storeOpenedEmail(Session session, AccountId accountId, DetailedEmail detailedEmail);

  Future<DetailedEmail> getStoredOpenedEmail(Session session, AccountId accountId, EmailId emailId);

  Future<DetailedEmail> getStoredNewEmail(Session session, AccountId accountId, EmailId emailId);

  Future<SendingEmail> storeSendingEmail(AccountId accountId, UserName userName, SendingEmail sendingEmail);

  Future<SendingEmail> updateSendingEmail(AccountId accountId, UserName userName, SendingEmail newSendingEmail);

  Future<List<SendingEmail>> getAllSendingEmails(AccountId accountId, UserName userName);

  Future<void> deleteSendingEmail(AccountId accountId, UserName userName, String sendingId);

  Future<void> deleteMultipleSendingEmail(AccountId accountId, UserName userName, List<String> sendingIds);

  Future<List<SendingEmail>> updateMultipleSendingEmail(AccountId accountId, UserName userName, List<SendingEmail> newSendingEmails);

  Future<SendingEmail> getStoredSendingEmail(AccountId accountId, UserName userName, String sendingId);

  Future<Email> unsubscribeMail(Session session, AccountId accountId, EmailId emailId);

  Future<EmailRecoveryAction> restoreDeletedMessage(RestoredDeletedMessageRequest restoredDeletedMessageRequest);

  Future<EmailRecoveryAction> getRestoredDeletedMessage(EmailRecoveryActionId emailRecoveryActionId);

  Future<Email> storeEventAttendanceStatus(
    Session session,
    AccountId accountId,
    EmailId emailId,
    EventActionType eventActionType);
}