import 'dart:async';
import 'dart:typed_data';

import 'package:core/data/network/download/downloaded_response.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:email_recovery/email_recovery/email_recovery_action.dart';
import 'package:email_recovery/email_recovery/email_recovery_action_id.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/sort/comparator.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:model/account/account_request.dart';
import 'package:model/download/download_task_id.dart';
import 'package:model/email/attachment.dart';
import 'package:model/email/email_content.dart';
import 'package:model/email/mark_star_action.dart';
import 'package:model/email/read_actions.dart';
import 'package:tmail_ui_user/features/composer/domain/model/email_request.dart';
import 'package:tmail_ui_user/features/email/domain/model/detailed_email.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_to_mailbox_request.dart';
import 'package:tmail_ui_user/features/email/domain/model/restore_deleted_message_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/create_new_mailbox_request.dart';

abstract class EmailRepository {
  Future<Email> getEmailContent(Session session, AccountId accountId, EmailId emailId);

  Future<bool> sendEmail(
    Session session,
    AccountId accountId,
    EmailRequest emailRequest,
    {CreateNewMailboxRequest? mailboxRequest}
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
    StreamController<Either<Failure, Success>> onReceiveController
  );

  Future<List<EmailId>> moveToMailbox(Session session, AccountId accountId, MoveToMailboxRequest moveRequest);

  Future<List<Email>> markAsStar(
    Session session,
    AccountId accountId,
    List<Email> emails,
    MarkStarAction markStarAction
  );

  Future<List<EmailContent>> transformEmailContent(
    List<EmailContent> emailContents,
    Map<String, String> mapCidImageDownloadUrl,
    TransformConfiguration transformConfiguration
  );

  Future<Email> saveEmailAsDrafts(Session session, AccountId accountId, Email email);

  Future<bool> removeEmailDrafts(Session session, AccountId accountId, EmailId emailId);

  Future<Email> updateEmailDrafts(Session session, AccountId accountId, Email newEmail, EmailId oldEmailId);

  Future<List<EmailId>> deleteMultipleEmailsPermanently(Session session, AccountId accountId, List<EmailId> emailIds);

  Future<bool> deleteEmailPermanently(Session session, AccountId accountId, EmailId emailId);

  Future<jmap.State?> getEmailState(Session session, AccountId accountId);

  Future<void> storeDetailedNewEmail(Session session, AccountId accountId, DetailedEmail detailedEmail);

  Future<List<Email>> getListDetailedEmailById(Session session, AccountId accountId, Set<EmailId> emailIds, {Set<Comparator>? sort});

  Future<void> storeEmail(Session session, AccountId accountId, Email email);

  Future<Email> getStoredEmail(Session session, AccountId accountId, EmailId emailId);

  Future<void> storeOpenedEmail(Session session, AccountId accountId, DetailedEmail detailedEmail);

  Future<DetailedEmail> getStoredOpenedEmail(Session session, AccountId accountId, EmailId emailId);

  Future<DetailedEmail> getStoredNewEmail(Session session, AccountId accountId, EmailId emailId);

  Future<String> transformHtmlEmailContent(
    String htmlContent,
    TransformConfiguration configuration
  );

  Future<Email> unsubscribeMail(Session session, AccountId accountId, EmailId emailId);

  Future<EmailRecoveryAction> restoreDeletedMessage(RestoredDeletedMessageRequest restoredDeletedMessageRequest);

  Future<EmailRecoveryAction> getRestoredDeletedMessage(EmailRecoveryActionId emailRecoveryActionId);
}