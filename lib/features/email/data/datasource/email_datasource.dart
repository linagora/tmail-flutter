import 'dart:async';

import 'package:core/data/network/download/downloaded_response.dart';
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
import 'package:tmail_ui_user/features/composer/domain/model/email_request.dart';
import 'package:tmail_ui_user/features/email/domain/model/detailed_email.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_to_mailbox_request.dart';
import 'package:tmail_ui_user/features/email/domain/model/preview_email_eml_request.dart';
import 'package:tmail_ui_user/features/email/domain/model/restore_deleted_message_request.dart';
import 'package:tmail_ui_user/features/email/domain/model/view_entire_message_request.dart';
import 'package:tmail_ui_user/features/email/presentation/model/eml_previewer.dart';
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
      CancelToken? cancelToken
    }
  );

  Future<({
    List<EmailId> emailIdsSuccess,
    Map<Id, SetError> mapErrors,
  })> markAsRead(
    Session session,
    AccountId accountId,
    List<EmailId> emailIds,
    ReadActions readActions,
  );

  Future<DownloadedResponse> exportAttachment(
    Attachment attachment,
    AccountId accountId,
    String baseDownloadUrl,
    AccountRequest accountRequest,
    CancelToken cancelToken
  );

  Future<({
    List<EmailId> emailIdsSuccess,
    Map<Id, SetError> mapErrors,
  })> moveToMailbox(
    Session session,
    AccountId accountId,
    MoveToMailboxRequest moveRequest,
  );

  Future<({
    List<EmailId> emailIdsSuccess,
    Map<Id, SetError> mapErrors,
  })> markAsStar(
    Session session,
    AccountId accountId,
    List<EmailId> emailIds,
    MarkStarAction markStarAction
  );

  Future<Email> saveEmailAsDrafts(
    Session session,
    AccountId accountId,
    Email email,
    {CancelToken? cancelToken}
  );

  Future<bool> removeEmailDrafts(
    Session session,
    AccountId accountId,
    EmailId emailId,
    {CancelToken? cancelToken}
  );

  Future<Email> updateEmailDrafts(
    Session session,
    AccountId accountId,
    Email newEmail,
    EmailId oldEmailId,
    {CancelToken? cancelToken}
  );

  Future<Email> saveEmailAsTemplate(
    Session session,
    AccountId accountId,
    Email email,
    {
      CreateNewMailboxRequest? createNewMailboxRequest,
      CancelToken? cancelToken
    }
  );

  Future<Email> updateEmailTemplate(
    Session session,
    AccountId accountId,
    Email newEmail,
    EmailId oldEmailId,
    {CancelToken? cancelToken}
  );

  Future<({
    List<EmailId> emailIdsSuccess,
    Map<Id, SetError> mapErrors,
  })> deleteMultipleEmailsPermanently(
    Session session,
    AccountId accountId,
    List<EmailId> emailIds,
  );

  Future<bool> deleteEmailPermanently(
    Session session,
    AccountId accountId,
    EmailId emailId,
    {CancelToken? cancelToken}
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

  Future<void> unsubscribeMail(Session session, AccountId accountId, EmailId emailId);

  Future<EmailRecoveryAction> restoreDeletedMessage(RestoredDeletedMessageRequest restoredDeletedMessageRequest);

  Future<EmailRecoveryAction> getRestoredDeletedMessage(EmailRecoveryActionId emailRecoveryActionId);

  Future<void> markAsAnswered(
    Session session,
    AccountId accountId,
    List<EmailId> emailIds);

  Future<void> markAsForwarded(
    Session session,
    AccountId accountId,
    List<EmailId> emailIds);

  Future<List<Email>> parseEmailByBlobIds(AccountId accountId, Set<Id> blobIds);

  Future<String> generatePreviewEmailEMLContent(PreviewEmailEMLRequest previewEmailEMLRequest);

  Future<void> sharePreviewEmailEMLContent(EMLPreviewer emlPreviewer);

  Future<EMLPreviewer> getPreviewEmailEMLContentShared(String keyStored);

  Future<void> removePreviewEmailEMLContentShared(String keyStored);

  Future<void> storePreviewEMLContentToSessionStorage(EMLPreviewer emlPreviewer);

  Future<EMLPreviewer> getPreviewEMLContentInMemory(String keyStored);

  Future<DownloadedResponse> exportAllAttachments(
    AccountId accountId,
    EmailId emailId,
    String baseDownloadAllUrl,
    String outputFileName,
    AccountRequest accountRequest,
    {CancelToken? cancelToken}
  );

  Future<String> generateEntireMessageAsDocument(ViewEntireMessageRequest entireMessageRequest);

  Future<void> addLabelToEmail(
    Session session,
    AccountId accountId,
    EmailId emailId,
    KeyWordIdentifier labelKeyword,
  );

  Future<void> addLabelToThread(
    Session session,
    AccountId accountId,
    List<EmailId> emailIds,
    KeyWordIdentifier labelKeyword,
  );

  Future<void> removeLabelFromEmail(
    Session session,
    AccountId accountId,
    EmailId emailId,
    KeyWordIdentifier labelKeyword,
  );
}