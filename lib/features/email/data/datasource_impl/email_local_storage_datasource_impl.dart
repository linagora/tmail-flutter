
import 'dart:async';
import 'dart:convert';

import 'package:core/data/model/preview_attachment.dart';
import 'package:core/data/network/download/downloaded_response.dart';
import 'package:core/domain/extensions/datetime_extension.dart';
import 'package:core/presentation/extensions/html_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/utils/file_utils.dart';
import 'package:core/utils/preview_eml_file_utils.dart';
import 'package:dio/dio.dart';
import 'package:email_recovery/email_recovery/email_recovery_action.dart';
import 'package:email_recovery/email_recovery/email_recovery_action_id.dart';
import 'package:filesize/filesize.dart';
import 'package:get/get.dart';
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
import 'package:model/extensions/list_email_address_extension.dart';
import 'package:model/extensions/presentation_email_extension.dart';
import 'package:tmail_ui_user/features/caching/utils/local_storage_manager.dart';
import 'package:tmail_ui_user/features/composer/domain/model/email_request.dart';
import 'package:tmail_ui_user/features/email/data/datasource/email_datasource.dart';
import 'package:tmail_ui_user/features/email/domain/model/detailed_email.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_to_mailbox_request.dart';
import 'package:tmail_ui_user/features/email/domain/model/preview_email_eml_request.dart';
import 'package:tmail_ui_user/features/email/domain/model/restore_deleted_message_request.dart';
import 'package:tmail_ui_user/features/email/domain/model/view_entire_message_request.dart';
import 'package:tmail_ui_user/features/email/presentation/extensions/attachment_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/model/eml_previewer.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/create_new_mailbox_request.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/model/sending_email.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';

class EmailLocalStorageDataSourceImpl extends EmailDataSource {

  final LocalStorageManager _localStorageManager;
  final PreviewEmlFileUtils _previewEmlFileUtils;
  final ExceptionThrower _exceptionThrower;
  final ImagePaths _imagePaths = Get.find<ImagePaths>();
  final FileUtils _fileUtils = Get.find<FileUtils>();

  EmailLocalStorageDataSourceImpl(
    this._localStorageManager,
    this._previewEmlFileUtils,
    this._exceptionThrower,
  );

  @override
  Future<bool> deleteEmailPermanently(Session session, AccountId accountId, EmailId emailId, {CancelToken? cancelToken}) {
    throw UnimplementedError();
  }

  @override
  Future<({List<EmailId> emailIdsSuccess, Map<Id, SetError> mapErrors})> deleteMultipleEmailsPermanently(Session session, AccountId accountId, List<EmailId> emailIds) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteMultipleSendingEmail(AccountId accountId, UserName userName, List<String> sendingIds) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteSendingEmail(AccountId accountId, UserName userName, String sendingId) {
    throw UnimplementedError();
  }

  @override
  Future<DownloadedResponse> exportAttachment(Attachment attachment, AccountId accountId, String baseDownloadUrl, AccountRequest accountRequest, CancelToken cancelToken) {
    throw UnimplementedError();
  }

  @override
  Future<String> generatePreviewEmailEMLContent(PreviewEmailEMLRequest previewEmailEMLRequest) {
    throw UnimplementedError();
  }

  @override
  Future<List<SendingEmail>> getAllSendingEmails(AccountId accountId, UserName userName) {
    throw UnimplementedError();
  }

  @override
  Future<Email> getDetailedEmailById(Session session, AccountId accountId, EmailId emailId) {
    throw UnimplementedError();
  }

  @override
  Future<Email> getEmailContent(Session session, AccountId accountId, EmailId emailId, {Properties? additionalProperties}) {
    throw UnimplementedError();
  }

  @override
  Future<EmailRecoveryAction> getRestoredDeletedMessage(EmailRecoveryActionId emailRecoveryActionId) {
    throw UnimplementedError();
  }

  @override
  Future<Email> getStoredEmail(Session session, AccountId accountId, EmailId emailId) {
    throw UnimplementedError();
  }

