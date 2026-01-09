import 'dart:async';

import 'package:core/data/model/preview_attachment.dart';
import 'package:core/data/network/download/downloaded_response.dart';
import 'package:core/domain/extensions/datetime_extension.dart';
import 'package:core/presentation/extensions/html_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/file_utils.dart';
import 'package:core/utils/platform_info.dart';
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
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/composer/domain/model/email_request.dart';
import 'package:tmail_ui_user/features/email/data/datasource/email_datasource.dart';
import 'package:tmail_ui_user/features/email/data/local/html_analyzer.dart';
import 'package:tmail_ui_user/features/email/data/network/email_api.dart';
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
import 'package:tmail_ui_user/main/exceptions/send_email_exception_thrower.dart';

class EmailDataSourceImpl extends EmailDataSource {

  final EmailAPI emailAPI;
  final ExceptionThrower _exceptionThrower;
  final ExceptionThrower _sendEmailExceptionThrower = Get.find<SendEmailExceptionThrower>();
  final PreviewEmlFileUtils _previewEmailUtils = Get.find<PreviewEmlFileUtils>();
  final HtmlAnalyzer _htmlAnalyzer = Get.find<HtmlAnalyzer>();
  final FileUtils _fileUtils = Get.find<FileUtils>();
  final ImagePaths _imagePaths = Get.find<ImagePaths>();

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
  Future<Email> saveEmailAsTemplate(
    Session session,
    AccountId accountId,
    Email email,
    {
      CreateNewMailboxRequest? createNewMailboxRequest,
      CancelToken? cancelToken
    }
  ) {
    return Future.sync(() async {
      return await emailAPI.saveEmailAsTemplate(
        session,
        accountId,
        email,
        createNewMailboxRequest: createNewMailboxRequest,
        cancelToken: cancelToken
      );
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<Email> updateEmailTemplate(
    Session session,
    AccountId accountId,
    Email newEmail,
    EmailId oldEmailId,
    {CancelToken? cancelToken}
  ) {
    return Future.sync(() async {
      return await emailAPI.updateEmailTemplate(
        session,
        accountId,
        newEmail,
        oldEmailId,
        cancelToken: cancelToken
      );
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

  @override
  Future<String> generatePreviewEmailEMLContent(PreviewEmailEMLRequest previewEmailEMLRequest) {
    return Future.sync(() async {
      final email = previewEmailEMLRequest.email;
      final appLocalizations = previewEmailEMLRequest.appLocalizations;
      final locale = previewEmailEMLRequest.locale.toLanguageTag();

      final listAttachments = email
        .allAttachments
        .getListAttachmentsDisplayedOutside(email.htmlBodyAttachments);

      final listInlineImages = email
        .allAttachments
        .listAttachmentsDisplayedInContent;

      final mapCidImageDownloadUrl = listInlineImages.toMapCidImageDownloadUrl(
        accountId: previewEmailEMLRequest.accountId,
        downloadUrl: previewEmailEMLRequest.baseDownloadUrl,
      );

      final emailContentEscaped = await _transformEmailContent(
        email.emailContentList,
        mapCidImageDownloadUrl,
      );

      final sender = email.from?.isNotEmpty == true
        ? email.from!.first
        : null;

      final receiveTime = email.getReceivedAt(
        newLocale: locale,
        pattern: email.receivedAt?.value.toLocal().toPatternForPrinting(locale)
      );

      final sentTime = email.getSentAt(
        newLocale: locale,
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

      final previewEmlHtmlDocument = _previewEmailUtils.generatePreviewEml(
        appName: appLocalizations.app_name,
        ownEmailAddress: previewEmailEMLRequest.ownEmailAddress,
        subjectPrefix: appLocalizations.subject,
        subject: previewEmailEMLRequest.email.subject?.escapeLtGtHtmlString() ?? '',
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

      return previewEmlHtmlDocument;
    }).catchError(_exceptionThrower.throwException);
  }

  Future<String> _transformEmailContent(
    List<EmailContent> emailContents,
    Map<String, String> mapCidImageDownloadUrl,
  ) async {
    try {
      final transformConfiguration = PlatformInfo.isWeb
        ? TransformConfiguration.forPreviewEmailOnWeb()
        : TransformConfiguration.forPreviewEmail();

      final listEmailContent = await Future.wait(emailContents
        .map((emailContent) async => await _htmlAnalyzer.transformEmailContent(
          emailContent,
          mapCidImageDownloadUrl,
          transformConfiguration,
        ))
        .toList());

      return listEmailContent.asHtmlString;
    } catch (e) {
      logError('EmailDataSourceImpl::_transformEmailContent:Exception = $e');
      return '';
    }
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
  Future<void> storePreviewEMLContentToSessionStorage(EMLPreviewer emlPreviewer) {
    throw UnimplementedError();
  }

  @override
  Future<void> removePreviewEmailEMLContentShared(String keyStored) {
    throw UnimplementedError();
  }

  @override
  Future<EMLPreviewer> getPreviewEMLContentInMemory(String keyStored) {
    throw UnimplementedError();
  }
  
  @override
  Future<DownloadedResponse> exportAllAttachments(
    AccountId accountId,
    EmailId emailId,
    String baseDownloadAllUrl,
    String outputFileName,
    AccountRequest accountRequest, {
    CancelToken? cancelToken,
  }) => Future.sync(() async {
    return await emailAPI.exportAllAttachments(
      accountId,
      emailId,
      baseDownloadAllUrl,
      outputFileName,
      accountRequest,
      cancelToken: cancelToken,
    );
  }).catchError(_exceptionThrower.throwException);

  @override
  Future<String> generateEntireMessageAsDocument(ViewEntireMessageRequest entireMessageRequest) {
    throw UnimplementedError();
  }

  @override
  Future<void> addLabelToEmail(
    Session session,
    AccountId accountId,
    EmailId emailId,
    KeyWordIdentifier labelKeyword,
  ) {
    return Future.sync(() async {
      return await emailAPI.addLabelToEmail(
        session,
        accountId,
        emailId,
        labelKeyword,
      );
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<void> addLabelToThread(
    Session session,
    AccountId accountId,
    List<EmailId> emailIds,
    KeyWordIdentifier labelKeyword,
  ) {
    return Future.sync(() async {
      return await emailAPI.addLabelToThread(
        session,
        accountId,
        emailIds,
        labelKeyword,
      );
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<void> removeLabelFromEmail(
    Session session,
    AccountId accountId,
    EmailId emailId,
    KeyWordIdentifier labelKeyword,
  ) {
    return Future.sync(() async {
      return await emailAPI.removeLabelFromEmail(
        session,
        accountId,
        emailId,
        labelKeyword,
      );
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<void> removeLabelFromThread(
    Session session,
    AccountId accountId,
    List<EmailId> emailIds,
    KeyWordIdentifier labelKeyword,
  ) {
    return Future.sync(() async {
      return await emailAPI.removeLabelFromThread(
        session,
        accountId,
        emailIds,
        labelKeyword,
      );
    }).catchError(_exceptionThrower.throwException);
  }
}