  @override
  Future<DetailedEmail> getStoredNewEmail(Session session, AccountId accountId, EmailId emailId) {
    throw UnimplementedError();
  }

  @override
  Future<DetailedEmail> getStoredOpenedEmail(Session session, AccountId accountId, EmailId emailId) {
    throw UnimplementedError();
  }

  @override
  Future<SendingEmail> getStoredSendingEmail(AccountId accountId, UserName userName, String sendingId) {
    throw UnimplementedError();
  }

  @override
  Future<({List<EmailId> emailIdsSuccess, Map<Id, SetError> mapErrors})> markAsRead(Session session, AccountId accountId, List<EmailId> emailIds, ReadActions readActions) {
    throw UnimplementedError();
  }

  @override
  Future<({List<EmailId> emailIdsSuccess, Map<Id, SetError> mapErrors})> markAsStar(Session session, AccountId accountId, List<EmailId> emailIds, MarkStarAction markStarAction) {
    throw UnimplementedError();
  }

  @override
  Future<({List<EmailId> emailIdsSuccess, Map<Id, SetError> mapErrors})> moveToMailbox(Session session, AccountId accountId, MoveToMailboxRequest moveRequest) {
    throw UnimplementedError();
  }

  @override
  Future<List<Email>> parseEmailByBlobIds(AccountId accountId, Set<Id> blobIds) {
    throw UnimplementedError();
  }

  @override
  Future<bool> removeEmailDrafts(Session session, AccountId accountId, EmailId emailId, {CancelToken? cancelToken}) {
    throw UnimplementedError();
  }

  @override
  Future<EmailRecoveryAction> restoreDeletedMessage(RestoredDeletedMessageRequest restoredDeletedMessageRequest) {
    throw UnimplementedError();
  }

  @override
  Future<Email> saveEmailAsDrafts(Session session, AccountId accountId, Email email, {CancelToken? cancelToken}) {
    throw UnimplementedError();
  }

  @override
  Future<void> sendEmail(Session session, AccountId accountId, EmailRequest emailRequest, {CreateNewMailboxRequest? mailboxRequest, CancelToken? cancelToken}) {
    throw UnimplementedError();
  }

  @override
  Future<void> sharePreviewEmailEMLContent(EMLPreviewer emlPreviewer) {
    return Future.sync(() async {
      return _localStorageManager.save(
        emlPreviewer.id,
        jsonEncode(emlPreviewer.toJson()),
      );
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<void> storeDetailedNewEmail(Session session, AccountId accountId, DetailedEmail detailedEmail) {
    throw UnimplementedError();
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
  Future<SendingEmail> storeSendingEmail(AccountId accountId, UserName userName, SendingEmail sendingEmail) {
    throw UnimplementedError();
  }

  @override
  Future<void> unsubscribeMail(Session session, AccountId accountId, EmailId emailId) {
    throw UnimplementedError();
  }

  @override
  Future<Email> updateEmailDrafts(Session session, AccountId accountId, Email newEmail, EmailId oldEmailId, {CancelToken? cancelToken}) {
    throw UnimplementedError();
  }

  @override
  Future<List<SendingEmail>> updateMultipleSendingEmail(AccountId accountId, UserName userName, List<SendingEmail> newSendingEmails) {
    throw UnimplementedError();
  }

  @override
  Future<SendingEmail> updateSendingEmail(AccountId accountId, UserName userName, SendingEmail newSendingEmail) {
    throw UnimplementedError();
  }

  @override
  Future<EMLPreviewer> getPreviewEmailEMLContentShared(String keyStored) {
    return Future.sync(() async {
      final data = _localStorageManager.get(keyStored);
      return EMLPreviewer.fromJson(jsonDecode(data));
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<void> storePreviewEMLContentToSessionStorage(EMLPreviewer emlPreviewer) {
    throw UnimplementedError();
  }

  @override
  Future<void> removePreviewEmailEMLContentShared(String keyStored) {
    return Future.sync(() async {
      return _localStorageManager.remove(keyStored);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<EMLPreviewer> getPreviewEMLContentInMemory(String keyStored) {
    throw UnimplementedError();
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
  Future<DownloadedResponse> exportAllAttachments(AccountId accountId, EmailId emailId, String baseDownloadAllUrl, String outputFileName, AccountRequest accountRequest, {CancelToken? cancelToken}) {
    throw UnimplementedError();
  }

  @override
  Future<String> generateEntireMessageAsDocument(ViewEntireMessageRequest entireMessageRequest) {
    return Future.sync(() async {
      final email = entireMessageRequest.presentationEmail;
      final appLocalizations = entireMessageRequest.appLocalizations;
      final locale = entireMessageRequest.locale.toLanguageTag();
      final listAttachments = entireMessageRequest.attachments;
      final emailContentEscaped = entireMessageRequest.emailContent;

      final sender = email.from?.isNotEmpty == true
          ? email.from!.first
          : null;

      final receiveTime = email.getReceivedAt(
          locale,
          pattern: email.receivedAt?.value.toLocal().toPatternForPrinting(locale)
      );

      final sentTime = email.getSentAt(
          locale,
          pattern: email.sentAt?.value.toLocal().toPatternForPrinting(locale)
      );

      final List<PreviewAttachment> listPreviewAttachment = [];

      if (listAttachments.isNotEmpty) {
        await Future.forEach<Attachment>(listAttachments, (attachment) async {
          final iconBase64Data = await _fileUtils.convertImageAssetToBase64(
              attachment.getIcon(_imagePaths));

          final previewAttachment = PreviewAttachment(
            iconBase64Data: iconBase64Data,
            name: attachment.name.escapeLtGtHtmlString(),
            size: filesize(attachment.size?.value),
            link: attachment.hyperLink,
          );

          listPreviewAttachment.add(previewAttachment);
        });
      }

      final attachmentIconBase64Data = email.hasAttachment == true
          ? await _fileUtils.convertImageAssetToBase64(_imagePaths.icAttachment)
          : '';

      final htmlDocument = _previewEmlFileUtils.generatePreviewEml(
        appName: appLocalizations.app_name,
        ownEmailAddress: entireMessageRequest.ownEmailAddress,
        subjectPrefix: appLocalizations.subject,
        subject: email.subject?.escapeLtGtHtmlString() ?? '',
        emailContent: emailContentEscaped,
        senderName: sender?.name.escapeLtGtHtmlString() ?? '',
        senderEmailAddress: sender?.email ?? '',
        dateTime: receiveTime.isNotEmpty ? receiveTime : sentTime,
        fromPrefix: appLocalizations.from_email_address_prefix,
        toPrefix: appLocalizations.to_email_address_prefix,
        ccPrefix: appLocalizations.cc_email_address_prefix,
        bccPrefix: appLocalizations.bcc_email_address_prefix,
        replyToPrefix: appLocalizations.replyToEmailAddressPrefix,
        titleAttachment: listPreviewAttachment.length > 1
          ? appLocalizations.attachments.toLowerCase()
          : appLocalizations.attachment.toLowerCase(),
        attachmentIcon: attachmentIconBase64Data,
        toAddress: email.to?.listEmailAddressToString(isFullEmailAddress: true),
        ccAddress: email.cc?.listEmailAddressToString(isFullEmailAddress: true),
        bccAddress: email.bcc?.listEmailAddressToString(isFullEmailAddress: true),
        replyToAddress: email.replyTo?.listEmailAddressToString(isFullEmailAddress: true),
        listAttachment: listPreviewAttachment,
      );

      return htmlDocument;
    }).catchError(_exceptionThrower.throwException);
  }
  
  @override
  Future<Email> saveEmailAsTemplate(
    Session session,
    AccountId accountId,
    Email email, {
    CreateNewMailboxRequest? createNewMailboxRequest,
    CancelToken? cancelToken,
  }) {
    throw UnimplementedError();
  }
  
  @override
  Future<Email> updateEmailTemplate(
    Session session,
    AccountId accountId,
    Email newEmail,
    EmailId oldEmailId, {
    CancelToken? cancelToken,
  }) {
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